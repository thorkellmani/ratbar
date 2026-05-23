extends Node

signal navigate_to_job(id: int, coords: Vector2)

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
var _assigned_jobs: Dictionary[int, JobConstants.JOB]

func get_assigned_job(ratId: int) -> JobConstants.JOB:
	return _assigned_jobs.get(ratId, JobConstants.JOB.UNASSIGNED)

func unassign_job(ratId: int) -> void:
	_assigned_jobs[ratId] = JobConstants.JOB.UNASSIGNED

func assign_job(ratId: int, job: JobConstants.JOB) -> void:
	_assigned_jobs[ratId] = job
	var job_location = JOB_LOCATIONS.get(job, Vector2(0,0))
	
	if job_location:
		navigate_to_job.emit(ratId, job_location)
	
func clear() -> void:
	#what happens when all jobs are unassigned?
	var _ids = _assigned_jobs.keys()
	_assigned_jobs = {}

func _on_assign_job_button_pressed() -> void:
	assign_job(1, JobConstants.JOB.values().pick_random())
