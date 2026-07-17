class_name RatJobSkills extends BaseStatGroup

func _init() -> void:
	_min = 0
	_max = 10

@export var head_cook: float:
	set(value):
		head_cook = _clamp_value(value)
		stat_changed.emit()

@export var line_cook: float:
	set(value):
		line_cook = _clamp_value(value)
		stat_changed.emit()

@export var prep_cook: float:
	set(value):
		prep_cook = _clamp_value(value)
		stat_changed.emit()

@export var dishwasher: float:
	set(value):
		dishwasher = _clamp_value(value)
		stat_changed.emit()

@export var bartender: float:
	set(value):
		bartender = _clamp_value(value)
		stat_changed.emit()


func get_keys() -> Array[String]:
	return [
		"head_cook",
		"line_cook",
		"prep_cook",
		"dishwasher",
		"bartender",
	]
