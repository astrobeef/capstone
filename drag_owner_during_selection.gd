extends Node2D

var _selectable_area_2d: SelectableArea2D:
	get():
		return get_parent()

var _do_drag := false

func _enter_tree() -> void:
	_selectable_area_2d.state_changed.connect(_on_state_changed, CONNECT_DEFERRED)

func _on_state_changed(old: SelectableArea2D.STATE, new: SelectableArea2D.STATE):
	match new:
		SelectableArea2D.STATE.NOT, SelectableArea2D.STATE.SECONDARY_SELECT, SelectableArea2D.STATE.PRIME_SELECTED:
			_do_drag = false
		SelectableArea2D.STATE.PRIME_SELECTED_AND_HELD:
			_do_drag = true

func _input(event: InputEvent) -> void:
	if _do_drag:
		owner.global_position = get_global_mouse_position()
