class_name NeedUrgencies extends Resource

@export var need_urgencies: NeedUrgency

func get_effective_average_urgency(
	needs: Needs,
	net_rates_per_hour: Dictionary[String, float]
) -> float:
	var need_keys: Array[String] = NeedFields.get_keys()
	var total: float = 0.0

	for need in need_keys:
		var sample_value: float = needs._get_max() if net_rates_per_hour[need] > 0.0 else needs[need]
		total += need_urgencies[need].sample(sample_value)

	return total / need_keys.size()
