extends Node2D

class_name RatManager

var rat_scene = preload("res://entities/rat/rat.tscn")

signal rat_clicked(rat: Rat)

var next_rat_id: int = 1
var selected_rat: Rat

@onready var _location_manager: LocationManager = get_parent().get_node("LocationManager")
@onready var _job_manager: JobManager = get_parent().get_node("JobManager")

func generate_rat() -> void:
	var rat: Rat = rat_scene.instantiate()

	rat.initialize(next_rat_id)

	next_rat_id += 1
	rat.rat_clicked.connect( func(x: Rat): rat_clicked.emit(x))
	rat.need_reevaluation.connect(trigger_rat_reevaluation)

	add_child(rat)
	rat.global_position = $RatGenerateMarker.global_position
	Colony.colony[rat.id] = rat

func trigger_rat_reevaluation(rat: Rat):
	var locations: Array[Location]= _location_manager.get_location_data()
	var job := _job_manager.get_assigned_job(rat)
	rat.reevaluate_needs(job, locations)
