extends CharacterBody3D
class_name DroneBase

signal move_complete()
signal destroyed()

@export var DroneID : String

@onready var _control_window : PopupWindow = $ControlWindow
@onready var _nav_agent : NavigationAgent3D = $NavigationAgent3D

var _curr_interaction : InteractiveBase

var _scans = []
@export var DoorRoomScanDist = 1
@onready var _ray = $Area3D/RayCast3D

@export var Faces : Array[Texture]
@onready var icon = $CollisionShape3D/Sprite3D

func _ready():
	_control_window.hide()
	_control_window.title = DroneID
	_nav_agent.velocity_computed.connect(_on_velocity_calculated)
	_nav_agent.navigation_finished.connect(_on_navigation_finished)

	icon.texture = Faces.pick_random()
	icon.get_node('Label3D').text = DroneID


func _physics_process(_delta):
	var next_pos : Vector3 = _nav_agent.get_next_path_position()
	var next_v : Vector3 = global_position.direction_to(next_pos) * _nav_agent.max_speed
	if _nav_agent.avoidance_enabled:
		_nav_agent.set_velocity(next_v)
	else:
		_on_velocity_calculated(next_v)

	for s in _scans:
		var dist = global_position.distance_to(s.global_position)
		_ray.target_position = s.global_position - global_position
		_ray.force_raycast_update()
		if not _ray.is_colliding() or _ray.get_collider() == s:
			if s.is_in_group(Constants.DOOR_GROUP) and dist <= DoorRoomScanDist and s.is_open():
				for r in DoorManager.get_rooms_by_door(s):
					DoorManager.reveal_room(r, 1)
			else:
				DoorManager.reveal_model(s, 2)

	
func _on_velocity_calculated(safe_v : Vector3):
	velocity = safe_v
	move_and_slide()

func _on_navigation_finished():
	_nav_agent.avoidance_priority = .75
	move_complete.emit()


func move(pos:Vector3) -> bool:
	if _curr_interaction != null:
		var result = await _curr_interaction.interaction_end(self)
		if result:
			_curr_interaction = null
		else:
			return false

	_nav_agent.avoidance_priority = .5
	_nav_agent.set_target_position(pos)
	return true

func do_interaction(interaction:InteractiveBase) -> bool:
	if _curr_interaction != null:
		var r = await _curr_interaction.interaction_end(self)
		if r:
			if _curr_interaction == interaction:
				_curr_interaction = null
				return true
			_curr_interaction = null
		else:
			CommandManager.log_message(DroneID + ': Could not end interface with ' + _curr_interaction.Descriptor)
			return false

	var result = await interaction.interaction_start(self)
	if result:
		if not interaction.InteractOneShot:
			_curr_interaction = interaction
		return true

	return false

func destroy(send_alert=true):
	if send_alert:
		CommandManager.log_message('Lost connection with {0}'.format([DroneID]))
	queue_free()
	destroyed.emit()


func get_curr_room() -> Node3D:
	var regions = NavigationServer3D.map_get_regions(_nav_agent.get_navigation_map())
	for r in regions:
		if NavigationServer3D.region_owns_point(r, global_position):
			var oid = NavigationServer3D.region_get_owner_id(r)
			var node = instance_from_id(oid)
			return node
	
	printerr(self, ' could not identify current room')
	return null

func get_room_interactions() -> InteractiveBase:
	var room = get_curr_room()
	for n in room.get_children():
		if n is InteractiveBase and not n is ScannableFile:
			return n
	
	return null

func get_room_files() -> ScannableFile:
	var room = get_curr_room()
	for n in room.get_children():
		if n is ScannableFile:
			return n
	
	return null


func process_command(cmd:String, args:Array[String]):
	if cmd == 'ping' and DroneID in args:
		CommandManager.log_message(DroneID + ': pong')

	
	if cmd != DroneID:
		if get_parent().MaxDrones == 1:
			args.push_front(cmd)
		else:
			return null
	
	if args.size() == 0:
		return CommandWindow.CommandOutput.new(false, [DroneID + ': Input a command'])


	if args[0] == 'move':
		if args.size() < 2:
			return CommandWindow.CommandOutput.new(false, [DroneID + ': move requires 1 extra argument (DroneID move ID)'])
		if args[1][0] == Constants.ROOM_ID_PREFIX:
			if DoorManager.get_rooms().get(args[1]) and DoorManager.room_is_revealed(DoorManager.get_rooms().get(args[1]).get_rid()):
				move(DoorManager.get_rooms()[args[1]].global_position)
				return CommandWindow.CommandOutput.new(true, [])
			else:
				return CommandWindow.CommandOutput.new(false, ['Unrecognized id ' + args[1]])
		elif args[1][0] == Constants.DOOR_ID_PREFIX:
			if DoorManager.get_doors().get(args[1]) and DoorManager.get_doors()[args[1]].is_revealed():
				move(DoorManager.get_doors()[args[1]].global_position)
				return CommandWindow.CommandOutput.new(true, [])
			else:
				return CommandWindow.CommandOutput.new(false, ['Unrecognized id ' + args[1]])
		else:
			for d in get_tree().get_nodes_in_group(Constants.DRONE_GROUP):
				if d.DroneID == args[1]:
					move(d.global_position)
					return CommandWindow.CommandOutput.new(true, [])
			return CommandWindow.CommandOutput.new(false, ['Unrecognized id ' + args[1]])
	elif args[0] == 'interface':
		var i = get_room_interactions()
		if i == null:
			return CommandWindow.CommandOutput.new(false, [DroneID + ': Nothing in range to interface with'])

		move(i.global_position)
		await move_complete
		var result = await do_interaction(i)
		if result:
			return CommandWindow.CommandOutput.new(true, [])
		else:
			return CommandWindow.CommandOutput.new(false, [DroneID + ': Failed to interface with ' + i.Descriptor])
	elif args[0] == 'download':
		var i = get_room_files()
		if i == null:
			return CommandWindow.CommandOutput.new(false, [DroneID + ': No files found'])

		move(i.global_position)
		await move_complete
		var result = await do_interaction(i)
		if result:
			return CommandWindow.CommandOutput.new(true, [])
		else:
			return CommandWindow.CommandOutput.new(false, [DroneID + ': Failed to scan ' + i.Descriptor])
	elif args[0] == 'control':
		if _control_window.is_open():
			_control_window.close()
		else:
			_control_window.open()
		return CommandManager.CommandOutput.new(true, [])
	elif args[0] == 'explode':
		destroy(false)
		return CommandWindow.CommandOutput.new(true, ['{0}: Goodbye o/'.format([DroneID])])	
	elif args[0] == 'face':
		if args.size() < 2:
			return CommandWindow.CommandOutput.new(false, [DroneID + ': face requires 1 extra argument (DroneID face [face number])'])
		var i = args[1].to_int()
		if i >= Faces.size() or i < 0:
			return CommandWindow.CommandOutput.new(false, [DroneID + ': invalid face number'])
		icon.texture = Faces[i]
		return CommandWindow.CommandOutput.new(true)
	
	if get_parent().MaxDrones > 1:
		return CommandWindow.CommandOutput.new(false, [DroneID + ': Unknown command'])
	else:
		return null


func _on_area_3d_body_entered(body:Node3D) -> void:
	_scans.append(body)

func _on_area_3d_body_exited(body:Node3D) -> void:
	_scans.erase(body)
