extends Node2D

func get_job_locations(job: JobConstants.JOB) -> Array[Vector2]:
	return get_location_data().filter(func(child: Location) -> bool:
		return child.job == job).map(func(child: Location) -> Vector2:
			return child.position)

func get_location_data() -> Array[Location]:
	var locations: Array[Location] = []
	for child in get_children():
		if child is Location:
			locations.append(child)
		
	return locations
