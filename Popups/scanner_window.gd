extends PopupWindow

@onready var _frequency_label = $Control/TextureRect2/FrequencyLabel
@onready var _frequency : Knob = $Control/TextureRect2/FrequencyKnob
@onready var _amplitude_label = $Control/TextureRect3/AmplitudeLabel
@onready var _amplitude : Knob = $Control/TextureRect3/AmplitudeKnob
@onready var _wavelength_label = $Control/TextureRect4/WavelengthLabel
@onready var _wavelength : Knob = $Control/TextureRect4/WavelengthKnob

@onready var _wave_display : Line2D = $Line2D
@export var WavePoints = 72
@onready var _wave_start : Node2D = $WaveStart
@onready var _wave_end : Node2D = $WaveEnd
@onready var _wave_size : float = _wave_end.global_position.x - _wave_start.global_position.x
@onready var _wave_point_delta : float = _wave_size / WavePoints
@export var WaveEdgeLength : float = 10.

@export var ScanFrequency = 1.
var _next_scan : float = 0
var _drone_scanners : Array[DroneScan] = []
@export var ScannerEffects : Array[Node3D] = []
@export var ScanOffset = 3.

var _active = false
var _t = 0

func _ready():
	_on_frequency_knob_value_changed(_frequency.Value)
	_on_amplitude_knob_value_changed(_amplitude.Value)
	_on_wavelength_knob_value_changed(_wavelength.Value)


func _process(delta: float) -> void:
	if not _active: return

	var f = _frequency.Value
	var a = _amplitude.Value
	var w = _wavelength.Value

	var points : Array[Vector2] = []

	_t += delta * f
	for i in range(WavePoints):
		var x = i * _wave_point_delta
		var y = (a/10.) * sin((x + _t) / (w / 10.))
		points.append(_wave_start.global_position + Vector2(x, y))

	_wave_display.points = points


	var scan_targets = get_tree().get_nodes_in_group(Constants.SCANNABLE_GROUP)
	var best : Scannable = null
	var best_score = 0
	for s in scan_targets:
		if s is not Scannable:
			printerr('Trying to scan non-scannable ', s)
			continue

		var score = s.similarity(f, a, w)
		if score > best_score:
			best = s
			best_score = score

	_next_scan -= delta
	if _next_scan <= 0:
		_next_scan = ScanFrequency

		var hit : Array[DroneBase] = []
		for d in _drone_scanners:
			if d.drone == null or d.drone.is_queued_for_deletion(): continue

			if d.try_scan(best, best_score):
				hit.append(d.drone)
			elif d.fails > 3:
				ScannerEffects[_drone_scanners.find(d)].clear()


		for i in range(hit.size()):
			ScannerEffects[i].do_pulse(hit[i], best, ScanOffset, hit)


func start_scanner():
	_drone_scanners = []
	for d in get_tree().get_nodes_in_group(Constants.DRONE_GROUP):
		_drone_scanners.append(DroneScan.new(d))

	_active = true

func stop_scanner():
	for s in ScannerEffects:
		s.clear()
	_active = false

func open():
	super()
	start_scanner()

func close():
	stop_scanner()
	super()


func _on_frequency_knob_value_changed(new_value:int) -> void:
	_frequency_label.text = 'FREQ: {0}'.format([new_value])

func _on_amplitude_knob_value_changed(new_value:int) -> void:
	_amplitude_label.text = 'AMP: {0}'.format([new_value])

func _on_wavelength_knob_value_changed(new_value:int) -> void:
	_wavelength_label.text = 'WAVE: {0}'.format([new_value])


class DroneScan:
	var drone : DroneBase
	var curr_scan_target : Scannable = null
	var fails = 0

	func _init(_drone:DroneBase):
		drone = _drone

	func try_scan(target:Scannable, chance:float) -> bool:
		var r = randf()
		# Boost chance of success if target already scanned
		if target == curr_scan_target:
			r *= .5

		if r <= chance: 
			fails = 0
			curr_scan_target = target
			return true

		fails += 1
		return false
