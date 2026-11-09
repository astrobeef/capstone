extends Node2D
class_name TransitionDiagram2D

func refresh_from_table(table: TTableRes) -> void:
	for route in get_children():
		var symbols: Array[String] = []
		if table != null:
			for state_row in table.rows:
				for input_index in range(table.inputs.size()):
					var route_name := "%s_to_%s" % [state_row.state, state_row.row[input_index]]
					if route_name == str(route.name):
						symbols.append(table.inputs[input_index])
		(route as Transition2D).set_inputs(symbols)
