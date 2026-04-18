extends Node3D
class_name InteractiveBase

@export var Descriptor = "Unnamed Object"

@export var InteractOneShot = false

@export var StartActive = false
@onready var _active : bool = StartActive
func is_active() -> bool: return _active

func interaction_start(drone:DroneBase) -> bool:
	print(drone, ' started')
	return true

func interaction_end(drone:DroneBase) -> bool:
	print(drone, ' ended')
	return true
