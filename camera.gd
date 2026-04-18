extends Camera3D

@export var MinZoom = 2.5
@export var MaxZoom = 50
@export var ZoomSpeed = 10.
@export var ScrollSpeed = 1.
var _scrolling = false
var _last_mouse_pos : Vector3 = Vector3.ZERO

func _process(delta):
	_scrolling = Input.is_action_pressed('pan')

	if _scrolling:
		var mp = get_viewport().get_mouse_position()
		var wp = project_position(mp, 0) - global_position
		wp.y = 0

		if _scrolling and _last_mouse_pos != Vector3.ZERO:
			var dir = _last_mouse_pos - wp
			global_position += dir

		_last_mouse_pos = wp
	else:
		_last_mouse_pos = Vector3.ZERO


	if Input.is_action_just_pressed('zoom_in'):
		size -= ZoomSpeed * delta
	if Input.is_action_just_pressed('zoom_out'):
		size += ZoomSpeed * delta
	size = clamp(size, MinZoom, MaxZoom)
