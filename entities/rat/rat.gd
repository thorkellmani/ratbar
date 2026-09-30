extends Area2D

class_name Rat

signal rat_clicked(rat: Rat)

const DEFAULT_VALUES := preload("res://entities/rat/generation_defaults/generation_defaults.tres")
const DECAY_RATES := preload("res://entities/rat/stats/need/decay_rate/need_decay_rate.tres")

#region Local variables
var id: int

var _title: String
var _needs: Needs
var _personality: Personality
var _status: Status
var _camaraderie: Camaraderie
var _other: Other


var _locked_need: String
var _current_location: Location
var _destination: Location

#TODO LATER
#var last_nutrition_source: int = -1
#var last_stimulation_source: int = -1
#var last_social_activity: int = -1
#var last_social_partner_id: int = -1
#endregion

var personality: Personality:
	get: return _personality

var needs: Needs:
	get: return _needs

var status: Status:
	get: return _status

var camaraderie: Camaraderie:
	get: return _camaraderie

var other: Other:
	get: return _other

#endregion

func _process(delta: float) -> void:
	match other.state:
		RatConstants.STATE.PROCEEDING_TO_WORK, RatConstants.STATE.PROCEEDING_TO_LOCATION:
			global_position = global_position.move_toward(_destination.global_position, 400 * delta)
			if global_position == _destination.global_position:
				_arrive_at_destination()


func _randomize_personality_trait(personality_trait: String) -> float:
	return randfn(DEFAULT_VALUES.personality_mean.get(personality_trait), DEFAULT_VALUES.personality_deviation.get(personality_trait))

func initialize(
	idx: int,
) -> void:
	#could be optimized if needed
	id = idx
	_title = "Rat " + str(id)
	$Label.text = _title
	$ColorRect.modulate = Color.from_hsv(randf(), 0.8, 0.9)

	_personality = Personality.new()
	_personality.greed = _randomize_personality_trait("greed")
	_personality.temper = _randomize_personality_trait("temper")
	_personality.socialness = _randomize_personality_trait("socialness")
	_personality.ambition = _randomize_personality_trait("ambition")
	_personality.laziness = _randomize_personality_trait("laziness")

	_status = DEFAULT_VALUES.default_status.duplicate()
	_needs = DEFAULT_VALUES.default_needs.duplicate()
	_camaraderie = Camaraderie.new()
	_other = Other.new()

func apply_game_tick_effects(assigned_job: Job) -> void:
	var need_keys = NeedFields.get_keys()
	for need in need_keys:
		var location_modifier: float = _synthesize_location_modifier(need, assigned_job)
		#modifiers are given in hour granularity, normalize by GAME_TICKS_PER_IN_GAME_HOUR for correct numbers per tick
		var total_modifiers = _normalize_per_hour_modifier(DECAY_RATES[need] + location_modifier)
		
		_needs[need] += total_modifiers

func _synthesize_location_modifier(need: String, assigned_job: Job) -> float:
	if _current_location == null:
		return 0.0

	var location_modifiers: LocationModifiers = _current_location.modifiers
	#modifiers are given in hour granularity, normalize by GAME_TICKS_PER_IN_GAME_HOUR for correct numbers per tick
	var modifier = location_modifiers[need]
	#apply employment modifiers if rat has job, rat is at job and rat is working
	if assigned_job != null && _current_location in assigned_job.locations && other.state == RatConstants.STATE.WORKING:
		modifier += assigned_job.modifiers[need] if assigned_job.modifiers[need] != null else 0
	
	return modifier

func _normalize_per_hour_modifier(modifier: float) -> float:
	return modifier / GameConstants.GAME_TICKS_PER_IN_GAME_HOUR

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		rat_clicked.emit(self)

func reevaluate_needs(job: Job, locations: Array[Location]) -> void:
	var intended_location: Location = NeedsEvaluator.evaluate(self, job, locations)
	if intended_location == _current_location:
		print("Same destination selected")
		return
		
	_destination = intended_location
	print(_destination.title if _destination else "No destination")
	if _destination:
		_start_travelling(job)
	if not _destination:
		other.state = RatConstants.STATE.IDLE
		
func _start_travelling(job: Job) -> void:
	_current_location = null
	other.state = RatConstants.STATE.PROCEEDING_TO_WORK if job != null && _destination in job.locations else RatConstants.STATE.PROCEEDING_TO_LOCATION
		
func _arrive_at_destination() -> void:
	if  other.state == RatConstants.STATE.PROCEEDING_TO_WORK:
		other.state = RatConstants.STATE.WORKING
	else:
		other.state = RatConstants.STATE.IDLE

	_current_location = _destination
	_destination = null
