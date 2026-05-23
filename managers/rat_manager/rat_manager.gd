extends Node2D

var rat_scene = preload("res://entities/rat/rat.tscn")

signal rat_clicked(rat: Rat)

var next_rat_id: int = 1

var RATS: Dictionary[int, Rat]
var selected_rat: Rat

func generate_rat() -> void:
	var rat: Rat = rat_scene.instantiate()
	rat.id = next_rat_id
	next_rat_id += 1
	rat.rat_clicked.connect( func(x: Rat): rat_clicked.emit(x))
	
	for rat_trait in RatConstants.TRAIT.values():
		rat.personality[rat_trait] = randfn(RatConstants.TRAIT_MEAN[rat_trait], RatConstants.TRAIT_DEVIATION[rat_trait])

	rat.mood = RatConstants.DEFAULT_MOOD.duplicate()
	rat.statuses = RatConstants.DEFAULT_STATUSES.duplicate()
	rat.job_skills = RatConstants.DEFAULT_JOB_SKILLS.duplicate()
	rat.currency = 0
	rat.owner_relationship = 0
	
	add_child(rat)
	rat.global_position = $RatGenerateMarker.global_position
	RATS[rat.id] = rat
	
func navigate_to_job() -> void:
	# if not at_job, go to job.
	# 1. find where job is
	# 2. path find to job (Astar2d)
	# 3. play correct animations based on direction.
	pass
	
func _ready() -> void:
	generate_rat()

func _on_job_manager_navigate_to_job(id: int, coords: Vector2) -> void:
	print("navigation to job")
	# create navigation manager in MAIN 
	# just teleport for now+
	RATS[id].global_position = coords
