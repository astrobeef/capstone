extends Node2D

var puzzle: PuzzleRes
var _user_table: TTableRes

var _table_view: TransitionTableGUI:
	get():
		return get_node_or_null("./CanvasLayer/UIRoot/Margin/Columns/RightColumn/TableSlot/TransitionTableGUI")

var _puzzle_panel: PuzzlePanel:
	get():
		return get_node_or_null("./CanvasLayer/UIRoot/Margin/Columns/LeftColumn/PanelScroll/PuzzlePanel")

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
		return get_node_or_null("./CanvasLayer/UIRoot/Margin/Columns/LeftColumn/PuzzleNavigation")

var _selection: Control:
	get():
		return get_node_or_null("./CanvasLayer/PuzzleSelection")

var _columns: Control:
	get():
		return get_node_or_null("./CanvasLayer/UIRoot/Margin/Columns")

var _diagram_host: Control:
	get():
		return get_node_or_null("./CanvasLayer/UIRoot/Margin/Columns/RightColumn/DiagramHost")

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
	get_viewport().size_changed.connect(_place_diagram)
	_diagram_host.resized.connect(_place_diagram)
	# Resume a prior session; otherwise open the puzzle list (the existing hub).
	if _progression.has_saved_progress():
		_progression.select_puzzle(_progression.get_resume_index())
	else:
		_show_selection()
	await get_tree().process_frame
	_place_diagram()

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
	await get_tree().process_frame
	_place_diagram()

func _on_transition_selected(origin_state: String, input_index: int, new_destination: String, _previous_destination: String) -> void:
	for state_row in _user_table.rows:
		if state_row.state == origin_state:
			state_row.row[input_index] = new_destination
			break
	_diagram.refresh_from_table(_user_table)
	_puzzle_panel.clear_results()
	_progression.save_progress()

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
	if _columns != null:
		_columns.visible = value
	_selection.visible = not value

func _place_diagram() -> void:
	if _automata == null or _diagram_host == null or not _automata.visible:
		return
	var rect := _diagram_host.get_global_rect()
	if rect.size.x < 8.0 or rect.size.y < 8.0:
		return
	var state_count := 2
	if _user_table != null:
		state_count = maxi(1, _user_table.rows.size())
	var diagram_width := float((state_count - 1) * 140 + 80)
	var x := rect.position.x + maxf(16.0, (rect.size.x - diagram_width) * 0.5)
	var y := rect.position.y + rect.size.y * 0.45
	_automata.global_position = Vector2(x, y)

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
