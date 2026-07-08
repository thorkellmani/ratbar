extends Control

signal assign_job_requested
signal generate_rat_requested

var stat_row = preload("res://debug/panel_row/debug_panel_stat_row.tscn")
var action_row = preload("res://debug/panel_button/panel_button.tscn")

var _rat: Rat

var stat_groups := {
	"Personality": {"accessor": "personality", "enum": RatConstants.TRAIT},
	"Mood": {"accessor": "mood", "enum": RatConstants.MOOD},
	"Status": {"accessor": "status", "enum": RatConstants.STATUS},
	"Vice": {"accessor": "vice", "enum": RatConstants.VICE},
}

# Dictionary mapping stat keys to their corresponding LineEdit inputs.
var _stat_inputs: Dictionary[String, LineEdit] = {}

var actions := {
	"ASSIGN_JOB": {
		"label": "Assign Job",
		"signal": assign_job_requested
	},
	"GENERATE_RAT": {
		"label": "Generate Rat",
		"signal": generate_rat_requested,
	},
}

func _make_stat_key(panel: String, stat: String) -> String:
	return panel + '-' + stat

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for stat_group in stat_groups:
		var ui_stat_group_container := FoldableContainer.new()
		var vBox := VBoxContainer.new()
		add_child(ui_stat_group_container)
		ui_stat_group_container.title = stat_group
		ui_stat_group_container.folded = true
		ui_stat_group_container.add_child(vBox)

		for stat in stat_groups[stat_group]:
			var ui_stat_row: DebugPanelStatRow =  stat_row.instantiate()
			vBox.add_child(ui_stat_row)
			var stat_key:= _make_stat_key(stat_group, stat)
			_stat_inputs[stat_key] = ui_stat_row.value
			ui_stat_row.label.text = stat

	for action in actions:
		var button: Button = action_row.instantiate()
		add_child(button)
		button.text = actions[action].label
		button.pressed.connect(func():
			actions[action].signal.emit()
		)

func inspect_rat(rat: Rat) -> void:
	_rat = rat

	if !visible:
		visible = true

	_update()

func _update() -> void:
	for group in stat_groups:
		var accessor = stat_groups[group]["accessor"]
		var enum_dict = stat_groups[group]["enum"]
		for stat in enum_dict:
			var stat_key = _make_stat_key(group, stat)
			_stat_inputs[stat_key].text = str(_rat.get_stat(accessor, enum_dict[stat]))
