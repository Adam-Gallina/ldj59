extends Node3D

@onready var _command_window : CommandWindow = $CommandWindow

func _ready():
    _command_window.close()


func _on_cmd_pressed():
    if _command_window.is_open():
        _command_window.close()
    else:
        _command_window.open()
