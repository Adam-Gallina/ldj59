extends InteractiveBase
class_name ScannableFile

@export var filename : String
@export var filepath : String

@export var ScannedColor : Color

var _notif_elapsed = 0
@export var NotificationMaxSize : float = 1.35
@export var NotificationSpeed : float = .75

func _process(delta: float) -> void:
	if _active: return
	_notif_elapsed += delta

	var t = (1 + sin(_notif_elapsed * NotificationSpeed * (2 * PI))) / 2
	var s = 1 + (NotificationMaxSize - 1) * t
	$Sprite3D.scale = Vector3(s, s, s)



func interaction_start(_drone:DroneBase) -> bool:
	if _active: return true

	CommandManager.log_message('Downloaded ' + filename)

	DataWindow.add_file(filename, filepath)

	$Sprite3D.modulate = ScannedColor

	_active = true

	return true

func interaction_end(_drone:DroneBase) -> bool:
	return true

	
func hide_model():
	$Sprite3D.hide()

func reveal_model():
	$Sprite3D.show()