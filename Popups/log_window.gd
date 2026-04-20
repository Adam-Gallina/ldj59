extends PopupWindow
class_name LogWindow

signal message_received()
signal message_read()


@export var FileButtonScene : PackedScene
@export var FileWindowScene : PackedScene
@export var ImageWindowScene : PackedScene

@onready var _button_parent = $ScrollContainer/VBoxContainer

@export var DefaultFileX = 285
@export var DefaultFileY = 220
var _last_window : Window

func _ready() -> void:
	super()
	
	add_file('MISSION_BRIEFING.txt', 'res://Popups/Documents/mission_briefing.txt', false)

func add_file(filename, filepath, send_message=true):
	var b = FileButtonScene.instantiate()
	b.text = filename
	b.pressed.connect(open_file.bind(filename, filepath))
	_button_parent.add_child(b)

	if send_message:
		if is_open():
			message_read.emit()
		else:
			message_received.emit()


func open_file(filename:String, filepath:String):
	var w : PopupWindow
	if filepath.ends_with('.txt'):
		w = FileWindowScene.instantiate()
	elif filepath.ends_with('.png'):
		w = ImageWindowScene.instantiate()
	else:
		printerr('LogWindow: Unhandled filetype - ', filepath)
		return

	get_parent().add_child(w)
	w.set_file(filename, filepath)

	if _last_window != null:
		if (_last_window.position.x - DefaultFileX) % 20 == 0 and (_last_window.position.y - DefaultFileY) % 20 == 0:
			w.position = _last_window.position + Vector2i(20, 20)
	_last_window = w


func open():
	super()

	message_read.emit()
