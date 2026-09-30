extends Area2D
class_name SelectableArea2D

enum STATE {NOT = -1, SECONDARY_SELECT = 0, PRIME_SELECTED = 1, PRIME_SELECTED_AND_HELD = 2}
signal state_changed(old: STATE, new: STATE)

@export
var select_state: STATE:
	get():
		return _select_state
	set(state):
		if state != _select_state:
			state_changed.emit(_select_state, state)
			_select_state = state

var _select_state := STATE.NOT

# Godot built-in. Ctrl+Click to read more.
func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	# `exact_match` true to avoid firing multiple inputs
	var do_select_new: bool = event.is_action_pressed("Select New Circle", false, true)
	# `exact_match` true to avoid firing multiple inputs
	var do_append_select: bool = event.is_action_pressed("Append Select Circle", false, true)
	if !do_select_new && !do_append_select:
		return
	match select_state:
		STATE.NOT:
			if do_select_new || do_append_select:
				select_state = STATE.PRIME_SELECTED_AND_HELD
				if do_select_new:
					_clear_other_selections()
				if do_append_select:
					_make_secondary_other_selections()
		STATE.SECONDARY_SELECT:
			select_state = STATE.PRIME_SELECTED_AND_HELD
			if do_select_new:
				_clear_other_selections()
			elif do_append_select:
				_make_secondary_other_selections()
		STATE.PRIME_SELECTED:
			if do_select_new:
				select_state = STATE.PRIME_SELECTED_AND_HELD
				_clear_other_selections()
			elif do_append_select:
				select_state = STATE.NOT
		STATE.PRIME_SELECTED_AND_HELD:
			pass

func _clear_other_selections():
	var areas = _get_selectable_areas_in_scene()
	for a in areas:
		if a != self && a.select_state != STATE.NOT:
			a.select_state = STATE.NOT

func _make_secondary_other_selections():
	var areas = _get_selectable_areas_in_scene()
	for a in areas:
		if a != self && (a.select_state == STATE.PRIME_SELECTED || a.select_state == STATE.PRIME_SELECTED_AND_HELD):
			a.select_state = STATE.SECONDARY_SELECT

func _input(event: InputEvent) -> void:
	var do_select_new_released = event.is_action_released("Select New Circle", true)
	var do_append_select_released = event.is_action_released("Append Select Circle", true)
	if do_select_new_released || do_append_select_released:
		var overlaps_mouse = Globals.get_circles_at_mouse().has(owner)
		if overlaps_mouse && select_state != STATE.PRIME_SELECTED_AND_HELD:
			return	# If it overlaps, then `_input_event` will handle functionality
		match select_state:
			STATE.NOT:
				pass
			STATE.SECONDARY_SELECT:
				if do_select_new_released:
					select_state = STATE.NOT
			STATE.PRIME_SELECTED:
				if do_select_new_released:
					select_state = STATE.NOT
				elif do_append_select_released:
					select_state = STATE.SECONDARY_SELECT
			STATE.PRIME_SELECTED_AND_HELD:
				select_state = STATE.PRIME_SELECTED

func _get_selectable_areas_in_scene() -> Array[SelectableArea2D]:
	var nodes := get_tree().get_nodes_in_group("SelectableArea2D")
	var areas : Array[SelectableArea2D]
	for n in nodes:
		areas.append(n as SelectableArea2D)
	return areas
