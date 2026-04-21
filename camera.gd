extends Camera3D

@export var MinZoom = 2.5
@export var MaxZoom = 50
@export var ZoomSpeed = 10.
@export var ScrollSpeed = 1.
var _scrolling = false
var _last_mouse_pos : Vector3 = Vector3.ZERO

var _can_control = true

func _process(delta):
	if not _can_control: return
	
	if Input.is_action_just_pressed('pan') and WindowManager._curr_window == null:
		_scrolling = true
	if Input.is_action_just_released('pan'):
		_scrolling = false

	if _scrolling:
		var mp = get_viewport().get_mouse_position()
		var wp = project_position(mp, 10) - global_position
		wp.y = 0

		if _scrolling and _last_mouse_pos != Vector3.ZERO:
			var dir = _last_mouse_pos - wp
			global_position += dir

		_last_mouse_pos = wp
	else:
		_last_mouse_pos = Vector3.ZERO


	if Input.is_action_just_pressed('zoom_in') and WindowManager._curr_window == null:
		#size -= ZoomSpeed * delta
		global_position.y -= ZoomSpeed * delta
	if Input.is_action_just_pressed('zoom_out') and WindowManager._curr_window == null:
		#size += ZoomSpeed * delta
		global_position.y += ZoomSpeed * delta
	#size = clamp(size, MinZoom, MaxZoom)
	global_position.y = clamp(global_position.y, MinZoom, MaxZoom)
