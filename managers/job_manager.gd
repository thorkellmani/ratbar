extends Node

signal navigate_to_job(id: int, coords: Vector2)

var JOB_LOCATIONS: Dictionary[Constants.JOB, Vector2]

func _ready() -> void:
	JOB_LOCATIONS = {
		Constants.JOB.COOK: $Cook1Marker.global_position,
		Constants.JOB.COOK2: $Cook2Marker.global_position,
		Constants.JOB.SERVER: $ServerMarker.global_position,
		Constants.JOB.GROCER: $Grocer1Marker.global_position,
		Constants.JOB.DISHWASHER: $DishwasherMarker.global_position
	}

var _assigned_jobs: Dictionary[int, Constants.JOB]

func get_assigned_job(ratId: int) -> Constants.JOB:
	return _assigned_jobs.get(ratId, Constants.JOB.UNASSIGNED)

func unassign_job(ratId: int) -> void:
	_assigned_jobs[ratId] = Constants.JOB.UNASSIGNED

func assign_job(ratId: int, job: Constants.JOB) -> void:
	print("assign job")
	_assigned_jobs[ratId] = job
	var job_location = JOB_LOCATIONS.get(job, Vector2(0,0))
	
	if job_location:
		navigate_to_job.emit(ratId, job_location)
	else:
		print("job location not found")
	
func clear() -> void:
	#what happens when all jobs are unassigned?
	var _ids = _assigned_jobs.keys()
	_assigned_jobs = {}

func _on_assign_job_button_pressed() -> void:
	print('PRESSED')
	assign_job(1, Constants.JOB.values().pick_random())
