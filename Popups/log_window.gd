extends PopupWindow
class_name LogWindow

@export var FileButtonScene : PackedScene
@export var FileWindowScene : PackedScene
@export var ImageWindowScene : PackedScene

@onready var _button_parent = $ScrollContainer/VBoxContainer

@export var DefaultFileX = 285
@export var DefaultFileY = 220
var _last_window : Window

func _ready() -> void:
	add_file('MISSION_BRIEFING.txt', 'res://Popups/Documents/mission_briefing.txt')
	add_file('M0NK3_COMMANDS.txt', 'res://Popups/Documents/basic_commands.txt')
	add_file('M0NK3_ADV.txt', 'res://Popups/Documents/advanced_commands.txt')
	add_file('gearbo.png', 'res://Icons/Images/Gear.png')

func add_file(filename, filepath):
	var b = FileButtonScene.instantiate()
	b.text = filename
	b.pressed.connect(open_file.bind(filename, filepath))
	_button_parent.add_child(b)


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
