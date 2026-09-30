extends Node

var _draw_root_2D: DrawRoot2D:
	get():
		return get_parent().get_node("DrawRoot2D")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Create Circle"):
		_draw_root_2D.add_circle_at_mouse()
	if event.is_action_pressed("Remove Circle"):
		_draw_root_2D.try_remove_circle_at_mouse()
