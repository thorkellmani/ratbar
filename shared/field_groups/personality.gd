class_name PersonalityFields extends BaseStatGroup

@export var greed: float:
	set(value):
		greed = _clamp_value(value)
		stat_changed.emit()

@export var temper: float:
	set(value):
		temper = _clamp_value(value)
		stat_changed.emit()

@export var socialness: float:
	set(value):
		socialness = _clamp_value(value)
		stat_changed.emit()

@export var ambition: float:
	set(value):
		ambition = _clamp_value(value)
		stat_changed.emit()

@export var laziness: float:
	set(value):
		laziness = _clamp_value(value)
		stat_changed.emit()


func get_keys() -> Array[String]:
	return [
		"greed",
		"temper",
		"socialness",
		"ambition",
		"laziness",
	]
