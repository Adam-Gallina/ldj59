extends PopupWindow

signal message_received()
signal message_read()

@onready var textbox : TextEdit = $TextEdit

@export var message_prefix = "]] "

func log_message(text:String):
	textbox.text += '\n\n' + message_prefix + text
	textbox.get_v_scroll_bar().value = textbox.get_v_scroll_bar().max_value

	if is_open():
		message_read.emit()
	else:
		message_received.emit()


func open():
	super()

	message_read.emit()
