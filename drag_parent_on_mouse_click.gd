extends Area2D
class_name SelectableArea2D

signal selected(is_selected: bool)

var _selected := false

# Godot built-in. Ctrl+Click to read more.
func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("Select Circle"):
		_selected = true
		selected.emit(true)

# Godot built-in. Ctrl+Click to read more.
func _input(event: InputEvent) -> void:
	if event.is_action_released("Select Circle"):
		_selected = false
		selected.emit(false)
	elif _selected:
		get_parent().global_position = get_global_mouse_position()
