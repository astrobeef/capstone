extends Node2D

func _physics_process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var circles_at_mouse := Globals.get_circles_at_mouse()
	if circles_at_mouse.size() > 0:
		draw_line(Vector2.ZERO, circles_at_mouse[0].global_position - self.global_position, Color.BLUE, 2.0, true)
