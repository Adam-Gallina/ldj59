extends Node

signal walls_loaded()

var _doors : Dictionary = {}
func get_doors() -> Dictionary: return _doors
var _rooms : Dictionary = {}
func get_rooms() -> Dictionary: return _rooms

## { room RID : [bordered walls] }
var _room_walls : Dictionary = {}
var _room_objects : Dictionary = {}
## { door : [bordered room RIDs] }
var _door_rooms : Dictionary = {}
func get_rooms_by_door(door):
	return _door_rooms.get(door)
## { room : [bordered door RIDs] }
var _room_doors : Dictionary = {}
func get_doors_by_room(room_rid):
	return _room_doors.get(room_rid)
var _revealed_rooms : Array = []
const ROOM_SEARCH_DIRS = [Vector3(1, 0, 1), Vector3(1, 0, -1), Vector3(-1, 0, -1), Vector3(-1, 0, 1)]

func _init():
	add_to_group(Constants.COMMAND_GROUP)

func _ready():
	var doors = get_tree().get_nodes_in_group(Constants.DOOR_GROUP)
	for d in doors:
		if d is DoorBase:
			if d.DoorID == '': continue
			
			if _doors.get(d.DoorID):
				printerr('DoorManager: Trying to store door with duplicate ID - ', d.DoorID, '. ', d, ' conflicts with ', _doors.get(d.DoorID))
			_doors[d.DoorID] = d
		else:
			printerr('DoorManager: Trying to add non-DoorBase to doors - ', d)
	
	var rooms = get_tree().get_nodes_in_group(Constants.ROOM_GROUP)
	for r in rooms:
		if r is RoomBase:
			if _rooms.get(r.RoomID):
				printerr('DoorManager: Trying to store room with duplicate ID - ', r.RoomID, '. ', r, ' conflicts with ', _rooms.get(r.RoomID))
			_rooms[r.RoomID] = r
		else:
			printerr('DoorManager: Trying to add non-DoorBase to doors - ', r)

	load_walls.call_deferred()

func load_walls():
	await NavigationServer3D.map_changed

	var walls = get_tree().get_nodes_in_group(Constants.WALL_GROUP)
	var m = NavigationServer3D.get_maps()[0]
	var regions = NavigationServer3D.map_get_regions(m)
	for r in regions:
		_room_walls[r] = []
		_room_objects[r] = []

	for w in walls:
		var model = w.get_node('%Model')
		hide_model(model)
		for d in ROOM_SEARCH_DIRS:
			for r in regions:
				if NavigationServer3D.region_owns_point(r, w.global_position + d):
					if model not in _room_walls[r]:
						_room_walls[r].append(model)
					break
					
	_room_doors = {}
	for r in regions:
		_room_doors[r] = []

	var doors = get_tree().get_nodes_in_group(Constants.DOOR_GROUP)
	for door in doors:
		hide_model(door)
		_door_rooms[door] = []

		var dirs = [door.basis.z, -door.basis.z]
		for d in dirs:
			for r in regions:
				if NavigationServer3D.region_owns_point(r, door.global_position + d):
					_room_doors[r].append(door)
					if door not in _room_walls[r]:
						_room_walls[r].append(door)
						_door_rooms[door].append(r)
					break
					
	var rooms = get_tree().get_nodes_in_group(Constants.ROOM_GROUP)
	for room in rooms:
		var rid = room.get_rid()
		_room_walls[rid].append(room)
		hide_model(room)
		for n in room.get_children():
			_room_objects[rid].append(n)
			hide_model(n)


	walls_loaded.emit()


func reveal_room(rid, full_reveal=2):
	for w in _room_walls[rid]:
		reveal_model(w, full_reveal)
	if full_reveal > 0:
		for o in _room_objects[rid]:
			if full_reveal == 1 and o.name.to_lower().contains('floor'):
				reveal_model(o, full_reveal)
			elif full_reveal == 2:
				reveal_model(o)
	if rid not in _revealed_rooms:
		_revealed_rooms.append(rid)

func room_is_revealed(rid):
	return rid in _revealed_rooms

func hide_model(model):
	if model is VisualInstance3D:
		model.layers = 0
	else:
		model.hide_model()

func reveal_model(model, _full_reveal=2):
	if model is VisualInstance3D:
		model.layers |= 1
	elif model.has_method('reveal_model'):
		model.reveal_model()

func model_is_revealed(model):
	return model.layers > 0


func process_command(cmd:String, args:Array[String]):
	var succeeded = 0
	var output : Array[String] = []

	if cmd == 'scan':
		if args.size() == 0:
			return CommandWindow.CommandOutput.new(false, ['scan requires at least one argument (scan doorID[s])'])
		for a in args:
			if _doors.get(a) and model_is_revealed(_doors[a].get_node('%Model')):
				if _doors[a].is_active() or _doors[a].is_open():
					if not _doors[a].CanScan:
						output.append('{0} did not respond'.format([a]))
						continue

					for r in _door_rooms[_doors[a]]:
						reveal_room(r, 0)
					succeeded += 1
				else:
					output.append('{0} failed to scan'.format([a]))
			else:
				output.append('Unrecognized door_id \'' + a + '\'')
	elif cmd == 'open':
		if args.size() == 0:
			return CommandWindow.CommandOutput.new(false, ['open requires at least one argument (open doorID[s])'])
		for a in args:
			if _doors.get(a):
				if _doors[a].open():
					succeeded += 1
					for r in _door_rooms[_doors[a]]:
						reveal_room(r, 0)
				else:
					output.append('{0} failed to open'.format([a]))
			else:
				output.append('Unrecognized door_id \'' + a + '\'')
	elif cmd == 'close':
		if args.size() == 0:
			return CommandWindow.CommandOutput.new(false, ['close requires at least one argument (close doorID[s]'])
		for a in args:
			if _doors.get(a):
				if _doors[a].close():
					succeeded += 1
				else:
					output.append('{0} failed to close'.format([a]))
			else:
				output.append('Unrecognized door_id \'' + a + '\'')
	elif cmd == 'lock':
		if args.size() == 0:
			return CommandWindow.CommandOutput.new(false, ['lock requires at least one argument (lock doorID[s]'])
		for a in args:
			if _doors.get(a):
				if _doors[a].lock():
					succeeded += 1
				else:
					output.append('{0} failed to lock'.format([a]))
			else:
				output.append('Unrecognized door_id \'' + a + '\'')
	elif cmd == 'unlock':
		if args.size() == 0:
			return CommandWindow.CommandOutput.new(false, ['unlock requires at least one argument (unlock doorID[s]'])
		for a in args:
			if _doors.get(a):
				if _doors[a].unlock():
					succeeded += 1
				else:
					output.append('{0} failed to lock'.format([a]))
			else:
				output.append('Unrecognized door_id \'' + a + '\'')
	elif cmd == 'doors':
		for r in _room_walls.keys():
			reveal_room(r, 2)
		return CommandWindow.CommandOutput.new(true)
	elif _doors.get(cmd):
		if _doors[cmd].is_open():
			if _doors[cmd].close():
				succeeded += 1
			else:
				output.append('{0} failed to close'.format([cmd]))
		else:
			if _doors[cmd].open():
				succeeded += 1
				for r in _door_rooms[_doors[cmd]]:
					reveal_room(r, 0)
			else:
				output.append('{0} failed to open'.format([cmd]))
	else:
		return null
	
	return CommandWindow.CommandOutput.new(succeeded > 0, output)
