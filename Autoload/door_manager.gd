extends Node

var _doors : Dictionary = {}
func get_doors() -> Dictionary: return _doors
var _rooms : Dictionary = {}
func get_rooms() -> Dictionary: return _rooms

func _init():
	add_to_group(Constants.COMMAND_GROUP)

func _ready():
	var doors = get_tree().get_nodes_in_group(Constants.DOOR_GROUP)
	for d in doors:
		if d is DoorBase:
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


func process_command(cmd:String, args:Array[String]):
	var succeeded = 0
	var output : Array[String] = []

	if cmd == 'open':
		for a in args:
			if _doors.get(a):
				if _doors[a].open():
					succeeded += 1
				else:
					output.append('{a} failed to open')
			else:
				output.append('Unrecognized door_id \'' + a + '\'')
	elif cmd == 'close':
		for a in args:
			if _doors.get(a):
				if _doors[a].close():
					succeeded += 1
				else:
					output.append('{a} failed to close')
			else:
				output.append('Unrecognized door_id \'' + a + '\'')
	else:
		if _doors.get(cmd):
			if _doors[cmd].is_open():
				if _doors[cmd].close():
					succeeded += 1
				else:
					output.append('{a} failed to close')
			else:
				if _doors[cmd].open():
					succeeded += 1
				else:
					output.append('{a} failed to open')
		else:
			return null
	
	return CommandWindow.CommandOutput.new(succeeded > 0, output)
