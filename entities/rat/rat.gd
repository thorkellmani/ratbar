extends Area2D

class_name Rat

signal rat_clicked(rat: Rat)

var id: int
var title: String
var mood: Dictionary[RatConstants.MOOD, float] = {}
var personality: Dictionary[RatConstants.TRAIT, float] = {}
var statuses: Dictionary[RatConstants.STATUS, float] = {}
var owner_relationship: float
var currency: float
var job_skills: Dictionary[JobConstants.JOB, float]

#region Stat functions
func update_personality_trait(key: RatConstants.TRAIT, modifier: float) -> void:
	personality[key] = clampf(personality[key] +  modifier, -100, 100)
	
func update_moodlet(key: RatConstants.MOOD, modifier: float) -> void:
	mood[key] = clampf(mood[key] +  modifier, -100, 100)
	
func update_status(key: RatConstants.STATUS, modifier: float) -> void:
	statuses[key] = clampf(statuses[key] +  modifier, 0, 100)
	
func update_currency(modifier: float) -> void:
	currency += modifier
	
func update_owner_relationship(modifier: float) -> void:
	owner_relationship = clampf(owner_relationship + modifier, -100, 100)
	
#endregion


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		rat_clicked.emit(self)
		
