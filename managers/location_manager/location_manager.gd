extends Node2D

class_name LocationManager

func get_location_data() -> Array[Location]:
	var locations: Array[Location] = []
	for child in get_children():
		if child is Location:
			locations.append(child)
		
	return locations
