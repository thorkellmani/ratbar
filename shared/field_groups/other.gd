class_name OtherFields extends BaseStatGroup

@export var owner_relationship: float:
	set(value):
		owner_relationship = clampf(value, -100, 100)
		stat_changed.emit()

@export var currency: float:
	set(value):
		currency = value
		stat_changed.emit()

@export var crisis: RatConstants.CRISIS = RatConstants.CRISIS.UNAFFECTED:
	set(value):
		crisis = value
		stat_changed.emit()

@export var state: RatConstants.STATE = RatConstants.STATE.IDLE:
	set(value):
		state = value
		stat_changed.emit()

@export var assigned_job: JobConstants.JOB = JobConstants.JOB.UNASSIGNED:
	set(value):
		assigned_job = value
		stat_changed.emit()

func get_keys() -> Array[String]:
	return [
		"owner_relationship",
		"currency",
		"crisis",
		"state",
		"assigned_job",
	]
