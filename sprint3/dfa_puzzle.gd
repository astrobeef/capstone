extends Node2D

var puzzle: PuzzleRes
var _user_table: TTableRes

var _table_view: TransitionTableGUI:
	get():
		return get_node_or_null("./CanvasLayer/MarginContainer/TransitionTableGUI")

var _puzzle_panel: PuzzlePanel:
	get():
		return get_node_or_null("./CanvasLayer/PanelScroll/PuzzlePanel")

var _automata: Automata2D:
	get():
		return get_node_or_null("./Automata2D")

var _diagram: TransitionDiagram2D:
	get():
		return get_node_or_null("./Automata2D/TransitionDiagram2D")

var _progression: PuzzleProgression:
	get():
		return get_node_or_null("./PuzzleProgression")

var _navigation: HBoxContainer:
	get():
		return get_node_or_null("./CanvasLayer/PuzzleNavigation")

var _selection: Control:
	get():
		return get_node_or_null("./CanvasLayer/PuzzleSelection")

func _ready() -> void:
	_table_view.transition_selected.connect(_on_transition_selected)
	_puzzle_panel.check_requested.connect(_on_check_requested)
	_puzzle_panel.restore_requested.connect(_on_restore_requested)
	_progression.puzzle_selected.connect(_on_puzzle_selected)
	_progression.progression_changed.connect(_refresh_navigation)
	_selection.puzzle_requested.connect(_progression.select_puzzle)
	_navigation.previous_requested.connect(func(): _progression.select_puzzle(_progression.current_puzzle_index - 1))
	_navigation.next_requested.connect(func(): _progression.select_puzzle(_progression.current_puzzle_index + 1))
	_navigation.return_requested.connect(_show_selection)
	_progression.select_puzzle(0)

func _on_puzzle_selected(selected_puzzle: PuzzleRes, table: TTableRes) -> void:
	puzzle = selected_puzzle
	_user_table = table
	_automata.set_table(_user_table)
	_table_view.table = _user_table
	_table_view.rebuild_table()
	_diagram.refresh_from_table(_user_table)
	_puzzle_panel.configure_puzzle(puzzle.title, _requirements_text())
	_set_puzzle_visible(true)
	_refresh_navigation()

func _on_transition_selected(origin_state: String, input_index: int, new_destination: String, _previous_destination: String) -> void:
	for state_row in _user_table.rows:
		if state_row.state == origin_state:
			state_row.row[input_index] = new_destination
			break
	_diagram.refresh_from_table(_user_table)
	_puzzle_panel.clear_results()

func _on_check_requested() -> void:
	var results := puzzle.evaluate(_user_table)
	var lines := PackedStringArray()
	for index in range(puzzle.test_inputs.size()):
		var expected := puzzle.expected_acceptance[index]
		var actual := results[index]
		var outcome := "Pass" if actual == expected else "Fail"
		lines.append("%s: expected %s, actual %s - %s" % [_input_text(puzzle.test_inputs[index]), _acceptance_text(expected), _acceptance_text(actual), outcome])
	var solved := puzzle.is_puzzle_solved(results)
	_puzzle_panel.show_results("\n".join(lines), solved)
	if solved:
		_progression.mark_current_complete()

func _on_restore_requested() -> void:
	_progression.restore_current()

func _refresh_navigation() -> void:
	var index := _progression.current_puzzle_index
	_navigation.set_navigation_available(_progression.is_unlocked(index - 1), _progression.is_unlocked(index + 1))
	_selection.refresh(_progression)

func _show_selection() -> void:
	_selection.refresh(_progression)
	_set_puzzle_visible(false)

func _set_puzzle_visible(value: bool) -> void:
	_automata.visible = value
	get_node("./CanvasLayer/PanelScroll").visible = value
	get_node("./CanvasLayer/DiagramLegend").visible = value
	_navigation.visible = value
	_selection.visible = not value

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
