extends Window
class_name PopupWindow


func is_open() -> bool: return visible

func open():
	show()

func close():
	hide()