extends CanvasLayer

signal assign_job_requested(rat: Rat, job: JobConstants.JOB)
signal generate_rat_requested

var _rat: Rat

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
		for stat_name in _rat.personality.get_keys():
			result[stat_name] = {
				"get": func(): return _rat.personality.get(stat_name),
				"set": func(value): _rat.personality.set(stat_name, value),
			}
		return result,
	"Mood": func():
		var result := {}
		for stat_name in _rat.mood.get_keys():
			result[stat_name] = {
				"get": func(): return _rat.mood.get(stat_name),
				"set": func(value): _rat.mood.set(stat_name, value),
			}
		return result,
	"Statuses": func():
		var result := {}
		for stat_name in _rat.status.get_keys():
			result[stat_name] = {
				"get": func(): return _rat.status.get(stat_name),
				"set": func(value): _rat.status.set(stat_name, value),
			}
		return result,
	"Job skills": func():
		var result := {}
		for stat_name in _rat.job_skills.get_keys():
			result[stat_name] = {
				"get": func(): return _rat._job_skills.get(stat_name),
				"set": func(value): _rat._job_skills.set(stat_name, value),
			}
		return result,
	"Vice": func():
		var result := {}
		for stat_name in _rat.vice.get_keys():
			result[stat_name] = {
				"get": func(): return _rat.vice.get(stat_name),
				"set": func(value): _rat.vice.set(stat_name, value),
			}
		return result,
	"Other": func():
		var result := {}
		for key in _rat.other.get_keys():
			result[key] = {
				"get": func(): return _rat.other.get(key),
				"set": func(value): _rat.other.set(key, value)
			}
		return result
}

var assign_job_group = {
	"Head cook": JobConstants.JOB.HEAD_COOK,
	"Line cook": JobConstants.JOB.LINE_COOK,
	"Prep cook": JobConstants.JOB.PREP_COOK,
	"Dishwasher": JobConstants.JOB.DISHWASHER,
	"Bartender": JobConstants.JOB.BARTENDER,
	"Clear job": JobConstants.JOB.UNASSIGNED
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
	for job in assign_job_group:
		job_vbox.add_child(generate_button(job, func(): assign_job_requested.emit(_rat, assign_job_group[job])))


	for action in actions:
		$Scroller/Panel.add_child(generate_button(actions[action].label, func(): actions[action].signal.emit()))
	$Scroller/Panel.add_child(TimeButton.new())
	$Scroller/Panel.add_child(PauseButton.new())



func _update() -> void:
	for child in $Scroller/Panel.get_children():
		if child is DebugPanelGroup:
			child.update()

func _connect_signals() -> void:
	_rat.mood.stat_changed.connect(_update)
	_rat.personality.stat_changed.connect(_update)
	_rat.status.stat_changed.connect(_update)
	_rat.vice.stat_changed.connect(_update)
	_rat.job_skills.stat_changed.connect(_update)
	_rat.other.stat_changed.connect(_update)

func _disconnect_signals() -> void:
	_rat.mood.stat_changed.disconnect(_update)
	_rat.personality.stat_changed.disconnect(_update)
	_rat.status.stat_changed.disconnect(_update)
	_rat.vice.stat_changed.disconnect(_update)
	_rat.job_skills.stat_changed.disconnect(_update)
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
