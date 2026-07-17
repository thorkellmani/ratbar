class_name DebugPanelStatRow extends VBoxContainer

@onready var field_value: LineEdit = $Values/Value
@onready var field_label: Label = $Values/Item

var _stat_getter: Callable
var _stat_setter: Callable

func bind(getter: Callable, setter: Callable) -> void:
	_stat_getter = getter
	_stat_setter = setter

	#connect debug input update to update rat stat
	field_value.text_submitted.connect(func(updated_value: String):
		_stat_setter.call(updated_value.to_float())
	)

func update_field() -> void:
	if _stat_getter is Callable and _stat_setter is Callable:
		var stat = _stat_getter.call()
		if stat is float or stat is int:
			field_value.text = "%.0f" % stat
		else:
			field_value.text = str(stat)
