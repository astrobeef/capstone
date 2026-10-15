extends Node2D
class_name Automata2D

const STATE_SCENE = preload("res://state_2d.tscn")

@export
var table: TTableRes

var _current_state: String

func _ready() -> void:
	create_states()
	reset()

func create_states() -> void:
	for index in range(table.rows.size()):
		var state_row := table.rows[index]
		var state_node := STATE_SCENE.instantiate() as State2D
		state_node.name = state_row.state
		state_node.label_name = state_row.state
		state_node.is_start = state_row.state == table.start_state
		state_node.is_accepting = state_row.state in table.accepting_states
		state_node.position = Vector2(100 + index * 140, 100)
		if state_row.state == table.start_state:
			state_node.condition_type = State2D.CONDITION_TYPE.START
		elif state_row.state in table.accepting_states:
			state_node.condition_type = State2D.CONDITION_TYPE.FINAL
		else:
			state_node.condition_type = State2D.CONDITION_TYPE.INTER
		add_child(state_node)

func reset() -> void:
	_current_state = table.start_state

func step(input: String) -> void:
	var input_index := table.inputs.find(input)
	for state_row in table.rows:
		if state_row.state == _current_state:
			_current_state = state_row.row[input_index]
			return

func is_accepting() -> bool:
	return _current_state in table.accepting_states

func _unhandled_input(event: InputEvent) -> void:
	var state := _state_under_mouse()
	if state == null:
		return
	if event.is_action_pressed("Toggle Accept"):
		if state.condition_type == State2D.CONDITION_TYPE.FINAL:
			state.condition_type = State2D.CONDITION_TYPE.INTER
		else:
			state.condition_type = State2D.CONDITION_TYPE.FINAL
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("Set Start State"):
		_make_start(state)
		get_viewport().set_input_as_handled()

func _make_start(chosen: State2D) -> void:
	for child in get_children():
		var state := child as State2D
		if state == null:
			continue
		if state == chosen:
			state.condition_type = State2D.CONDITION_TYPE.START
		elif state.condition_type == State2D.CONDITION_TYPE.START:
			state.condition_type = State2D.CONDITION_TYPE.INTER

func _state_under_mouse() -> State2D:
	var mouse := get_global_mouse_position()
	for child in get_children():
		var state := child as State2D
		if state != null and mouse.distance_to(state.global_position) <= 48.0:
			return state
	return null
