class_name Other extends BaseStatGroup

@export var owner_relationship: float:
	set(value):
		owner_relationship = clampf(value, -100, 100)
		stat_changed.emit()

@export var currency: float:
	set(value):
		currency = value
		stat_changed.emit()

@export var crisis_state: RatConstants.CRISIS_STATE = RatConstants.CRISIS_STATE.UNAFFECTED:
	set(value):
		crisis_state = value
		stat_changed.emit()

@export var job_state: RatConstants.JOB_STATE = RatConstants.JOB_STATE.IDLE:
	set(value):
		job_state = value
		stat_changed.emit()

@export var assigned_job: JobConstants.JOB = JobConstants.JOB.UNASSIGNED:
	set(value):
		assigned_job = value
		stat_changed.emit()

func get_keys() -> Array[String]:
	return [
		"owner_relationship",
		"currency",
		"crisis_state",
		"job_state",
		"assigned_job",
	]
