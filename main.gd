extends Node

func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if $RatManager.RATS.size() > 0 && $AssignJobButton.disabled:
		$AssignJobButton.disabled = false
	elif $RatManager.RATS.size() < 1 && !$AssignJobButton.disabled:
		$AssignJobButton.disabled = true
