class_name StressEvaluator extends Object

const TUNING := preload("res://systems/stress/stress_tuning.tres")

static func get_stress_tier(average_urgency: float) -> StressTier:
	var tiers: Array = TUNING.tiers
	for tier in tiers:
		if average_urgency < tier.upper_average_urgency:
			return tier
	return tiers.back()

static func get_work_rate_per_game_hour(is_working: bool) -> float:
	return TUNING.working_stress_change_per_game_hour if is_working else 0.0

static func get_stress_rate_per_game_hour(
	average_urgency: float,
	is_working: bool
) -> float:
	var tier: StressTier = get_stress_tier(average_urgency)
	return tier.stress_change_per_game_hour + get_work_rate_per_game_hour(is_working)

static func calculate_tick_stress_change(
	average_urgency: float,
	is_working: bool
) -> float:
	return get_stress_rate_per_game_hour(
		average_urgency,
		is_working
	) / GameConstants.GAME_TICKS_PER_IN_GAME_HOUR
