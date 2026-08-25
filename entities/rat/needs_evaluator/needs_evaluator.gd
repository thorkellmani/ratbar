class_name NeedsEvaluator extends Object

const URGENCIES := preload("./need_urgencies.tres")

const SCORING_TUNING_CONSTANT = 3

static func evaluate(rat: Rat, assigned_job: Job, locations: Array[Location]) -> Location:
	print("Evaluating needs for ", rat._title)
	var has_job: bool = assigned_job != null
	
	var best_score: float = -INF
	var best_location: Location
	
	var need_keys := NeedFields.get_keys()
	var normalized_need_urgencies: Dictionary[String, float] = get_normalized_need_urgencies(rat, need_keys)
	
	if has_job:
		print("Rat with job ", assigned_job.title, " is deciding where to travel to next...")
	else:
		print("Rat is deciding where to travel to next...")
	
	for location in locations:
		var total_powered_location_score: float = 0
		var active_axis_count: int = 0
		for axis in need_keys:
			if location.pull[axis] > 0:
				active_axis_count += 1
				total_powered_location_score += pow((normalized_need_urgencies[axis] * location.pull.get_normalized_value(axis)), SCORING_TUNING_CONSTANT )
				
		# if no axises, continue to next location
		if active_axis_count < 1:
			continue
		
		# Raise the locations scores to a power, sum them, get the average, then bring it back.
		# This helps more "urgent" needs have extra weight
		var mean_power_location_score: float = pow((( 1.0 / active_axis_count) * total_powered_location_score), 1.0 / SCORING_TUNING_CONSTANT)
		
		var employment_pressure : float = JobConstants.EMPLOYMENT_PRESSURE if has_job && location in assigned_job.locations else 0.0
		var total_location_score = employment_pressure + mean_power_location_score
		
		print("Location ", location.title, " has score: ", total_location_score)
		
		if total_location_score > best_score:
			best_score = total_location_score
			best_location = location
			
	if best_location != null:
		print("Best location for ", rat._title, " is ", best_location.title, " with score ", best_score)
	else:
		print("No good location")
	return best_location

static func get_normalized_need_urgencies(rat: Rat, need_keys: Array[String]) -> Dictionary[String, float]:
	var urgencies: Dictionary[String, float] = {}
	for need in need_keys:
		urgencies[need] = URGENCIES.need_urgencies[need].sample(rat.needs[need])
	return urgencies
