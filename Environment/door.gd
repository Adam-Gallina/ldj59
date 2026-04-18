extends Node3D
class_name DoorBase

@export var DoorID : String
@export var OpenOffset = 1.
@onready var _model : Node3D = get_node('%Model')

@export var StartOpen = false
var _open = false

@onready var _nav_link : NavigationLink3D = $NavigationLink3D

@export var PowerSource : Node3D

func _ready() -> void:
	if StartOpen:
		open(true)
	else:
		close(true)

func is_open() -> bool:
	return _open

func is_active() -> bool:
	return PowerSource == null or PowerSource.is_active()

func open(override_power=false) -> bool:
	if not is_active() and not override_power: return false

	if not is_open():
		_model.position = Vector3.RIGHT * OpenOffset
		_open = true
		
	_nav_link.navigation_layers = 1<<1
	
	return true

func close(override_power=false) -> bool:
	if not is_active() and not override_power: return false
		
	if is_open():
		_model.position = Vector3.ZERO
		_open = false
		
	_nav_link.navigation_layers = 0

	return true
