extends Node2D

var picked_rat: Rat

func _ready() -> void:
	if OS.is_debug_build():
		$RatManager.rat_clicked.connect(_on_rat_clicked)
		$DebugPanel.assign_job_requested.connect($JobManager._on_assign_job_button_pressed)
		$DebugPanel.generate_rat_requested.connect($RatManager.generate_rat)

func _on_rat_clicked(rat: Rat) -> void:
	$DebugPanel.inspect_rat(rat)

func _process(_delta: float) -> void:
	if picked_rat and $DebugControls.visible:
		for key in picked_rat.TRAIT:
			$DebugControls.get_node(key).text = "%s: %.1f" % [key, picked_rat.personality[RatConstants.TRAIT[key]]]
		for key in picked_rat.MOOD:
			$DebugControls.get_node(key).text = "%s: %.1f" % [key, picked_rat.mood[RatConstants.MOOD[key]]]
		for key in picked_rat.STATUS:
			$DebugControls.get_node(key).text = "%s: %.1f" % [key, picked_rat.statuses[RatConstants.STATUS[key]]]
