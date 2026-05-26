extends Node

signal navigate_to_job(rat: Rat, coords: Vector2)

@export var head_cook_marker: Marker2D
@export var line_cook_marker: Marker2D
@export var prep_cook_marker: Marker2D
@export var dishwasher_marker: Marker2D
@export var bartender_marker: Marker2D

var JOB_LOCATIONS: Dictionary[JobConstants.JOB, Vector2]

func _ready() -> void:
	JOB_LOCATIONS = {
		JobConstants.JOB.HEAD_COOK: head_cook_marker.global_position,
		JobConstants.JOB.LINE_COOK: line_cook_marker.global_position,
		JobConstants.JOB.PREP_COOK: prep_cook_marker.global_position,
		JobConstants.JOB.DISHWASHER: dishwasher_marker.global_position,
		JobConstants.JOB.BARTENDER: bartender_marker.global_position
	}

func get_assigned_job(rat: Rat) -> JobConstants.JOB:
	return rat.assigned_job

func unassign_job(rat: Rat) -> void:
	rat.update_assigned_job(JobConstants.JOB.UNASSIGNED)

func assign_job(rat: Rat, job: JobConstants.JOB) -> void:
	rat.update_assigned_job(job)
	var job_location = JOB_LOCATIONS.get(job, Vector2(0,0))

	if job_location:
		navigate_to_job.emit(rat, job_location)

func clear_all_jobs() -> void:
	#what happens when all jobs are unassigned?
	var rats: Array[Rat] = Colony.rats.values()
	for rat in rats:
		rat.update_assigned_job(JobConstants.JOB.UNASSIGNED)

func _on_assign_job_button_pressed() -> void:
	assign_job(1, JobConstants.JOB.values().pick_random())
