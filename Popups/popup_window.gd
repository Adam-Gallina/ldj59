extends Window
class_name PopupWindow

func _ready() -> void:
	mouse_entered.connect(WindowManager._mouse_entered_window.bind(self))
	mouse_exited.connect(WindowManager._mouse_exited_window.bind(self))

func is_open() -> bool: return visible

func open():
	show()

func close():
	hide()