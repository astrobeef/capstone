extends Node2D
class_name Automata2D

const STATE_OFFSET = Vector2(0,0)

const STATE_SCENE = preload("res://state_2d.tscn")

@export
var table: TTableRes

signal trace_changed(current_state: String, consumed: int, total: int, finished: bool, accepted: bool)

var _current_state: String
var _trace_input := ""
var _trace_index := 0
var _trace_active := false

func _ready() -> void:
	if table != null:
		set_table(table)

func set_table(value: TTableRes) -> void:
	clear_trace()
	table = value
	for child in get_children():
		if child is State2D:
			remove_child(child)
			child.queue_free()
	_create_states()
	_reset()

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

func begin_trace(input_string: String) -> void:
	_trace_input = input_string
	_trace_index = 0
	_trace_active = true
	_reset()
	_update_current_visuals()
	_emit_trace_changed()

func advance_trace() -> void:
	if not _trace_active or _trace_index == _trace_input.length():
		return
	step(_trace_input[_trace_index])
	_trace_index += 1
	_update_current_visuals()
	_emit_trace_changed()

func clear_trace() -> void:
	_trace_active = false
	_trace_input = ""
	_trace_index = 0
	_update_current_visuals()

func _update_current_visuals() -> void:
	for child in get_children():
		if child is State2D:
			child.set_current(_trace_active and child.label_name == _current_state)

func _emit_trace_changed() -> void:
	var finished := _trace_index == _trace_input.length()
	var accepted := finished and _current_state in table.accepting_states
	trace_changed.emit(_current_state, _trace_index, _trace_input.length(), finished, accepted)
