extends Node3D
class_name DoorBase

@export var DoorID : String
@export var OpenOffset = 1.
@onready var _model : Node3D = get_node_or_null('%Model')
@onready var _label : Label3D = get_node_or_null('Label3D')

@export var StartOpen = false
var _open = false
var _locked = false

@export var CanScan = true

@onready var _nav_link : NavigationLink3D = $NavigationLink3D

@export var PowerSource : Node3D

@export var PoweredCol : Color
@export var UnpoweredCol : Color

func _ready() -> void:
	if StartOpen:
		open(true)
	else:
		close(true)

	if _label != null:
		_label.text = DoorID
		_label.rotation.y = -rotation.y

func is_open() -> bool:
	return _open

func is_active() -> bool:
	return PowerSource == null or PowerSource.is_active()


func _process(_delta):
	$Sprite3D2.modulate = PoweredCol if is_active() else UnpoweredCol
	$Label3D/Sprite3D.modulate = PoweredCol if is_active() else UnpoweredCol


func open(override_power=false) -> bool:
	if not is_active() and not override_power: return false

	if _locked: return false

	if not is_open():
		$CollisionShape3D.position = Vector3.RIGHT * OpenOffset
		_open = true
		
	_nav_link.navigation_layers = 1<<1
	
	return true

func close(override_power=false) -> bool:
	if not is_active() and not override_power: return false

	if _locked: return false
		
	if is_open():
		$CollisionShape3D.position = Vector3.ZERO
		_open = false
		
	_nav_link.navigation_layers = 0

	return true


func lock(override_power=false) -> bool:
	if not is_active() and not override_power: return false

	_locked = true
	return true

func unlock(override_power=false) -> bool:
	if not is_active() and not override_power: return false

	_locked = false
	return true


func hide_model():
	if _label != null:
		_label.hide()
	$Sprite3D2.hide()
	_model.layers = 0

func reveal_model():
	if _label != null:
		_label.show()
	$Sprite3D2.show()
	_model.layers = 1
