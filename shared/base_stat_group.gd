class_name BaseStatGroup extends Resource

signal stat_changed

func _get_min() -> float: return 0.0
func _get_max() -> float: return 1.0

static func get_keys() -> Array[String]: return []

func get_normalized_value(key: String) -> float:
	assert(key in get_keys(), "unknown key: " + key)
	return (get(key) - _get_min()) / (_get_max() - _get_min())

func _clamp_value(value: float) -> float:
	return clampf(value, _get_min(), _get_max())
