extends PopupWindow

signal message_received()
signal message_read()

@onready var textbox : TextEdit = $TextEdit
@onready var typing_hint : Label = $TypingLabel
var t = .5

@export var message_prefix = "]] "

func log_message(text:String):
	textbox.text += '\n\n' + message_prefix + text
	textbox.get_v_scroll_bar().value = textbox.get_v_scroll_bar().max_value

	if is_open():
		message_read.emit()
	else:
		message_received.emit()


func _process(delta: float) -> void:
	if typing_hint.visible:
		t -= delta
		if t <= 0:
			t = .5
			if typing_hint.text.ends_with('...'):
				typing_hint.text = 'Tony is typing.'
			elif typing_hint.text.ends_with('..'):
				typing_hint.text = 'Tony is typing...'
			elif typing_hint.text.ends_with('.'):
				typing_hint.text = 'Tony is typing..'
		


func set_typing(typing):
	typing_hint.visible = typing
	


func open():
	super()

	message_read.emit()
