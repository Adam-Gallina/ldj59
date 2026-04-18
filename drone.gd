extends CharacterBody3D
class_name DroneBase

signal move_complete()

@export var DroneID : String

@onready var _nav_agent : NavigationAgent3D = $NavigationAgent3D

var _curr_interaction : InteractiveBase

func _ready():
	_nav_agent.velocity_computed.connect(_on_velocity_calculated)
	_nav_agent.navigation_finished.connect(_on_navigation_finished)


func _physics_process(_delta):
	var next_pos : Vector3 = _nav_agent.get_next_path_position()
	var next_v : Vector3 = global_position.direction_to(next_pos) * _nav_agent.max_speed
	if _nav_agent.avoidance_enabled:
		_nav_agent.set_velocity(next_v)
	else:
		_on_velocity_calculated(next_v)
	
func _on_velocity_calculated(safe_v : Vector3):
	velocity = safe_v
	move_and_slide()

func _on_navigation_finished():
	_nav_agent.avoidance_priority = .75
	move_complete.emit()


func move(pos:Vector3) -> bool:
	if _curr_interaction != null:
		if _curr_interaction.interaction_end(self):
			print(DroneID + ': Ending interface')
			_curr_interaction = null
		else:
			print(DroneID + ': Could not end interface with ' + _curr_interaction.Descriptor)
			return false

	_nav_agent.avoidance_priority = .5
	_nav_agent.set_target_position(pos)
	return true

func do_interaction(interaction:InteractiveBase) -> bool:
	if _curr_interaction != null:
		if _curr_interaction.interaction_end(self):
			print(DroneID + ': Ending interface')
			_curr_interaction = null
		else:
			print(DroneID + ': Could not end interface with ' + _curr_interaction.Descriptor)
			return false

	if interaction.interaction_start(self):
		if not interaction.InteractOneShot:
			_curr_interaction = interaction
		return true

	return false


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
		if n is InteractiveBase:
			return n

	return null


func process_command(cmd:String, args:Array[String]):
	if cmd == 'ping' and DroneID in args:
		CommandManager.log_message(DroneID + ': pong')

	if cmd != DroneID: return null

	if args[0] == 'move':
		if args[1][0] == Constants.DRONE_ID_PREFIX:
			printerr('Do this already')
		elif args[1][0] == Constants.ROOM_ID_PREFIX:
			if DoorManager.get_rooms().get(args[1]) and DoorManager.room_is_revealed(DoorManager.get_rooms().get(args[1]).get_rid()):
				move(DoorManager.get_rooms()[args[1]].global_position)
				return CommandWindow.CommandOutput.new(true, [])
			else:
				return CommandWindow.CommandOutput.new(false, ['Unrecognized id ' + args[1]])
		elif args[1][0] == Constants.DOOR_ID_PREFIX:
			if DoorManager.get_doors().get(args[1]):
				move(DoorManager.get_doors()[args[1]].global_position)
				return CommandWindow.CommandOutput.new(true, [])
			else:
				return CommandWindow.CommandOutput.new(false, ['Unrecognized id ' + args[1]])
	elif args[0] == 'interface':
		var i = get_room_interactions()
		if i == null:
			return CommandWindow.CommandOutput.new(false, [DroneID + ': Nothing to interface with'])

		move(i.global_position)
		await move_complete
		if do_interaction(i):
			return CommandWindow.CommandOutput.new(true, [DroneID + ': Started interface with ' + i.Descriptor])
		else:
			return CommandWindow.CommandOutput.new(false, [DroneID + ': Failed to interface with ' + i.Descriptor])
