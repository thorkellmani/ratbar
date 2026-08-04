class_name Status extends BaseStatGroup

func _init() -> void:
	_min = 0
	_max = 100

@export var stress: float:
	set(value):
		stress = _clamp_value(value)
		stat_changed.emit()

@export var health: float:
	set(value):
		health = _clamp_value(value)
		stat_changed.emit()


@export var inebriation: float:
	set(value):
		inebriation = _clamp_value(value)
		stat_changed.emit()


@export var radicalization: float:
	set(value):
		radicalization = _clamp_value(value)
		stat_changed.emit()


@export var extra_stress: float:
	set(value):
		extra_stress = _clamp_value(value)
		stat_changed.emit()

func get_keys() -> Array[String]:
	return [
		"stress",
		"health",
		"inebriation",
		"radicalization",
		"extra_stress",
	]
