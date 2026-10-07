extends Node2D
class_name Automata2D

const STATE_SCENE = preload("res://state_2d.tscn")

@export
var table: TTableRes

var current_state: String

func _ready() -> void:
	create_states()
	reset()

func create_states() -> void:
	for index in range(table.rows.size()):
		var state_row := table.rows[index]
		var state_node := STATE_SCENE.instantiate() as State2D
		state_node.name = state_row.state
		state_node.label_name = state_row.state
		state_node.position = Vector2(100 + index * 140, 100)
		add_child(state_node)

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
