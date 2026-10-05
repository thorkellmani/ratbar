extends CanvasLayer

signal assign_job_requested(rat: Rat, job: Job)
signal generate_rat_requested

var _rat: Rat


@onready var _job_manager: JobManager = get_parent().get_node("JobManager")
@onready var _stress_readout: Label = $Scroller/Panel/StressReadout
@onready var _average_urgency_label: Label = $Scroller/Panel/StressBreakdown/Details/AverageUrgency
@onready var _need_tier_label: Label = $Scroller/Panel/StressBreakdown/Details/NeedTier
@onready var _working_rate_label: Label = $Scroller/Panel/StressBreakdown/Details/WorkingRate
@onready var _net_rate_label: Label = $Scroller/Panel/StressBreakdown/Details/NetRate

# Dictionary mapping stat keys to their corresponding LineEdit inputs.
var actions := {
	"GENERATE_RAT": {
		"label": "Generate Rat",
		"signal": generate_rat_requested,
	},
}
# _rat of the moment of invocation, not initalization
var debug_panel_structure: Dictionary[String, Callable] = {
	"Personality": func():
		var result := {}
		for stat_name in Personality.get_keys():
			result[stat_name] = {
				"get": func(): return _rat.personality.get(stat_name),
				"set": func(value): _rat.personality.set(stat_name, value),
			}
		return result,
	"Needs": func():
		var result := {}
		for stat_name in Needs.get_keys():
			result[stat_name] = {
				"get": func(): return _rat.needs.get(stat_name),
				"set": func(value): _rat.needs.set(stat_name, value),
			}
		return result,
	"Statuses": func():
		var result := {}
		for stat_name in Status.get_keys():
			result[stat_name] = {
				"get": func(): return _rat.status.get(stat_name),
				"set": func(value): _rat.status.set(stat_name, value),
			}
		return result,
	"Other": func():
		var result := {}
		for key in Other.get_keys():
			result[key] = {
				"get": func(): return _rat.other.get(key),
				"set": func(value): _rat.other.set(key, value)
			}
		return result
}

func generate_button(label: String, callback: Callable) -> Button:
	var button: Button = Button.new()
	button.text = label
	button.pressed.connect(callback)
	return button


func _initialize() -> void:
	for group_name in debug_panel_structure:
		var rat_stat_group = debug_panel_structure[group_name].call()
		var debug_panel_group: DebugPanelGroup = DebugPanelGroup.new()
		debug_panel_group.title = group_name
		$Scroller/Panel.add_child(debug_panel_group)

		for stat_name in rat_stat_group:
			var group_functions: Dictionary = rat_stat_group[stat_name]
			debug_panel_group.add_child_row(stat_name, group_functions["get"], group_functions["set"])

	#assign job
	var assign_job_panel_group = FoldableContainer.new()
	var job_vbox = VBoxContainer.new()

	assign_job_panel_group.title = "Assign Jobs"
	$Scroller/Panel.add_child(assign_job_panel_group)
	assign_job_panel_group.add_child(job_vbox)
	assign_job_panel_group.folded = true
	
	for job in _job_manager.get_jobs():
		job_vbox.add_child(generate_button(job.title, func(): assign_job_requested.emit(_rat, job)))
	job_vbox.add_child(generate_button("Unassign", func(): assign_job_requested.emit(_rat, null)))
	
	for action in actions:
		$Scroller/Panel.add_child(generate_button(actions[action].label, func(): actions[action].signal.emit()))
	$Scroller/Panel.add_child(TimeButton.new())
	$Scroller/Panel.add_child(PauseButton.new())



func _update() -> void:
	_stress_readout.text = "Rat %d stress: %.2f / %.0f" % [
		_rat.id,
		_rat.status.stress,
		_rat.status._get_max(),
	]
	if is_nan(_rat.effective_average_urgency):
		_average_urgency_label.text = "Average urgency: --"
		_need_tier_label.text = "Need tier: --"
		_working_rate_label.text = "Working: --"
		_net_rate_label.text = "Net stress rate: --"
	else:
		var average: float = _rat.effective_average_urgency
		var tier: StressTier = StressEvaluator.get_stress_tier(average)
		var job: Job = _job_manager.get_assigned_job(_rat)
		var is_working: bool = _rat.is_working_assigned_job(job)

		_average_urgency_label.text = "Average urgency: %.3f" % average
		_need_tier_label.text = "Need tier: %s (%s)" % [
			tier.label,
			_format_hourly_rate(tier.stress_change_per_game_hour),
		]
		_working_rate_label.text = "Working: %s" % _format_hourly_rate(
			StressEvaluator.get_work_rate_per_game_hour(is_working)
		)
		_net_rate_label.text = "Net stress rate: %s" % _format_hourly_rate(
			StressEvaluator.get_stress_rate_per_game_hour(average, is_working)
		)

	for child in $Scroller/Panel.get_children():
		if child is DebugPanelGroup:
			child.update()

func _format_hourly_rate(rate: float) -> String:
	return ("+" if rate > 0.0 else "") + ("%.0f/h" % rate)

func _connect_signals() -> void:
	_rat.needs.stat_changed.connect(_update)
	_rat.personality.stat_changed.connect(_update)
	_rat.status.stat_changed.connect(_update)
	_rat.other.stat_changed.connect(_update)

func _disconnect_signals() -> void:
	_rat.needs.stat_changed.disconnect(_update)
	_rat.personality.stat_changed.disconnect(_update)
	_rat.status.stat_changed.disconnect(_update)
	_rat.other.stat_changed.disconnect(_update)

func inspect_rat(rat: Rat) -> void:
	if !_rat:
		_rat = rat
		_initialize()

		visible = true
	else:
		_disconnect_signals()
		_rat = rat

	_connect_signals()
	_update()
