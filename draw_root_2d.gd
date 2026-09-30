extends Node2D
class_name DrawRoot2D	# Giving classname since this class is referenced elsewhere (`prototype_inputs.gd`)

## Preload scene resource to be instanced on call (see `preload` for more info)
var _draw_circle_scene: PackedScene = preload("res://draw_circle_2d.tscn")

var _drawn_circles: Array[DrawCircle2D] = []

func _enter_tree() -> void:
	_append_preexisting_circles()

func _append_preexisting_circles():
	for c in get_children():
		if c is DrawCircle2D:
			_drawn_circles.append(c)

func add_circle_at_mouse():
	var inst := _draw_circle_scene.instantiate() as DrawCircle2D
	self.add_child(inst)
	inst.global_position = get_global_mouse_position()
	_drawn_circles.append(inst)

func try_remove_circle_at_mouse():
	var circles := _get_circles_at_mouse()
	for c in circles:
		c.queue_free()
		_drawn_circles.erase(c)

func _get_circles_at_mouse() -> Array[DrawCircle2D]:
	var hit_circles: Array[DrawCircle2D]
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var hits := space_state.intersect_point(query)
	for h in hits:
		if h["collider"].owner is DrawCircle2D:
			hit_circles.append(h["collider"].owner)
	return hit_circles
