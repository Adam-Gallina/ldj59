extends InteractiveBase


func interaction_start(_drone:DroneBase) -> bool:
	_active = not _active

	if _active:
		activated.emit()
		CommandManager.log_message('Generator powered on')
	else:
		CommandManager.log_message('Generator powered off')

	return true
	

func hide_model():
	super()
	$Sprite3D.hide()

func reveal_model():
	super()
	$Sprite3D.show()