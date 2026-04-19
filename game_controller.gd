extends Node3D

@onready var _radar_window : PopupWindow = $RadarWindow
@onready var _scanner_window : PopupWindow = $ScannerWindow

@onready var _start_room : RoomBase = $Room1

@export var DroneButtons : Array[Button]
var _buttons : Dictionary
@export var MaxDrones = 3

@export var DroneScene : PackedScene
@export var DroneSpawnPos : Node3D

@export var DEBUG_gen_start_active = false
@export var DEBUG_server_always_active = false

func _ready():
	CommandManager.close()
	_radar_window.close()
	_scanner_window.close()

	_buttons = {}
	for b in DroneButtons:
		_buttons[b] = null
		b.hide()

	reveal_start.call_deferred()

	if DEBUG_gen_start_active:
		await $Room5/Generator.interaction_start(null)
	if DEBUG_server_always_active:
		await $Room9/Server.interaction_start(null)


func reveal_start():
	await DoorManager.walls_loaded

	DoorManager.reveal_room(_start_room.get_rid())

	CommandManager.send_command('deploy b1')


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


func _on_drone_destroyed(drone:DroneBase):
	for b in _buttons.keys():
		if _buttons[b] == drone:
			_buttons[b] = null
			b.pressed.disconnect(_on_drone_button_pressed)
			b.hide()
	

func process_command(cmd:String, args:Array[String]):
	if cmd == 'deploy':
		if args.size() != 1:
			return CommandManager.CommandOutput.new(false, ['deploy requires exactly 1 argument (deploy [bot name])'])

		var drones = get_tree().get_nodes_in_group(Constants.DRONE_GROUP)
		if drones.size() >= MaxDrones:
			return CommandManager.CommandOutput.new(false, ['Maximum bots deployed. Raise bandwidth before deploying more'])

		for i in drones:
			if i.DroneID == args[0]:
				return CommandManager.CommandOutput.new(false, ['BotID {0} already in use'.format([args[0]])])

		var d = DroneScene.instantiate()
		d.DroneID = args[0]
		d.destroyed.connect(_on_drone_destroyed.bind(d))

		for b in DroneButtons:
			if _buttons[b] == null:
				_buttons[b] = d
				b.show()
				b.pressed.connect(_on_drone_button_pressed.bind(args[0]))
				break

		add_child(d)
		d.global_position = DroneSpawnPos.global_position
		return CommandManager.CommandOutput.new(true, ['{0} ready for service'.format([args[0]])])
		
