extends Node2D

var picked_rat: Rat

func _ready() -> void:
	if OS.is_debug_build():
		for key in Rat.TRAIT:
			var label = Label.new()
			label.name = key
			$DebugControls.add_child(label)
		for key in Rat.MOOD:
			var label = Label.new()
			label.name = key
			$DebugControls.add_child(label)
		for key in Rat.STATUS:
			var label = Label.new()
			label.name = key
			print(key)
			$DebugControls.add_child(label)
		for key in ["currency", "owner_relationship"]:
			var label = Label.new()
			label.name = key
			$DebugControls.add_child(label)
		$RatManager.rat_clicked.connect(_on_rat_clicked)
		
func _on_rat_clicked(rat: Rat) -> void:
	picked_rat = rat
	$DebugControls.show()

func _process(_delta: float) -> void:
	if picked_rat and $DebugControls.visible:
		for key in picked_rat.TRAIT:
			$DebugControls.get_node(key).text = "%s: %.1f" % [key, picked_rat.personality[Rat.TRAIT[key]]]
		for key in picked_rat.MOOD:
			$DebugControls.get_node(key).text = "%s: %.1f" % [key, picked_rat.mood[Rat.MOOD[key]]]
