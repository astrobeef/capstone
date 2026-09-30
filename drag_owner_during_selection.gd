extends Node

var _selectable_area_2d: SelectableArea2D:
	get():
		return get_parent()

func _enter_tree() -> void:
	_selectable_area_2d.selected.connect(_on_selected)

func _on_selected(is_selected: bool):
	if is_selected:
		pass
