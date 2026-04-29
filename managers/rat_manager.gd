extends Node

var rat_scene = preload("res://rat.tscn")

var next_rat_id: int = 1

var RATS: Dictionary[int, Rat]

func generate_rat() -> void:
	var rat = rat_scene.instantiate()
	rat.id = next_rat_id
	RATS[rat.id] = rat
	
func navigate_to_job() -> void:
	# if not at_job, go to job.
	# 1. find where job is
	# 2. path find to job (Astar2d)
	# 3. play correct animations based on direction.
	pass

func _on_job_manager_navigate_to_job(id: int, coords: Vector2) -> void:
	# create navigation manager in MAIN 
	# just teleport for now+
	print(RATS)
	RATS[id].global_position = coords
