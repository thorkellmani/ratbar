extends Node

func _ready() -> void:
	$RatManager.generate_rat()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
