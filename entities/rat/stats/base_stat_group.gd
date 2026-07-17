class_name BaseStatGroup extends Resource

signal stat_changed

var _min: float
var _max: float

func _clamp_value(value: float) -> float:
	return clampf(value, _min, _max)
