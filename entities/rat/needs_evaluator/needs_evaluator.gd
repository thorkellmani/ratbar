class_name NeedsEvaluator extends Object

const URGENCIES := preload("./need_urgencies.tres")

static func evaluate(rat: Rat, assigned_job: JobConstants.JOB, locations: Array[Location]) -> Location:
	print("Evaluating needs for ", rat._title, " with job ", JobConstants.JOB.find_key(assigned_job))
	var best_score: float = -INF
	var best_location: Location
	for location in locations:
		var employment_pressure : float = JobConstants.EMPLOYMENT_PRESSURE if assigned_job == location.job else 0.0

		var score: float = (URGENCIES.mood_urgencies.nutrition.sample(rat.mood.nutrition) * location.pull.nutrition) + employment_pressure
		if score > best_score:
			best_score = score
			best_location = location


	print("Best location for ", rat._title, " with job ", JobConstants.JOB.find_key(assigned_job), " is ", best_location.title, " with score ", best_score)
	return best_location
