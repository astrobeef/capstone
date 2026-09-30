extends Node

const PRIME_SELECT_COLOR := Color.YELLOW
const SECONDARY_SELECT_COLOR := Color.GREEN

var _selectable_area_2d: SelectableArea2D:
	get():
		return get_parent()

var _draw_circle_2D: DrawCircle2D:
	get():
		return owner

var _previous_color: Color

func _enter_tree() -> void:
	_selectable_area_2d.state_changed.connect(_on_select_state_changed, ConnectFlags.CONNECT_DEFERRED)

func _on_select_state_changed(old: SelectableArea2D.STATE, new: SelectableArea2D.STATE):
	if new > -1:
		if _draw_circle_2D.stroke_color != PRIME_SELECT_COLOR && _draw_circle_2D.stroke_color != SECONDARY_SELECT_COLOR:
			_previous_color = _draw_circle_2D.stroke_color
		match new:
			SelectableArea2D.STATE.PRIME_SELECTED, SelectableArea2D.STATE.PRIME_SELECTED_AND_HELD:
				_draw_circle_2D.stroke_color = PRIME_SELECT_COLOR
			SelectableArea2D.STATE.SECONDARY_SELECT:
				_draw_circle_2D.stroke_color = SECONDARY_SELECT_COLOR
	else:
		_draw_circle_2D.stroke_color = _previous_color
