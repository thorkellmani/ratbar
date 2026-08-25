extends Node2D

class_name JobManager

var _ASSIGNED_JOBS: Dictionary[int, Job] = {}

func get_jobs() -> Array[Job]:
	var jobs: Array[Job] = []
	for child in get_children():
		if child is Job:
			jobs.append(child)
		
	return jobs


func get_assigned_job(rat: Rat) -> Job:
	return _ASSIGNED_JOBS.get(rat.id, null)

func unassign_job(rat: Rat) -> void:
	print("Clearing assigned job from ", rat._title)
	_ASSIGNED_JOBS.erase(rat.id)

func assign_job(rat: Rat, job: Job) -> void:
	print("Assigning job ", job.title, " to ", rat._title)
	_ASSIGNED_JOBS.set(rat.id, job)

func clear_all_jobs() -> void:
	_ASSIGNED_JOBS = {}

func _on_assign_job_button_pressed(rat: Rat, job: Job) -> void:
	if job == null:
		unassign_job(rat)
	else :
		assign_job(rat, job)
