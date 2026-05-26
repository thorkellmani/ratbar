extends Node2D

var rat_scene = preload("res://entities/rat/rat.tscn")

signal rat_clicked(rat: Rat)

var next_rat_id: int = 1
var selected_rat: Rat

func generate_rat() -> void:
	var rat: Rat = rat_scene.instantiate()
	rat.id = next_rat_id
	rat.title = "Rat " + str(next_rat_id)

	next_rat_id += 1
	rat.rat_clicked.connect( func(x: Rat): rat_clicked.emit(x))

	for rat_trait in RatConstants.TRAIT.values():
		rat.personality[rat_trait] = randfn(RatConstants.TRAIT_MEAN[rat_trait], RatConstants.TRAIT_DEVIATION[rat_trait])

	rat.mood = RatConstants.DEFAULT_MOOD.duplicate()
	rat.status = RatConstants.DEFAULT_STATUS.duplicate()
	rat.job_skills = RatConstants.DEFAULT_JOB_SKILLS.duplicate()
	rat.vice = RatConstants.DEFAULT_VICE.duplicate()
	rat.primary_vice = RatConstants.VICE.values().pick_random()
	rat.crisis_state = RatConstants.CRISIS_STATE.UNAFFECTED
	rat.job_state = RatConstants.JOB_STATE.IDLE
	rat.assigned_job = JobConstants.JOB.UNASSIGNED
	rat.currency = 0
	rat.owner_relationship = 0

	rat.last_nutrition_source = -1
	rat.last_stimulation_source = -1
	rat.last_social_activity = -1
	rat.last_social_partner_id = -1

	add_child(rat)
	rat.global_position = $RatGenerateMarker.global_position
	Colony.rats[rat.id] = rat

func navigate_to_job() -> void:
	# if not at_job, go to job.
	# 1. find where job is
	# 2. path find to job (Astar2d)
	# 3. play correct animations based on direction.
	pass

func _ready() -> void:
	generate_rat()

func _on_job_manager_navigate_to_job(rat: Rat, coords: Vector2) -> void:
	print("navigating to job")
	# create navigation manager in MAIN
	# just teleport for now+
	Colony.rats[rat.id].global_position = coords
