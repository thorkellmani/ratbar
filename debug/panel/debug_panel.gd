extends CanvasLayer

signal assign_job_requested(rat: Rat, job: Job)
signal generate_rat_requested

var _rat: Rat


@onready var _job_manager: JobManager = get_parent().get_node("JobManager")

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
	"Needs": func():
		var result := {}
		for stat_name in _rat.needs.get_keys():
			result[stat_name] = {
				"get": func(): return _rat.needs.get(stat_name),
				"set": func(value): _rat.needs.set(stat_name, value),
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
	"Other": func():
		var result := {}
		for key in _rat.other.get_keys():
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
	for child in $Scroller/Panel.get_children():
		if child is DebugPanelGroup:
			child.update()

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
