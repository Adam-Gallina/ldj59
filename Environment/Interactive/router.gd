extends Node3D

@export var RouterID : String
@export var PowerSource : Node3D

func is_revealed() -> bool:
	return get_node('%Model').layers > 0

func hide_model():
	get_node('%Model').layers = 0

func reveal_model():
	get_node('%Model').layers = 1
