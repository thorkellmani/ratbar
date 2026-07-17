class_name DebugPanelGroup extends FoldableContainer

var stat_row := preload("res://debug/panel_row/debug_panel_stat_row.tscn")

@onready var _vbox: VBoxContainer = VBoxContainer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	folded = true
	add_child(_vbox)

func add_child_row(label: String, getter: Callable, setter: Callable) -> void:
	var input: DebugPanelStatRow =  stat_row.instantiate()
	_vbox.add_child(input)
	input.field_label.text = label
	input.bind(getter, setter)

func update() -> void:
	for child in _vbox.get_children():
		if child is DebugPanelStatRow:
			child.update_field()
