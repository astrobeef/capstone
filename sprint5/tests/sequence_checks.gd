extends Node

## Plays the three-puzzle sequence through the running scene.
## Run: Godot --headless --path . res://sprint5/tests/sequence_checks.tscn

const SEQUENCE := [
	"res://sprint4/puzzles/beginner_01.tres",
	"res://sprint4/puzzles/beginner_02.tres",
	"res://sprint3/puzzles/first_puzzle.tres",
]

const SOLUTIONS := {
	"Ends in 1": {"A": ["A", "B"], "B": ["A", "B"]},
	"At least one 1": {"A": ["A", "B"], "B": ["B", "B"]},
	"Find the Double 1": {"A": ["A", "B"], "B": ["A", "C"], "C": ["C", "C"]},
}

# input, then the state after every symbol. The first entry is the start state.
const TRACES := {
	"Ends in 1": {"1": ["A", "B"], "10": ["A", "B", "A"]},
	"At least one 1": {"01": ["A", "A", "B"], "00": ["A", "A", "A"]},
	"Find the Double 1": {"110": ["A", "B", "C", "C"], "101": ["A", "B", "A", "B"]},
}

var _failures: PackedStringArray = []

func _ready() -> void:
	_check_resources()
	await _check_scene()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PuzzleProgression.SAVE_PATH))
	if _failures.is_empty():
		print("SEQUENCE CHECKS PASSED")
		get_tree().quit(0)
	else:
		for failure in _failures:
			print("FAIL: %s" % failure)
		get_tree().quit(1)

func _fail(message: String) -> void:
	_failures.append(message)

func _check_resources() -> void:
	for path in SEQUENCE:
		var puzzle := load(path) as PuzzleRes
		if puzzle == null:
			_fail("%s did not load" % path)
			continue
		var start_results := Eval.table_acceptance_of_inputs(puzzle.source_table, puzzle.test_inputs)
		var start_fails := false
		for i in puzzle.test_inputs.size():
			if start_results[i] != puzzle.expected_acceptance[i]:
				start_fails = true
				break
		if not start_fails:
			_fail("%s starting table already passes" % path)
		var solution: Dictionary = SOLUTIONS[puzzle.title]
		var solved := _apply_solution(puzzle.source_table, solution)
		var solved_results := Eval.table_acceptance_of_inputs(solved, puzzle.test_inputs)
		for i in puzzle.test_inputs.size():
			if solved_results[i] != puzzle.expected_acceptance[i]:
				_fail("%s solution fails on '%s'" % [path, puzzle.test_inputs[i]])
		for input in TRACES[puzzle.title]:
			var states: Array = TRACES[puzzle.title][input]
			var walked := _trace(solved, input)
			if walked != states:
				_fail("%s trace %s walked %s, documented %s" % [puzzle.title, input, walked, states])
			var accepted: bool = solved.accepting_states.has(str(walked[walked.size() - 1]))
			if accepted != Eval.table_accepts_input(solved, input):
				_fail("%s trace %s disagrees with Eval" % [puzzle.title, input])
	_check_single_cell_is_not_enough()

func _check_single_cell_is_not_enough() -> void:
	var puzzle := load(SEQUENCE[2]) as PuzzleRes
	var only_b: Dictionary = SOLUTIONS["Find the Double 1"].duplicate(true)
	only_b["C"] = ["A", "C"]
	var only_c: Dictionary = SOLUTIONS["Find the Double 1"].duplicate(true)
	only_c["B"] = ["A", "A"]
	for partial in [only_b, only_c]:
		var table := _apply_solution(puzzle.source_table, partial)
		var results := Eval.table_acceptance_of_inputs(table, puzzle.test_inputs)
		if results == puzzle.expected_acceptance:
			_fail("changing only one Find the Double 1 cell already solves it")

func _check_scene() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PuzzleProgression.SAVE_PATH))
	var scene := (load("res://sprint3/dfa_puzzle.tscn") as PackedScene).instantiate()
	add_child(scene)
	for _i in 4:
		await get_tree().process_frame
	var progression: PuzzleProgression = scene.get_node("PuzzleProgression")
	if progression.puzzles.size() != SEQUENCE.size():
		_fail("scene has %d puzzles, expected %d" % [progression.puzzles.size(), SEQUENCE.size()])
		return
	for i in SEQUENCE.size():
		if progression.puzzles[i].resource_path != SEQUENCE[i]:
			_fail("scene puzzle %d is %s" % [i, progression.puzzles[i].resource_path])
	var next := _button(scene, "NextButton")
	var previous := _button(scene, "PreviousButton")
	var summary: Label = scene.get_node("CanvasLayer/UIRoot/Margin/Columns/LeftColumn/PanelScroll/PuzzlePanel/Layout/SummaryLabel")
	progression.select_puzzle(0)
	await get_tree().process_frame
	_press_check(scene)
	if summary.text != "Requirements not yet met" or not next.disabled:
		_fail("unsolved Ends in 1 unlocked Next or hid the failure")
	else:
		print("FAIL ATTEMPT: Ends in 1 check stayed unsolved and Next stayed disabled")
	if _set_all_transitions(scene, SOLUTIONS["Ends in 1"]) != "":
		_fail("could not enter Ends in 1 solution")
		return
	_press_check(scene)
	if summary.text != "Puzzle solved" or next.disabled:
		_fail("solving Ends in 1 did not unlock Next")
		return
	next.pressed.emit()
	await get_tree().process_frame
	_press_check(scene)
	if summary.text != "Requirements not yet met" or not next.disabled:
		_fail("unsolved At least one 1 unlocked Next")
		return
	if _set_all_transitions(scene, SOLUTIONS["At least one 1"]) != "":
		_fail("could not enter At least one 1 solution")
		return
	_press_check(scene)
	if summary.text != "Puzzle solved" or next.disabled:
		_fail("solving At least one 1 did not unlock Next")
		return
	if _set_transition(scene, "A", 0, "B") != "":
		_fail("could not edit At least one 1")
		return
	next.pressed.emit()
	await get_tree().process_frame
	previous.pressed.emit()
	await get_tree().process_frame
	if _read_transition(scene, "A", 0) != "B":
		_fail("revisited At least one 1 lost the edit")
	else:
		print("REVISIT: At least one 1 kept A on 0 set to B")
	next.pressed.emit()
	await get_tree().process_frame
	if not next.disabled:
		_fail("Find the Double 1 enabled Next before it was solved")
	if _set_all_transitions(scene, SOLUTIONS["Find the Double 1"]) != "":
		_fail("could not enter Find the Double 1 solution")
		return
	if _read_transition(scene, "B", 1) != "C" or _read_transition(scene, "C", 0) != "C":
		_fail("Find the Double 1 solution is not B on 1 to C and C on 0 to C")
	_press_check(scene)
	if summary.text != "Puzzle solved" or not next.disabled:
		_fail("solving the last puzzle should leave Next disabled")
	else:
		print("SOLVED: Ends in 1, At least one 1, Find the Double 1")
		print("FINAL: Find the Double 1 keeps Next disabled")

func _apply_solution(source: TTableRes, solution: Dictionary) -> TTableRes:
	var table := Globals.deep_copy_table(source)
	for state_row in table.rows:
		var dest: Array = solution[state_row.state]
		state_row.row[0] = str(dest[0])
		state_row.row[1] = str(dest[1])
	return table

func _trace(table: TTableRes, input: String) -> Array:
	var states := [table.start_state]
	var current := table.start_state
	for i in input.length():
		var symbol := input.substr(i, 1)
		var input_index := table.inputs.find(symbol)
		for state_row in table.rows:
			if state_row.state == current:
				current = state_row.row[input_index]
				break
		states.append(current)
	return states

func _press_check(scene: Node) -> void:
	scene.get_node("CanvasLayer/UIRoot/Margin/Columns/LeftColumn/PanelScroll/PuzzlePanel/Layout/Buttons/CheckButton").pressed.emit()

func _button(scene: Node, button_name: String) -> Button:
	return scene.get_node("CanvasLayer/UIRoot/Margin/Columns/LeftColumn/PuzzleNavigation/%s" % button_name)

func _set_all_transitions(scene: Node, solution: Dictionary) -> String:
	for state in solution.keys():
		var dest: Array = solution[state]
		for input_index in 2:
			var error := _set_transition(scene, str(state), input_index, str(dest[input_index]))
			if error != "":
				return error
	return ""

func _set_transition(scene: Node, origin: String, input_index: int, destination: String) -> String:
	var button := _transition_button(scene, origin, input_index)
	if button == null:
		return "missing %s on %d" % [origin, input_index]
	for index in button.item_count:
		if button.get_item_text(index) == destination:
			button.select(index)
			button.emit_signal("item_selected", index)
			return ""
	return "missing destination %s" % destination

func _read_transition(scene: Node, origin: String, input_index: int) -> String:
	var button := _transition_button(scene, origin, input_index)
	if button == null:
		return ""
	return button.get_item_text(button.selected)

func _transition_button(scene: Node, origin: String, input_index: int) -> OptionButton:
	var grid := scene.get_node_or_null("CanvasLayer/UIRoot/Margin/Columns/RightColumn/TableSlot/TransitionTableGUI/MarginContainer/GeneratedTable")
	if grid == null:
		return null
	for child in grid.get_children():
		if child is OptionButton and str(child.get_meta("origin_state")) == origin and int(child.get_meta("input_index")) == input_index:
			return child
	return null
