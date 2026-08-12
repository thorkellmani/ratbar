class_name CamaraderieFields extends BaseStatGroup

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
		camaraderie[ratId] = clamp(camaraderie[ratId] + modifier, _get_min(), _get_max())
		stat_changed.emit()
