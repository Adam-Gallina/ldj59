extends Node3D

@onready var _radar_window : PopupWindow = $RadarWindow
@onready var _scanner_window : PopupWindow = $ScannerWindow

@onready var _start_room : RoomBase = $Room1

@export var DEBUG_gen_start_active = false

func _ready():
	CommandManager.close()
	_radar_window.close()
	_scanner_window.close()

	reveal_start.call_deferred()

	if DEBUG_gen_start_active:
		$Room5/Generator.interaction_start(null)


func reveal_start():
	await DoorManager.walls_loaded

	DoorManager.reveal_room(_start_room.get_rid())


func _on_cmd_pressed():
	if CommandManager.is_open():
		CommandManager.close()
	else:
		CommandManager.open()


func _on_radar_pressed() -> void:
	if _radar_window.is_open():
		_radar_window.close()
	else:
		_radar_window.open()

func _on_scanner_pressed() -> void:
	if _scanner_window.is_open():
		_scanner_window.close()
	else:
		_scanner_window.open()


func _on_drone_button_pressed(droneID:String) -> void:
	CommandManager.send_command(droneID + ' control')
