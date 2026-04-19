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
    if not _drone_disabled:
        _drone_disabled = true

        for z in ScanZones:
            z.monitoring = false

        var d = DroneScene.instantiate()
        d.DroneID = 'x7'
        interaction_end(d)
        d.DroneID = DroneID

        get_tree().root.get_node('Map').add_child(d)
        d.global_position = FakeDrone.global_position
        FakeDrone.hide()

        return true

    
    CommandManager.log_message('Server: User {0} connected'.format([drone.DroneID]))
    return super(drone)

func interaction_end(drone:DroneBase) -> bool:
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
    FakeDrone.show()

func hide_model():
    super()
    FakeDrone.hide()


func _on_body_entered(body:Node3D, zone:int):
    _tracked_body = body
    _zone = zone
    _last_tracked_pos = Vector3.ZERO
    
func _on_body_exited(_body:Node3D, _z:int):
    _tracked_body = null