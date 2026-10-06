extends Resource
class_name TTableRes

@export
var inputs: Array[String]
@export
var rows: Array[TRowRes]

var states: Array[String]:
	get():
		var r_states: Array[String]
		for r in rows:
			r_states.append(r.state)
		return r_states

func _init(p_inputs: Array[String], p_rows: Array[TRowRes]) -> void:
	rows = p_rows
	inputs = p_inputs

func print_inputs():
	var print_statement = "  ||"
	for s in inputs:
		print_statement += " %s " % s
	print(print_statement)
