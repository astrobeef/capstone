extends Node2D
class_name Automata2D

const STATE_OFFSET = Vector2(300,250)

const STATE_SCENE = preload("res://state_2d.tscn")
const TTABLE_SCENE = preload("res://transition_table_gui.tscn")

@export
var table: TTableRes

var _current_state: String

func _ready() -> void:
	_create_states()
	_create_ttable()
	_reset()

func _create_ttable() -> void:
	var table_node := TTABLE_SCENE.instantiate() as TransitionTableGUI
	table_node.table = table
	add_child(table_node)

func _create_states() -> void:
	for index in range(table.rows.size()):
		var state_row := table.rows[index]
		var state_node := STATE_SCENE.instantiate() as State2D
		state_node.name = state_row.state
		state_node.label_name = state_row.state
		state_node.is_start = state_row.state == table.start_state
		state_node.is_accepting = state_row.state in table.accepting_states
		state_node.position = STATE_OFFSET + Vector2(index * 140, 0)
		add_child(state_node)

func _reset() -> void:
	_current_state = table.start_state

func step(input: String) -> void:
	var input_index := table.inputs.find(input)
	for state_row in table.rows:
		if state_row.state == _current_state:
			_current_state = state_row.row[input_index]
			return
