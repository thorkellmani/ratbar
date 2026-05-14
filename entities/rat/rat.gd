extends Area2D

class_name Rat

signal rat_clicked(rat: Rat)

var id: int
var title: String
var mood: Dictionary[MOOD, float] = {}
var personality: Dictionary[TRAIT, float] = {}
var statuses: Dictionary[STATUS, float] = {}
var owner_relationship: float
var currency: float

enum TRAIT { GREED, TEMPER, SOCIALNESS, AMBITION, LAZINESS }
enum MOOD { NUTRITION, ENERGY, STIMULATION, SOCIAL, VICE_SATISFACTION }
enum STATUS { STRESS, HEALTH, INEBRIATION, RADICALIZATION, EXTRA_STRESS}

 #`stress` (0–100), `health` (0–100, default 100), `inebriation` (0–100), `owner_relationship` (-100 to 100), `radicalization` (0–100), `extra_stress` (0–100), `currency` (float, ≥ 0)


#region moodlet configuration
const TRAIT_DEVIATION: Dictionary[TRAIT, float] = { 
	TRAIT.GREED: 35,
	TRAIT.TEMPER: 40,
	TRAIT.SOCIALNESS: 30,
	TRAIT.AMBITION: 45,
	TRAIT.LAZINESS: 50 
}
const TRAIT_MEAN: Dictionary[TRAIT, float] = {
	TRAIT.GREED: 40,
	TRAIT.TEMPER: 10,
	TRAIT.SOCIALNESS: 60,
	TRAIT.AMBITION: -20,
	TRAIT.LAZINESS: 20
}

var initial_mood := mood
var initial_personality := personality
var initial_statuses := statuses
var initial_currency: float
var initial_owner_relationship: float
#endregion

func _ready() -> void:
	initial_mood = {
		MOOD.NUTRITION: 0,
		MOOD.ENERGY: 0,
		MOOD.STIMULATION: 0,
		MOOD.SOCIAL: 0,
		MOOD.VICE_SATISFACTION: 0,
	}
	initial_personality = {
		TRAIT.GREED: randfn(TRAIT_MEAN[TRAIT.GREED], TRAIT_DEVIATION[TRAIT.GREED]),
		TRAIT.TEMPER: randfn(TRAIT_MEAN[TRAIT.TEMPER], TRAIT_DEVIATION[TRAIT.TEMPER]),
		TRAIT.SOCIALNESS: randfn(TRAIT_MEAN[TRAIT.SOCIALNESS], TRAIT_DEVIATION[TRAIT.SOCIALNESS]),
		TRAIT.AMBITION: randfn(TRAIT_MEAN[TRAIT.AMBITION], TRAIT_DEVIATION[TRAIT.AMBITION]),
		TRAIT.LAZINESS: randfn(TRAIT_MEAN[TRAIT.LAZINESS], TRAIT_DEVIATION[TRAIT.LAZINESS]),
	}
	initial_statuses = {
		STATUS.STRESS: 0,
		STATUS.HEALTH: 100,
		STATUS.INEBRIATION: 0,
		STATUS.RADICALIZATION: 0,
		STATUS.EXTRA_STRESS: 0,
	}
	initial_currency = 0
	initial_owner_relationship = 0
	
	personality = initial_personality
	mood = initial_mood
	statuses = initial_statuses
	owner_relationship = initial_owner_relationship
	currency = initial_currency

#region Stat functions
func update_personality_trait(key: TRAIT, modifier: float) -> void:
	personality[key] = clampf(personality[key] +  modifier, -100, 100)
	
func update_moodlet(key: MOOD, modifier: float) -> void:
	mood[key] = clampf(mood[key] +  modifier, -100, 100)
	
func update_status(key: STATUS, modifier: float) -> void:
	statuses[key] = clampf(statuses[key] +  modifier, 0, 100)
	
func update_currency(modifier: float) -> void:
	currency += modifier
	
func update_owner_relationship(modifier: float) -> void:
	owner_relationship = clampf(owner_relationship + modifier, -100, 100)
	

func reset_mood() -> void:
	mood = initial_mood
	
func reset_statuses() -> void:
	statuses = initial_statuses
	
func reset_personality() -> void:
	personality = initial_personality
	
func reset_currency() -> void:
	currency = initial_currency
	
func reset_owner_relationship() -> void:
	owner_relationship = initial_owner_relationship
	
#endregion


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		rat_clicked.emit(self)
		
