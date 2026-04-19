extends Node3D
class_name InteractiveBase

signal activated()

@export var Descriptor = "Unnamed Object"

@export var InteractOneShot = false

@export var StartActive = false
@onready var _active : bool = StartActive
func is_active() -> bool: return _active

func interaction_start(drone:DroneBase) -> bool:
	print(drone, ' started')

	if InteractOneShot:
		_active = not _active
	else:
		_active = true

	if _active:
		activated.emit()

	return true

func interaction_end(drone:DroneBase) -> bool:
	print(drone, ' ended')

	if not InteractOneShot:
		_active = false

	return true


func hide_model():
	get_node('%Model').layers = 0

func reveal_model():
	get_node('%Model').layers = 1