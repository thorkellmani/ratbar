extends Area2D

class_name Rat

signal rat_clicked(rat: Rat)

const DEFAULT_VALUES := preload("res://entities/rat/generation_defaults/generation_defaults.tres")

#region Local variables
var id: int

var _title: String
var _mood: Mood
var _personality: Personality
var _status: Status
var _vice: Vice
var _job_skills: JobSkills
var _camaraderie: Camaraderie
var _other: Other

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

var mood: Mood:
	get: return _mood

var status: Status:
	get: return _status

var vice: Vice:
	get: return _vice

var job_skills: JobSkills:
	get: return _job_skills

var camaraderie: Camaraderie:
	get: return _camaraderie

var other: Other:
	get: return _other

#endregion

func _process(delta: float) -> void:
	match other.state:
		RatConstants.STATE.PROCEEDING_TO_LOCATION:
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
	_vice = DEFAULT_VALUES.default_vice.duplicate()
	_mood = DEFAULT_VALUES.default_mood.duplicate()
	_job_skills = DEFAULT_VALUES.default_job_skills.duplicate()
	_camaraderie = Camaraderie.new()
	_other = Other.new()

func apply_location_modifiers() -> void:
	if _current_location == null:
		return

	var modifiers: LocationModifiers = _current_location.modifiers
	#modifiers are given in hour granularity, normalize by GAME_TICKS_PER_IN_GAME_HOUR for correct numbers per tick
	_mood.nutrition += modifiers.nutrition / GameConstants.GAME_TICKS_PER_IN_GAME_HOUR


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		rat_clicked.emit(self)

func reevaluate_needs(job: JobConstants.JOB, locations: Array[Location]) -> void:
	var intended_location: Location = NeedsEvaluator.evaluate(self, job, locations)
	_destination = intended_location
	other.state = RatConstants.STATE.PROCEEDING_TO_LOCATION

func _arrive_at_destination() -> void:
	if _destination.job != JobConstants.JOB.UNASSIGNED:
		other.state = RatConstants.STATE.WORKING
	else:
		other.state = RatConstants.STATE.IDLE

	_current_location = _destination
	_destination = null
