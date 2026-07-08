extends Node2D

var picked_rat: Rat

func _ready() -> void:
	if OS.is_debug_build():
		$RatManager.rat_clicked.connect(_on_rat_clicked)
		$DebugUI.assign_job_requested.connect($JobManager._on_assign_job_button_pressed)
		$DebugUI.generate_rat_requested.connect($RatManager.generate_rat)

func _on_rat_clicked(rat: Rat) -> void:
	$DebugUI.inspect_rat(rat)
