extends Node3D

@onready var _command_window : PopupWindow = $CommandWindow
@onready var _radar_window : PopupWindow = $RadarWindow

func _ready():
	_command_window.close()
	_radar_window.close()


func _on_cmd_pressed():
	if _command_window.is_open():
		_command_window.close()
	else:
		_command_window.open()


func _on_radar_pressed() -> void:
	if _radar_window.is_open():
		_radar_window.close()
	else:
		_radar_window.open()


func _on_debug_map_pressed() -> void:
	pass # Replace with function body.
