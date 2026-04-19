extends CharacterBody3D

signal move_complete()

@onready var _nav_agent : NavigationAgent3D = $NavigationAgent3D
var _curr_room_rid

@export var BaseChanceToStay = .9
@export var RecursiveChanceToStay = .85
@onready var _curr_chance = BaseChanceToStay

@export var MoveTimeout = 10
@export var MoveDelayMin = 0
@export var MoveDelayMax = 2
var _new_room = false

var _drone_targets = []
@export var AttackRange = 1.5

@export var VisibleRange = 5.0

@onready var model = get_node('%Model')


func _ready() -> void:
	_nav_agent.velocity_computed.connect(_on_velocity_calculated)
	_nav_agent.navigation_finished.connect(_on_navigation_finished)

	identify_room.call_deferred()

func identify_room():
	await DoorManager.walls_loaded
	
	var regions = NavigationServer3D.map_get_regions(_nav_agent.get_navigation_map())
	for r in regions:
		if NavigationServer3D.region_owns_point(r, global_position):
			_curr_room_rid = r
			break

	start_random_move()

	

func _physics_process(_delta):
	var next_pos : Vector3 = _nav_agent.get_next_path_position()
	var next_v : Vector3 = global_position.direction_to(next_pos) * _nav_agent.max_speed
	if _nav_agent.avoidance_enabled:
		_nav_agent.set_velocity(next_v)
	else:
		_on_velocity_calculated(next_v)

	for d in _drone_targets:
		var dist = global_position.distance_to(d.global_position)
		if dist <= AttackRange:
			d.destroy()
		if dist <= VisibleRange:
			$RayCast3D.target_position = d.global_position - global_position
			$RayCast3D.force_raycast_update()
			if $RayCast3D.is_colliding():
				model.layers = 0b0010
			else:
				model.layers = 0b0011

	if _drone_targets.size() == 0:
		model.layers = 0b0010

	
func _on_velocity_calculated(safe_v : Vector3):
	velocity = safe_v
	move_and_slide()

func _on_navigation_finished():
	_nav_agent.avoidance_priority = .75
	move_complete.emit()

	if _new_room:
		$MoveTimer.start(randf_range(MoveDelayMax * 2, MoveDelayMax * 3))
		_new_room = false
	else:
		$MoveTimer.start(randf_range(MoveDelayMin, MoveDelayMax))
	
	
func move(pos:Vector3) -> bool:
	_nav_agent.avoidance_priority = .6
	_nav_agent.set_target_position(pos)
	$MoveTimer.start(MoveTimeout)
	return true


func start_random_move():
	for d in _drone_targets:
		if start_attack_move(d):
			return

	move(get_random_pos())

func get_random_pos():
	if randf() > _curr_chance:
		_curr_chance *= RecursiveChanceToStay
	else:
		_curr_chance = BaseChanceToStay
		var doors = DoorManager.get_doors_by_room(_curr_room_rid)
		if doors == null:
			var oid = NavigationServer3D.region_get_owner_id(_curr_room_rid)
			var node = instance_from_id(oid)
			printerr(name, ' currently in room with no doors: ', node)
		else:
			var open_doors = []
			for d in doors:
				if d.is_open():
					open_doors.append(d)

			if open_doors.size() > 0:
				var d = open_doors.pick_random()
				var rooms = DoorManager.get_rooms_by_door(d)
				if rooms.size() == 2:
					_curr_room_rid = rooms[1] if rooms[0] == _curr_room_rid else rooms[0]
					_new_room = true
				else:
					printerr(name, ' found door without exactly two rooms: ', d, ' ', rooms)

	return NavigationServer3D.region_get_random_point(_curr_room_rid, _nav_agent.navigation_layers, true)

func start_attack_move(target:Node3D) -> bool:
	var _last_target = _nav_agent.target_position
	_nav_agent.set_target_position(target.global_position)
	if _nav_agent.get_final_position().distance_to(target.global_position) > AttackRange:
		_nav_agent.set_target_position(_last_target)
		return false

	move(target.global_position)
	return true


func _on_body_entered(body: Node3D) -> void:
	_drone_targets.append(body)

func _on_body_exited(body: Node3D) -> void:
	_drone_targets.erase(body)
