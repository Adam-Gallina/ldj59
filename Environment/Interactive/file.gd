extends InteractiveBase
class_name ScannableFile

@export var filename : String
@export var filepath : String

@export var ScannedColor : Color

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