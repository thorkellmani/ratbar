class_name LocationPull extends BaseStatGroup

func _init() -> void:
	_min = -3
	_max = 3

@export var nutrition: float:
	set(value):
		nutrition = _clamp_value(value)
		stat_changed.emit()
