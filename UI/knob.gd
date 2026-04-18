extends Sprite2D
class_name Knob

signal value_changed(new_value:int)
signal value_set(new_value:int)

@export var MinValue = 0
@export var MaxValue = 100
@export var Value : int = 0
var _value_delta
@export var ChangeSpeed = 10.
@export var AllowWrap = false

@export var MinRotation = 0
@export var MaxRotation = 330

var _mouse_hovered = false
var _mouse_grabbed = false
var _last_mouse_pos = Vector2.ZERO

func _ready() -> void:
	set_value(Value)


func _process(delta):
	if _mouse_hovered and Input.is_action_just_pressed('select'):
		_mouse_grabbed = true
		_value_delta = Value
		_last_mouse_pos = Vector2.ZERO
	if Input.is_action_just_released('select'):
		_mouse_grabbed = false
		value_set.emit(Value)
	
	if _mouse_grabbed:
		var mp = get_viewport().get_mouse_position()

		if _last_mouse_pos != Vector2.ZERO:
			var dir = mp - _last_mouse_pos
			_value_delta += dir.x * ChangeSpeed * delta

			if AllowWrap:
				if _value_delta <= MinValue:
					_value_delta += (MaxValue - MinValue)
				elif _value_delta > MaxValue:
					_value_delta -= (MaxValue - MinValue)
			else:
				_value_delta = clamp(_value_delta, MinValue, MaxValue)

			set_value(round(_value_delta))

		_last_mouse_pos = mp

func set_value(new_value):
	if new_value != Value:
		value_changed.emit(new_value)

	Value = new_value
	var t = float(Value - MinValue) / (MaxValue - MinValue)
	rotation = deg_to_rad(MinRotation + (MaxRotation - MinRotation) * t)


func _on_mouse_entered() -> void:
	_mouse_hovered = true

func _on_mouse_exited() -> void:
	_mouse_hovered = false
