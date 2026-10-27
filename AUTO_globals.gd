extends Node2D
class_name AutoGlobals

func get_circles_at_mouse() -> Array[DrawCircle2D]:
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

func deep_copy_table(source: TTableRes) -> TTableRes:
	var copy := source.duplicate(true) as TTableRes
	# Must manually duplicate custom resources
	for i in range(source.rows.size()):
		var source_row := source.rows[i]
		if source_row != null:
			copy.rows[i] = source_row.duplicate(true) as TRowRes
	return copy
