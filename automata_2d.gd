extends Node2D
class_name Automata2D

@export
var table: TTableRes

var current_state: String

func _ready() -> void:
	reset()
	print(current_state)
	step("1")
	print(current_state)
	step("0")
	print(current_state)
	print(is_accepting())

func reset() -> void:
	current_state = table.start_state

func step(input: String) -> void:
	var input_index := table.inputs.find(input)
	for state_row in table.rows:
		if state_row.state == current_state:
			current_state = state_row.row[input_index]
			return

func is_accepting() -> bool:
	return current_state in table.accepting_states
