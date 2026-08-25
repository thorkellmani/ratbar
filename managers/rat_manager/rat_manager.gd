extends Node2D

class_name RatManager

var rat_scene = preload("res://entities/rat/rat.tscn")

signal rat_clicked(rat: Rat)

var next_rat_id: int = 1
var selected_rat: Rat

var _rat_tick_slot_registry: Array[TickSlotRegistry] = []

@onready var _location_manager: LocationManager = get_parent().get_node("LocationManager")
@onready var _job_manager: JobManager = get_parent().get_node("JobManager")

func _ready() -> void:
	for i in range(GameConstants.GAME_TICK_SLOTS):
		var new_slot: TickSlotRegistry = TickSlotRegistry.new()
		new_slot.idx = i
		_rat_tick_slot_registry.append(new_slot)


func generate_rat() -> void:
	var rat: Rat = rat_scene.instantiate()
	rat.initialize(next_rat_id)

	next_rat_id += 1
	rat.rat_clicked.connect( func(x: Rat): rat_clicked.emit(x))

	add_child(rat)
	rat.global_position = $RatGenerateMarker.global_position
	Colony.colony[rat.id] = rat

	_assign_slot(rat)

func _assign_slot(rat: Rat) -> void:
	var slot_counts := _rat_tick_slot_registry.map(func(s) -> int: return s.rats.size())
	var slot: int = Utils.pick_weighted_random(slot_counts)
	_rat_tick_slot_registry[slot].rats.append(rat)

func _on_game_clock_tick(tick_count: int) -> void:
	#iterate over all rats and apply location modifiers
	for rat: Rat in Colony.colony.values():
		rat.apply_modifiers(_job_manager.get_assigned_job(rat))
		_check_rat_reevaluation(tick_count, rat)

func _check_rat_reevaluation(tick_count: int, rat: Rat) -> void:
	var slotted_rats: Array[Rat] = _rat_tick_slot_registry[tick_count % GameConstants.GAME_TICK_SLOTS].rats
	if rat in slotted_rats:
		var locations: Array[Location]= _location_manager.get_location_data()
		var job := _job_manager.get_assigned_job(rat)
		rat.reevaluate_needs(job, locations)
