extends Node
class_name AutoEval

func table_accepts_input(table: TTableRes, input: String) -> bool:
	var current_state := table.start_state
	for c in input:
		var input_index := table.inputs.find(c)
		for r in table.rows:
			if r.state == current_state:
				current_state = r.row[input_index]
				break
	return current_state in table.accepting_states

func table_acceptance_of_inputs(table: TTableRes, inputs: Array[String]) -> Array[bool]:
	var results: Array[bool] = []
	for input in inputs:
		var accepts := table_accepts_input(table, input)
		results.append(accepts)
	return results
