class_name NeedFields extends BaseStatGroup

@export var nutrition: float:
	set(value):
		nutrition = _clamp_value(value)
		stat_changed.emit()

@export var energy: float:
	set(value):
		energy = _clamp_value(value)
		stat_changed.emit()


@export var stimulation: float:
	set(value):
		stimulation = _clamp_value(value)
		stat_changed.emit()


@export var social: float:
	set(value):
		social = _clamp_value(value)
		stat_changed.emit()


@export var vice_satisfaction: float:
	set(value):
		vice_satisfaction = _clamp_value(value)
		stat_changed.emit()


func get_keys() -> Array[String]:
	return [
		"nutrition",
		"energy",
		"stimulation",
		"social",
		"vice_satisfaction",
	]
