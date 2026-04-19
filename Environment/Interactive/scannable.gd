extends Node
class_name Scannable

const FREQUENCY_RANGE = 70.
@export_range(10.,150.) var Frequency : float
const AMPLITUDE_RANGE = 60.
@export_range(30., 150.) var Amplitude : float
const WAVELENGTH_RANGE = 65.
@export_range(20., 150.) var Wavelength : float


## Less similar (0, 1) More similar
func similarity(f:float, a:float, w:float) -> float:
    var fscore = 1 - abs(Frequency - f) / FREQUENCY_RANGE
    if fscore < 0: fscore = 1 / FREQUENCY_RANGE
    
    var ascore = 1 - abs(Amplitude - a) / AMPLITUDE_RANGE
    if ascore < 0: ascore = 1 / AMPLITUDE_RANGE
    
    var wscore = 1 - abs(Wavelength - w) / WAVELENGTH_RANGE
    if wscore < 0: wscore = 1 / WAVELENGTH_RANGE

    return fscore * ascore * wscore
