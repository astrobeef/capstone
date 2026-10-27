extends Node2D

@export
var puzzle: PuzzleRes

var _user_table: TTableRes

var _table_view: TransitionTableGUI:
	get():
		return get_node("./CanvasLayer/MarginContainer/TransitionTableGUI")

var _puzzle_panel: PuzzlePanel:
	get():
		return get_node("./CanvasLayer/PuzzlePanel")

var _automata: Automata2D:
	get():
		return get_node("./Automata2D")

func _enter_tree() -> void:
	_user_table = puzzle.create_user_table()
	_automata.table = _user_table
	_table_view.table = _user_table

func _ready() -> void:
	_table_view.transition_selected.connect(_on_transition_selected)
	_puzzle_panel.check_requested.connect(_on_check_requested)
	_puzzle_panel.restore_requested.connect(_on_restore_requested)
	_puzzle_panel.configure_puzzle(puzzle.title, _requirements_text())

func _on_transition_selected(origin_state: String, input_index: int, new_destination: String, _previous_destination: String) -> void:
	for state_row in _user_table.rows:
		if state_row.state == origin_state:
			state_row.row[input_index] = new_destination
			break
	_puzzle_panel.clear_results()

func _on_check_requested() -> void:
	var results := puzzle.evaluate(_user_table)
	var lines := PackedStringArray()
	for index in range(puzzle.test_inputs.size()):
		var expected := puzzle.expected_acceptance[index]
		var actual := results[index]
		var outcome := "Pass" if actual == expected else "Fail"
		lines.append("%s: expected %s, actual %s - %s" % [_input_text(puzzle.test_inputs[index]), _acceptance_text(expected), _acceptance_text(actual),outcome])
	_puzzle_panel.show_results("\n".join(lines), puzzle.is_puzzle_solved(results))

func _on_restore_requested() -> void:
	_user_table = puzzle.create_user_table()
	_automata.table = _user_table
	_table_view.table = _user_table
	_table_view.rebuild_table()
	_puzzle_panel.clear_results()

func _requirements_text() -> String:
	var lines := PackedStringArray()
	for index in range(puzzle.test_inputs.size()):
		lines.append("%s: must %s" % [_input_text(puzzle.test_inputs[index]), _acceptance_text(puzzle.expected_acceptance[index])])
	return "\n".join(lines)

func _acceptance_text(accepts: bool) -> String:
	return "Accept" if accepts else "Reject"

func _input_text(input_string: String) -> String:
	if input_string.is_empty():
		return "(empty)"
	return '"%s"' % input_string
