extends Node

func get_assigned_job(rat: Rat) -> JobConstants.JOB:
	return rat.assigned_job

func unassign_job(rat: Rat) -> void:
	rat.update_assigned_job(JobConstants.JOB.UNASSIGNED)

func assign_job(rat: Rat, job: JobConstants.JOB) -> void:
	rat.update_assigned_job(job)

func clear_all_jobs() -> void:
	#what happens when all jobs are unassigned?
	var rats: Array[Rat] = Colony.colony.values()
	for rat in rats:
		rat.update_assigned_job(JobConstants.JOB.UNASSIGNED)

func _on_assign_job_button_pressed() -> void:
	pass
	#assign_job(1, JobConstants.JOB.values().pick_random())
