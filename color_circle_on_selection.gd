extends Node

var _selectable_area_2d: SelectableArea2D:
	get():
		return get_parent()

var _draw_circle_2D: DrawCircle2D:
	get():
		return owner

var _previous_color: Color

func _enter_tree() -> void:
	_selectable_area_2d.selected.connect(_on_selected)

func _on_selected(is_selected: bool):
	if is_selected:
		_previous_color = _draw_circle_2D.stroke_color
		_draw_circle_2D.stroke_color = Color.YELLOW
	else:
		_draw_circle_2D.stroke_color = _previous_color
