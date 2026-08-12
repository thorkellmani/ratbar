class_name BaseStatGroup extends Resource

signal stat_changed

func _get_min() -> float: return 0.0
func _get_max() -> float: return 1.0

func _clamp_value(value: float) -> float:
	return clampf(value, _get_min(), _get_max())
