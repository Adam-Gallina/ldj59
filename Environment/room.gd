extends NavigationRegion3D
class_name RoomBase

@export var RoomID : String

func _ready() -> void:
	$Sprite3D/Label3D.text = RoomID

	

func hide_model():
	$Sprite3D.hide()

func reveal_model():
	$Sprite3D.show()