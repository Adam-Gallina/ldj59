extends Node3D

@onready var radius_line : LineMesh3D = $RadiusLineMesh3D
@onready var pointer_line : LineMesh3D = $PointerLineMesh3D
@onready var point_line : LineMesh3D = $PointLineMesh3D

@export var AnimDuration = .9

var _animating = true

func do_pulse(pulse_source:Node3D, pulse_target:Scannable, pulse_offset:float, additional_pulse:Array):
	var dist = pulse_source.global_position.distance_to(pulse_target.get_parent().global_position)

	if additional_pulse.size() == 1:
		animate_pulse(pulse_source.global_position + Vector3.UP * pulse_offset, dist, 0, 360, AnimDuration)
	elif additional_pulse.size() > 2:
		var start_pos = pulse_source.global_position + Vector3.UP * pulse_offset
		var end_pos = pulse_target.get_parent().global_position + Vector3.UP * pulse_offset
		pointer_line.display_line([start_pos, start_pos + start_pos.direction_to(end_pos) * (start_pos.distance_to(end_pos) - .5)])
		point_line.display_donut(end_pos, .2, 36)
		radius_line.clear()
	else:
		var other_source = additional_pulse[0] if additional_pulse[0] != pulse_source else additional_pulse[1]
		var other_dir : Vector3 = pulse_source.global_position.direction_to(other_source.global_position)

		var target_dir : Vector3 = pulse_source.global_position.direction_to(pulse_target.get_parent().global_position)

		var ang = other_dir.signed_angle_to(target_dir, Vector3.UP)
		var dir = other_dir.normalized() * dist
		dir = dir.rotated(Vector3.UP, -ang)

		var start_ang = Vector3.FORWARD.signed_angle_to(target_dir, Vector3.UP)
		if start_ang < 0: start_ang += 2 * PI
		var end_ang = Vector3.FORWARD.signed_angle_to(dir, Vector3.UP)
		if end_ang < 0: end_ang += 2 * PI

		animate_pulse(pulse_source.global_position + Vector3.UP * pulse_offset, dist, rad_to_deg(start_ang), rad_to_deg(end_ang), AnimDuration * .75)


func animate_pulse(start_pos:Vector3, radius:float, start_ang:float, end_ang:float, duration):
	var anim = 0

	_animating = true

	while anim < duration and _animating:
		anim += get_process_delta_time()

		var t = anim / duration
		t = ease(t, -3)

		var ang = start_ang + (end_ang - start_ang) * t

		var dir = Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(ang))
		pointer_line.display_line([start_pos, start_pos + dir * (radius)])

		point_line.display_donut(start_pos + dir * radius, .2, 36)

		radius_line.display_arc(start_pos, radius - radius_line.MaxWidth/2, start_ang, ang, 72)

		await get_tree().process_frame

	if _animating:
		var end_dir = Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(end_ang))
		pointer_line.display_line([start_pos, start_pos + end_dir * (radius - .5)])

		point_line.display_donut(start_pos + end_dir * radius, .2, 36)

		radius_line.display_arc(start_pos, radius - radius_line.MaxWidth/2, start_ang, end_ang, 72)
		_animating = false


func clear():
	pointer_line.clear()
	point_line.clear()
	radius_line.clear()
	_animating = false
