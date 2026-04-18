extends Node3D
class_name InteractiveBase

@export var Descriptor = "Unnamed Object"

func interaction_start(drone:DroneBase) -> bool:
    print(drone, ' started')
    return true

func interaction_end(drone:DroneBase) -> bool:
    print(drone, ' ended')
    return true
