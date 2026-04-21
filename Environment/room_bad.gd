extends RoomBase

@export var Models : Array[MeshInstance3D]
@export var RevealDist = 3

func _ready():
	super()

	for m in Models: m.hide()

func _process(_delta):
	if !$Sprite3D.visible: return

	var d = get_tree().get_first_node_in_group(Constants.DRONE_GROUP)
	for m in Models:
		if m.visible: continue
		if m.global_position.distance_to(d.global_position) <= RevealDist:
			m.show()

func hide_model():
	super()

func reveal_model():
	super()