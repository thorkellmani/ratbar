extends Area2D

class_name Rat

signal rat_clicked(rat: Rat)

#region Local variables
var id: int
var title: String
var mood: Dictionary[RatConstants.MOOD, float] = {}
var personality: Dictionary[RatConstants.TRAIT, float] = {}
var status: Dictionary[RatConstants.STATUS, float] = {}
var owner_relationship: float
var currency: float
var job_skills: Dictionary[JobConstants.JOB, float] = {}
var vice: Dictionary[RatConstants.VICE, float] = {}
var primary_vice: RatConstants.VICE
var camaraderie: Dictionary[int, float] = {}
var crisis_state: RatConstants.CRISIS_STATE
var job_state: RatConstants.JOB_STATE
var assigned_job: JobConstants.JOB

var last_nutrition_source: int
var last_stimulation_source: int
var last_social_activity: int
var last_social_partner_id: int
#endregion

#region Stat functions

func get_stat(accessor: String, key: int) -> float:
	var dict = get(accessor)
	return dict[key] if dict else NAN

func update_personality_trait(key: RatConstants.TRAIT, modifier: float) -> void:
	personality[key] = clampf(personality[key] +  modifier, -100, 100)

func update_moodlet(key: RatConstants.MOOD, modifier: float) -> void:
	mood[key] = clampf(mood[key] +  modifier, -100, 100)

func update_vice(key: RatConstants.VICE, modifier: float) -> void:
	vice[key] = clampf(vice[key] +  modifier, 0, 100)

func update_status(key: RatConstants.STATUS, modifier: float) -> void:
	status[key] = clampf(status[key] +  modifier, 0, 100)

func update_currency(modifier: float) -> void:
	currency += modifier

func update_owner_relationship(modifier: float) -> void:
	owner_relationship = clampf(owner_relationship + modifier, -100, 100)

func update_assigned_job(job: JobConstants.JOB) -> void:
	assigned_job = job

#endregion


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		rat_clicked.emit(self)
