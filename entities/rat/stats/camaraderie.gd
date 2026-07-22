class_name Camaraderie extends BaseStatGroup

func _init() -> void:
	_min = -100
	_max = 100

@export var camaraderie: Dictionary[int, float] = {}

func add_relationship(ratId: int, value = 0.0) -> void:
	camaraderie[ratId] = value
	stat_changed.emit()

func remove_relationship(ratId: int) -> void:
	if ratId in camaraderie:
		camaraderie.erase(ratId)
		stat_changed.emit()

func update_relationship(ratId: int, modifier: float) -> void:
	if ratId in camaraderie:
		camaraderie[ratId] = clamp(camaraderie[ratId] + modifier, _min, _max)
		stat_changed.emit()
