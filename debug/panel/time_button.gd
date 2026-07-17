class_name TimeButton extends Button

const _TIME_BUTTON_VALUES := [1.0, 5.0, 10.0, 0.5]

var _index = 0

func _ready() -> void:
	pressed.connect(update_time_scale)
	text = "Time: %.1fx" % _TIME_BUTTON_VALUES[_index]

func update_time_scale() -> void:
	_index = (_index + 1) % _TIME_BUTTON_VALUES.size()
	Engine.time_scale = _TIME_BUTTON_VALUES[_index]
	text = "Time: %.1fx" % _TIME_BUTTON_VALUES[_index]
