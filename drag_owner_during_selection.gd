extends Node2D

var _selectable_area_2d: SelectableArea2D:
	get():
		return get_parent()

var _do_drag := false

var _begin_drag_timer: Timer

func _enter_tree() -> void:
	_selectable_area_2d.state_changed.connect(_on_state_changed, CONNECT_DEFERRED)
	_begin_drag_timer = Timer.new()
	_begin_drag_timer.autostart = false
	_begin_drag_timer.one_shot = true
	_begin_drag_timer.wait_time = 0.15
	self.add_child.call_deferred(_begin_drag_timer)

func _on_state_changed(old: SelectableArea2D.STATE, new: SelectableArea2D.STATE):
	match new:
		SelectableArea2D.STATE.NOT, SelectableArea2D.STATE.SECONDARY_SELECT, SelectableArea2D.STATE.PRIME_SELECTED:
			_do_drag = false
			_begin_drag_timer.stop()
		SelectableArea2D.STATE.PRIME_SELECTED_AND_HELD:
			if _begin_drag_timer.is_stopped():
				_begin_drag_timer.start()
				if !_begin_drag_timer.timeout.is_connected(_on_timeout):
					_begin_drag_timer.timeout.connect(_on_timeout, ConnectFlags.CONNECT_ONE_SHOT)

func _on_timeout():
	_do_drag = true

func _input(event: InputEvent) -> void:
	if _do_drag:
		owner.global_position = get_global_mouse_position()
