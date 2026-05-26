extends Control

signal assign_job_requested
signal generate_rat_requested

var stat_row = preload("res://debug/panel_row/debug_panel_stat_row.tscn")
var action_row = preload("res://debug/panel_button/panel_button.tscn")

var _rat: Rat

var collapsible_panels := {
	"Personality": RatConstants.TRAIT.keys(),
	"Mood": RatConstants.MOOD.keys(),
	"Status": RatConstants.STATUS.keys(),
	"Vice": RatConstants.VICE.keys(),
}

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for panel in collapsible_panels:
		var foldable := FoldableContainer.new()
		var vBox := VBoxContainer.new()
		add_child(foldable)
		foldable.title = panel
		foldable.folded = true
		foldable.add_child(vBox)

		for key in collapsible_panels[panel]:
			var row = stat_row.instantiate()
			vBox.add_child(row)
			row.label.text = key
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
	for panel in collapsible_panels:
		for key in collapsible_panels[panel]:
			$DebugPanelRow.value = _rat.get_stat(panel.to_lower(), key)
