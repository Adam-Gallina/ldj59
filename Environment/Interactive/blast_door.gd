extends InteractiveBase

@export var ScannedRoom : RoomBase
@export var ScannedEnemy : Node3D

@export var Door : DoorBase

func interaction_start(_drone:DroneBase) -> bool:
	DoorManager.reveal_room(ScannedRoom.get_rid(), 0)
	
	var m = ScannedEnemy.get_node('NavigationAgent3D').get_navigation_map()
	var _curr_room_rid = NavigationServer3D.map_get_closest_point_owner(m, ScannedEnemy.global_position)

	if _curr_room_rid == ScannedRoom.get_rid():
		CommandManager.log_message('Subject loose in lab. Cannot open primary door')
		return true

	var doors = DoorManager.get_doors_by_room(_curr_room_rid)
	for d in doors:
		if d.is_open():
			CommandManager.log_message('Subject loose in lab. Cannot open primary door')
			return true

	activated.emit()

	if Door.is_open():
		Door.close(true)

		CommandManager.log_message('Closing lab door.')
		await get_tree().create_timer(.33).timeout
		CommandManager.log_message('Closing lab door..')
		await get_tree().create_timer(.33).timeout
		CommandManager.log_message('Closing lab door...')
		await get_tree().create_timer(.33).timeout
		CommandManager.log_message('Thank you for visiting the lab :)')
	else:
		Door.open(true)

		DoorManager.reveal_room(ScannedRoom.get_rid(), 1)
		CommandManager.log_message('Opening lab door.')
		await get_tree().create_timer(.33).timeout
		CommandManager.log_message('Opening lab door..')
		await get_tree().create_timer(.33).timeout
		CommandManager.log_message('Opening lab door...')
		await get_tree().create_timer(.33).timeout
		CommandManager.log_message('Welcome to the lab :)')

	return true

func hide_model():
	super()
	$Sprite3D.hide()

func reveal_model():
	super()
	$Sprite3D.show()