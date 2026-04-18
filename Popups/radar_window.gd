extends PopupWindow

@onready var _direction_label = $Label4
@onready var _direction : Knob = $DirectionKnob
@onready var _angle_label = $Label
@onready var _angle : Knob = $AngleKnob
@onready var _strength_label = $Label2
@onready var _strength : Knob = $StrengthKnob
@onready var _precision_label = $Label3
@onready var _precision : Knob = $PrecisionKnob

@onready var _target_label = $Label5

@onready var _radar_edge : LineMesh3D = $LineMesh3D
@onready var _radar_cap : LineMesh3D = $CapLineMesh3D
@onready var _radar_pulse : LineMesh3D = $PulseLineMesh3D

@onready var _radar_cast : ShapeCast3D = $ShapeCast3D
@export var RadarCastDepth = 1.
@export var RadarPingScene : PackedScene
@export var PingOffset = 3.

var _active = false
@export var _curr_target : Node3D
var _curr_pulse = 0
@onready var _last_position = Vector3.ZERO
@onready var _last_direction = 0.
@onready var _last_angle = _angle.Value
@onready var _last_precision = calc_precision()

@export var Routers : Array[Node3D]
var _routers : Dictionary = {}

func _ready() -> void:
	for r in Routers:
		_routers[r.RouterID] = r


func _process(delta):
	if not _active: return

	var _last_pulse = _curr_pulse
	_curr_pulse += _last_precision * delta                      
	if _curr_pulse >= calc_strength():
		_last_pulse = 0
		_curr_pulse = 0
		_last_position = _curr_target.global_position
		_last_direction = _direction.Value
		_last_angle = _angle.Value
		_last_precision = calc_precision()

	draw_radar(_last_position + Vector3.UP * 4, _direction.Value, _angle.Value, calc_strength())
	draw_pulse(_last_position + Vector3.UP * 4, _last_direction, _last_angle, _curr_pulse)

	var colls = do_scan(_last_position + Vector3.UP * 4, _direction.Value, _angle.Value, calc_strength())

	for c in colls:
		if c == _curr_target: continue

		var dist = _last_position.distance_to(c.global_position)
		if dist >= _last_pulse and dist <= _curr_pulse:
			var ping = RadarPingScene.instantiate()
			get_parent().add_child(ping)
			ping.global_position = c.global_position + Vector3.UP * PingOffset
			ping.spawn(calc_strength() / _last_precision)


func draw_radar(pos:Vector3, rotation:float, angle:float, strength:float):
	var dir_l : Vector3 = Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(-rotation - angle/2))
	var dir_r : Vector3 = Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(-rotation + angle/2))

	_radar_edge.display_line([pos + dir_l * strength, pos, pos + dir_r * strength])

	_radar_cap.display_arc(pos, strength - _radar_cap.MaxWidth, -rotation - angle/2, -rotation + angle/2, 36)

func draw_pulse(pos:Vector3, rotation:float, angle:float, pulse_dist:float):
	_radar_pulse.display_arc(pos, pulse_dist - _radar_cap.MaxWidth/2, -rotation - angle/2, -rotation + angle/2, 36)


func do_scan(pos:Vector3, rotation:float, angle:float, strength:float) -> Array[Node3D]:
	var dir_l : Vector3 = Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(-rotation - angle/2))
	var dir : Vector3 = Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(-rotation))
	var dir_r : Vector3 = Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(-rotation + angle/2))

	var offset : Vector3 = Vector3.UP * RadarCastDepth

	_radar_cast.shape.points = [
		pos + dir_l * strength, pos + dir_l * strength + offset,
		pos, pos + offset, 
		pos + dir_r * strength, pos + dir_r * strength + offset,
		pos + dir * strength, pos + dir * strength + offset
	]

	_radar_cast.force_shapecast_update()
	var colls : Array[Node3D] = []
	for i in _radar_cast.get_collision_count():
		colls.append(_radar_cast.get_collider(i))

	return colls


func process_command(cmd:String, args:Array[String]) -> CommandWindow.CommandOutput:
	if cmd == 'radar':
		if args[0] == 'start':
			start_radar()
			return CommandWindow.CommandOutput.new(true, [])
		elif args[0] == 'stop':
			stop_radar()
			return CommandWindow.CommandOutput.new(true, [])
		elif _routers.get(args[0]):
			_curr_target = _routers[args[0]]
			_target_label = 'Scanning from: ' + args[0]
			start_radar()
			return CommandWindow.CommandOutput.new(true, [])
		elif args[0][0] == 'b':
			print(get_tree())
			for d in get_tree().get_nodes_in_group(Constants.DRONE_GROUP):
				if d.DroneID == args[0]:
					_curr_target = d
					_target_label = 'Scanning from: ' + d.DroneID
					start_radar()
					return CommandWindow.CommandOutput.new(true, [])

		return CommandWindow.CommandOutput.new(false, ['RADAR: Could not find ' + args[0]])

	return null


func calc_precision() -> float:
	var p = _precision.Value
	p = (_precision.MaxValue - (p - _precision.MinValue)) / 10. 
	return p

func calc_strength() -> float:
	return _strength.Value / 10.


func _on_direction_changed(new_value:int) -> void:
	_direction_label.text = 'Direction: {0}'.format([new_value])

func _on_angle_changed(new_value:int) -> void:
	_angle_label.text = 'Angle: {0}'.format([new_value])

func _on_strength_changed(new_value:int) -> void:
	new_value /= 10
	_strength_label.text = 'Strength: {0}'.format([new_value])

func _on_precision_changed(new_value:int) -> void:
	_precision_label.text = 'Precision: {0}'.format([new_value])


func start_radar():
	_radar_edge.show()
	_radar_cap.show()
	_radar_pulse.show()
	_curr_pulse = calc_strength()
	_active = true

func stop_radar():
	_radar_edge.hide()
	_radar_cap.hide()
	_radar_pulse.hide()
	_active = false

func open():
	super()
	start_radar()

func close():
	super()
	stop_radar()
