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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	# if has-work and working_mood:
		#continue_work
	#else
		#???
	
func navigate_to_job() -> void:
	# if not at_job, go to job.
	# 1. find where job is
	# 2. path find to job (Astar2d)
	# 3. play correct animations based on direction.
	pass


func _on_job_manager_navigate_to_job(id: int, coords: Vector2) -> void:
	# create navigation manager in MAIN 
	pass # Replace with function body.
