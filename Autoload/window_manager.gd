extends Node

var _curr_window = null

func _mouse_entered_window(window:PopupWindow):
    _curr_window = window

func _mouse_exited_window(window:PopupWindow):
    if window == _curr_window:
        _curr_window = null