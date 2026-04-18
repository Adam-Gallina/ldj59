extends CharacterBody3D

@export var DroneID : String

@onready var _nav_agent : NavigationAgent3D = $NavigationAgent3D

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


func move(pos:Vector3):
	_nav_agent.avoidance_priority = .5
	_nav_agent.set_target_position(pos)


func process_command(cmd:String, args:Array[String]):
	if cmd == 'move':
		if args[0] != DroneID:
			return null

		if args[1][0] == Constants.DRONE_ID_PREFIX:
			printerr('Do this already')
		elif args[1][0] == Constants.ROOM_ID_PREFIX:
			if DoorManager.get_rooms().get(args[1]):
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
			
