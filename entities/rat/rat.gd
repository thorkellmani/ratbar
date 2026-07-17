extends Area2D

class_name Rat

signal rat_clicked(rat: Rat)

const DEFAULT_VALUES := preload("res://entities/rat/generation_defaults.tres")

#region Local variables
var id: int

var _title: String
var _mood: RatMood
var _personality: RatPersonality
var _status: RatStatus
var _vice: RatVice
var _job_skills: RatJobSkills
var _camaraderie: RatCamaraderie
var _other: RatOther

#TODO LATER
#var last_nutrition_source: int = -1
#var last_stimulation_source: int = -1
#var last_social_activity: int = -1
#var last_social_partner_id: int = -1
#endregion

var personality: RatPersonality:
	get: return _personality

var mood: RatMood:
	get: return _mood

var status: RatStatus:
	get: return _status

var vice: RatVice:
	get: return _vice

var job_skills: RatJobSkills:
	get: return _job_skills

var camaraderie: RatCamaraderie:
	get: return _camaraderie

var other: RatOther:
	get: return _other

#endregion

func _randomize_personality_trait(personality_trait: String) -> float:
	return randfn(DEFAULT_VALUES.personality_mean.get(personality_trait), DEFAULT_VALUES.personality_deviation.get(personality_trait))

func initialize(
	idx: int,
) -> void:
	#could be optimized if needed
	id = idx
	_title = "Rat " + str(id)

	_personality = RatPersonality.new()
	_personality.greed = _randomize_personality_trait("greed")
	_personality.temper = _randomize_personality_trait("temper")
	_personality.socialness = _randomize_personality_trait("socialness")
	_personality.ambition = _randomize_personality_trait("ambition")
	_personality.laziness = _randomize_personality_trait("laziness")

	_status = DEFAULT_VALUES.default_status.duplicate()
	_vice = DEFAULT_VALUES.default_vice.duplicate()
	_mood = DEFAULT_VALUES.default_mood.duplicate()
	_job_skills = DEFAULT_VALUES.default_job_skills.duplicate()
	_camaraderie = RatCamaraderie.new()
	_other = RatOther.new()


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		rat_clicked.emit(self)
