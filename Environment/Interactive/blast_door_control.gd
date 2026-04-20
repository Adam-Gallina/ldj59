extends DoorBase

func _process(_delta):
	return
	
func hide_model():
	super()
	$Sprite3D3.hide()

func reveal_model():
	super()
	$Sprite3D3.show()