class_name PauseButton extends Button

var is_paused: bool
var previous_time_scale = Engine.time_scale

func _ready() -> void:
	pressed.connect(update_time_scale)
	text = "▶" if is_paused == true else "⏸"

func update_time_scale() -> void:
	if (is_paused):
		Engine.time_scale = previous_time_scale
		is_paused = false
	else:
		previous_time_scale = Engine.time_scale
		Engine.time_scale = 0
		is_paused = true
