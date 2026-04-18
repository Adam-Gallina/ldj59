extends Node3D
class_name DoorBase

@export var DoorID : String
@export var OpenOffset = 1.
@onready var _model : Node3D = $MeshInstance3D

@export var StartOpen = false
var _open = false

@onready var _nav_link : NavigationLink3D = $NavigationLink3D

func _ready() -> void:
	if StartOpen:
		open()
	else:
		close()

func is_open() -> bool:
	return _open

func open() -> bool:
	if not is_open():
		_model.position = Vector3.RIGHT * OpenOffset
		_open = true
		
	_nav_link.navigation_layers = 1<<1
	
	return true

func close() -> bool:
	if is_open():
		_model.position = Vector3.ZERO
		_open = false
		
	_nav_link.navigation_layers = 0

	return true
