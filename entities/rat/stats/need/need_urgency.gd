class_name NeedUrgency extends Resource

@export var nutrition: Curve
@export var energy: Curve
@export var stimulation: Curve
@export var social: Curve
@export var vice_satisfaction: Curve

func get_keys() -> Array[String]:
	return [
		"nutrition",
		"energy",
		"stimulation",
		"social",
		"vice_satisfaction",
	]
