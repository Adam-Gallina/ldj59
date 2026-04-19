extends Node3D

@onready var _radar_window : PopupWindow = $RadarWindow
@onready var _scanner_window : PopupWindow = $ScannerWindow
@onready var _message_window : PopupWindow = $MessageWindow

@onready var _start_room : RoomBase = $Rooms/Room1

@export var DroneButtons : Array[Button]
var _buttons : Dictionary
@export var MaxDrones = 1

@export var DroneScene : PackedScene
@export var DroneSpawnPos : Node3D

@export var DEBUG_gen_start_active = false
@export var DEBUG_server_always_active = false

@onready var _message_notification : TextureRect = $CanvasLayer/MessageButton/TextureRect
@export var NotificationMaxSize : float = 1.35
@export var NotificationSpeed : float = .75
var _notif_elapsed = 0.

func _ready():
	CommandManager.close()
	_radar_window.close()
	_scanner_window.close()
	DataWindow.close()

	_message_window.close()
	_message_window.message_received.connect(_on_message_received)
	_message_window.message_read.connect(_on_message_read)
	_message_notification.hide()

	_buttons = {}
	for b in DroneButtons:
		_buttons[b] = null
		b.hide()

	reveal_start.call_deferred()

	if DEBUG_gen_start_active:
		await $Rooms/Room5/Generator.interaction_start(null)
	if DEBUG_server_always_active:
		await $Rooms/Room9/Server.interaction_start(null)
		await $Rooms/Room9/Server.interaction_start(null)


func reveal_start():
	await DoorManager.walls_loaded

	DoorManager.reveal_room(_start_room.get_rid())

	CommandManager.send_command('deploy m1')

	_message_window.log_message('test')


func _process(delta: float) -> void:
	if _message_notification.visible:
		_notif_elapsed += delta

		var t = (1 + sin(_notif_elapsed * NotificationSpeed * (2 * PI))) / 2
		var s = 1 + (NotificationMaxSize - 1) * t
		_message_notification.scale = Vector2(s, s)


func _on_cmd_pressed():
	if CommandManager.is_open():
		CommandManager.close()
	else:
		CommandManager.open()

func _on_data_pressed():
	if DataWindow.is_open():
		DataWindow.close()
	else:
		DataWindow.open()


func _on_msg_pressed() -> void:
	if _message_window.is_open():
		_message_window.close()
	else:
		_message_window.open()

func _on_message_received():
	_message_notification.show()

func _on_message_read():
	_message_notification.hide()

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


func spawn_drone(droneID:String, spawn_pos:Vector3):
	var d = DroneScene.instantiate()
	d.DroneID = droneID
	d.destroyed.connect(_on_drone_destroyed.bind(d))

	for b in DroneButtons:
		if _buttons[b] == null:
			_buttons[b] = d
			b.show()
			b.pressed.connect(_on_drone_button_pressed.bind(droneID))
			break

	add_child(d)
	d.global_position = spawn_pos

	return d

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
 		
		spawn_drone(args[0], DroneSpawnPos.global_position)

		return CommandManager.CommandOutput.new(true, ['{0} ready for service'.format([args[0]])])
	elif cmd == 'xtra':
		MaxDrones += 1
