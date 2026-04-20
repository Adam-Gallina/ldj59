extends InteractiveBase

@export var ScanZones : Array[Area3D]
@export var ScanDoors : Array[Node3D]
var _tracked_body : Node3D
var _last_tracked_pos : Vector3 = Vector3.ZERO
var _zone : int

var _drone_disabled = false

@export var DroneScene : PackedScene
@export var DroneID : String
@export var FakeDrone : Node3D

func interaction_start(drone:DroneBase) -> bool:
	#if not _drone_disabled:
	#	_drone_disabled = true

	for z in ScanZones:
		z.monitoring = false

	#	get_tree().root.get_node('Map').MaxDrones += 1
	#	var d = get_tree().root.get_node('Map').spawn_drone('x7', FakeDrone.global_position)
	#	await interaction_end(d)
	#	d.DroneID = DroneID

	#	FakeDrone.hide()

	#	return true

	
	if drone != null:
		CommandManager.log_message('Server: User {0} connected'.format([drone.DroneID]))
	return await super(drone)

func interaction_end(drone:DroneBase) -> bool:
	await get_tree().process_frame
	if drone != null:
		CommandManager.log_message('Server: User {0} disconnected'.format([drone.DroneID]))
	return true

func _process(_delta: float) -> void:
	if _tracked_body != null:
		if _last_tracked_pos != Vector3.ZERO:
			if _last_tracked_pos.distance_to(_tracked_body.global_position) > 0:
				ScanDoors[_zone].close()
		_last_tracked_pos = _tracked_body.global_position


func reveal_model():
	super()
	#FakeDrone.show()
	$Sprite3D.show()

func hide_model():
	super()
	#FakeDrone.hide()
	$Sprite3D.hide()


func _on_body_entered(body:Node3D, zone:int):
	_tracked_body = body
	_zone = zone
	_last_tracked_pos = Vector3.ZERO
	
func _on_body_exited(_body:Node3D, _z:int):
	_tracked_body = null



func process_command(cmd:String, _args:Array[String]):
	if not is_active(): return null

	if cmd == 'routers':
		var routers = get_tree().root.get_node('Map/RadarWindow').Routers
		var out : Array[String] = []
		for r in routers:
			var status = 'Online' if r.PowerSource == null or r.PowerSource.is_active() else 'Offline'
			out.append('{0}\t| {1}'.format([r.RouterID, status]))
		return CommandManager.CommandOutput.new(true, out)

	return null
