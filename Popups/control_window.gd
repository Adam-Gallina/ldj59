extends PopupWindow

@onready var _drone : DroneBase = get_parent()

var _curr_dir : Vector3 = Vector3.ZERO

func _process(_delta: float) -> void:
    if is_open() and _curr_dir != Vector3.ZERO:
        _drone.move(_drone.global_position + _curr_dir * .5)

func _button_pressed(dir:Vector3):
    _curr_dir = dir

func _button_released(dir:Vector3):
    if dir == _curr_dir:
        _curr_dir = Vector3.ZERO