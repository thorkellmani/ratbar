extends Area2D

class_name Rat

var id: int
var title: String

# PERSONALITY ( 1-5)
var chillness: int
var riskiness: int
var ambition: int
var angriness: int
var socialness: int
var meanness: int

# MOOD (1-100)
var tiredness: int
var boredom: int
var stress: int
var burnout_level: int
var hunger: int

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	# if has-work and working_mood:
		#continue_work
	#else
		#???
