class_name ViceFields extends BaseStatGroup

@export var smoking: float:
	set(value):
		smoking = _clamp_value(value)
		stat_changed.emit()

@export var drinking: float:
	set(value):
		drinking = _clamp_value(value)
		stat_changed.emit()


@export var drugs: float:
	set(value):
		drugs = _clamp_value(value)
		stat_changed.emit()


@export var sex: float:
	set(value):
		sex = _clamp_value(value)
		stat_changed.emit()


@export var gambling: float:
	set(value):
		gambling = _clamp_value(value)
		stat_changed.emit()

@export var fighting: float:
	set(value):
		fighting = _clamp_value(value)
		stat_changed.emit()

func get_keys() -> Array[String]:
	return [
		"smoking",
		"drinking",
		"drugs",
		"sex",
		"gambling",
		"fighting",
	]
