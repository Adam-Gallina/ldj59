extends InteractiveBase

signal boom

@onready var ComputerWindow : PopupWindow = $Window
@onready var password_window : Control = $Window/Password
@onready var password_prompt : Label = $Window/Password/Label2
@onready var password_input : LineEdit = $Window/Password/LineEdit

@onready var download_window : Control = $Window/Download
@onready var download_button : Control = $Window/Download/Button2

@onready var error_popup : Control = $Window/Download/TextureRect
var _show_error = false
var _t = 0
@export var FlashSpeedOn = .75
@export var FlashSpeedOff = .5


func interaction_start(drone:DroneBase) -> bool:
	ComputerWindow.open()
	return await super(drone)

func interaction_end(drone:DroneBase) -> bool:
	ComputerWindow.close()
	return await super(drone)


func _process(delta: float) -> void:
	if not _show_error: return

	_t -= delta

	if _t <= 0:
		if error_popup.visible:
			error_popup.hide()
			_t = FlashSpeedOff
		else:
			error_popup.show()
			_t = FlashSpeedOn


func hide_model():
	super()
	$Sprite3D.hide()

func reveal_model():
	super()
	$Sprite3D.show()


func _on_button_pressed() -> void:
	if password_input.text == '1234':
		password_window.hide()
		download_window.show()
	else:
		password_input.text = ''
		password_prompt.text = 'WRONG'
		password_prompt.modulate = Color.RED
		await get_tree().create_timer(1.0).timeout
		password_prompt.text = 'Enter password to continue'
		password_prompt.modulate = Color.WHITE



func _on_check_box_toggled(toggled_on:bool) -> void:
	download_button.disabled = not toggled_on


func _on_button_2_pressed() -> void:
	_show_error = true
	boom.emit()


func close() -> void:
	ComputerWindow.close()
