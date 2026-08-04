extends Node2D

class_name JobManager

var _ASSIGNED_JOBS: Dictionary[int, JobConstants.JOB] = {}

func get_assigned_job(rat: Rat) -> JobConstants.JOB:
	return _ASSIGNED_JOBS.get(rat.id, JobConstants.JOB.UNASSIGNED)

func unassign_job(rat: Rat) -> void:
	_ASSIGNED_JOBS.erase(rat.id)

func assign_job(rat: Rat, job: JobConstants.JOB) -> void:
	if job == JobConstants.JOB.UNASSIGNED:
		print("Unassigning ", rat._title, " from job ", JobConstants.JOB.find_key(_ASSIGNED_JOBS.get(rat.id, JobConstants.JOB.UNASSIGNED)))
		unassign_job(rat)
	else:
		print("Assigning job ", JobConstants.JOB.find_key(job), " to ", rat._title)
		_ASSIGNED_JOBS.set(rat.id, job)

func clear_all_jobs() -> void:
	_ASSIGNED_JOBS = {}

func _on_assign_job_button_pressed(rat: Rat, job: JobConstants.JOB) -> void:
	assign_job(rat, job)
