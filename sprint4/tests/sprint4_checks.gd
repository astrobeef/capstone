extends Node

## Headless smoke check for the sprint 4 puzzle sequence.
## Run: Godot --headless --path . res://sprint4/tests/sprint4_checks.tscn

const PUZZLE_PATHS: PackedStringArray = [
	"res://sprint4/puzzles/beginner_01.tres",
	"res://sprint4/puzzles/beginner_02.tres",
	"res://sprint3/puzzles/first_puzzle.tres",
	"res://sprint4/puzzles/intermediate_01.tres",
	"res://sprint4/puzzles/intermediate_02.tres",
	"res://sprint4/puzzles/advanced_01.tres",
	"res://sprint4/puzzles/advanced_02.tres",
]

# Sprint 5 sequence loaded by the running scene. The later tier files stay on disk.
const SCENE_PATHS: PackedStringArray = [
	"res://sprint4/puzzles/beginner_01.tres",
	"res://sprint4/puzzles/beginner_02.tres",
	"res://sprint3/puzzles/first_puzzle.tres",
]

# Correct destinations per state, as [on0, on1]. Matches difficulty_tiers.md.
const SOLUTIONS := {
	"Ends in 1": {"A": ["A", "B"], "B": ["A", "B"]},
	"At least one 1": {"A": ["A", "B"], "B": ["B", "B"]},
	"Find the Double 1": {"A": ["A", "B"], "B": ["A", "C"], "C": ["C", "C"]},
	"Even number of 1s": {"A": ["A", "B"], "B": ["B", "A"]},
	"Even 0s and even 1s": {"A": ["B", "C"], "B": ["A", "D"], "C": ["D", "A"], "D": ["C", "B"]},
	"Contains 101": {"A": ["A", "B"], "B": ["C", "B"], "C": ["A", "D"], "D": ["D", "D"]},
}

var _failures: PackedStringArray = []

func _ready() -> void:
	_check_resources()
	await _check_scene()
	if _failures.is_empty():
		print("SPRINT4 CHECKS PASSED")
		get_tree().quit(0)
	else:
		for failure in _failures:
			print("FAIL: %s" % failure)
			push_error(failure)
		get_tree().quit(1)

func _fail(message: String) -> void:
	_failures.append(message)

func _check_resources() -> void:
	for path in PUZZLE_PATHS:
		var puzzle := load(path) as PuzzleRes
		if puzzle == null:
			_fail("%s did not load" % path)
			continue
		if puzzle.test_inputs.is_empty() or puzzle.test_inputs.size() != puzzle.expected_acceptance.size():
			_fail("%s has mismatched test inputs" % puzzle.title)
			continue
		if not puzzle.test_inputs.has(""):
			_fail("%s is missing the empty-string case" % puzzle.title)
		var start_results := Eval.table_acceptance_of_inputs(puzzle.source_table, puzzle.test_inputs)
		var start_fails := false
		for i in puzzle.test_inputs.size():
			if start_results[i] != puzzle.expected_acceptance[i]:
				start_fails = true
				break
		if not start_fails:
			_fail("%s starting table already passes" % puzzle.title)
		if not SOLUTIONS.has(puzzle.title):
			_fail("%s has no recorded solution" % puzzle.title)
			continue
		var solution: Dictionary = SOLUTIONS[puzzle.title]
		var solved: TTableRes = _apply_solution(puzzle.source_table, solution)
		var solved_results := Eval.table_acceptance_of_inputs(solved, puzzle.test_inputs)
		for i in puzzle.test_inputs.size():
			if solved_results[i] != puzzle.expected_acceptance[i]:
				_fail("%s solution fails on '%s'" % [puzzle.title, puzzle.test_inputs[i]])
				break

func _check_scene() -> void:
	# Avoid a leftover playtest save changing unlock/resume behavior.
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PuzzleProgression.SAVE_PATH))
	var scene := (load("res://sprint3/dfa_puzzle.tscn") as PackedScene).instantiate()
	add_child(scene)
	for _i in 4:
		await get_tree().process_frame
	var progression = scene.get_node("PuzzleProgression")
	if progression.puzzles.size() != SCENE_PATHS.size():
		_fail("scene has %d puzzles, expected %d" % [progression.puzzles.size(), SCENE_PATHS.size()])
		scene.queue_free()
		return
	for i in SCENE_PATHS.size():
		var expected := load(SCENE_PATHS[i]) as PuzzleRes
		if progression.puzzles[i].title != expected.title:
			_fail("scene puzzle %d is '%s', expected '%s'" % [i, progression.puzzles[i].title, expected.title])
	# Fresh launches open the puzzle list; enter the first puzzle for interaction checks.
	progression.select_puzzle(0)
	await get_tree().process_frame
	var previous := scene.get_node("CanvasLayer/UIRoot/Margin/Columns/LeftColumn/PuzzleNavigation/PreviousButton") as Button
	var next := scene.get_node("CanvasLayer/UIRoot/Margin/Columns/LeftColumn/PuzzleNavigation/NextButton") as Button
	if not previous.disabled or not next.disabled:
		_fail("first puzzle should disable Previous and Next until solved")
	# Solve the first puzzle via the table UI, confirm Next unlocks, and that an edit survives a round-trip.
	if _set_all_transitions(scene, SOLUTIONS["Ends in 1"]) != "":
		_fail("could not enter Ends in 1 solution")
		scene.queue_free()
		return
	scene.get_node("CanvasLayer/UIRoot/Margin/Columns/LeftColumn/PanelScroll/PuzzlePanel/Layout/Buttons/CheckButton").pressed.emit()
	if scene.get_node("CanvasLayer/UIRoot/Margin/Columns/LeftColumn/PanelScroll/PuzzlePanel/Layout/SummaryLabel").text != "Puzzle solved" or next.disabled:
		_fail("solving Ends in 1 did not unlock Next")
	next.pressed.emit()
	await get_tree().process_frame
	if _set_transition(scene, "A", 0, "B") != "":
		_fail("could not edit At least one 1")
		scene.queue_free()
		return
	previous.pressed.emit()
	await get_tree().process_frame
	next.pressed.emit()
	await get_tree().process_frame
	if _read_transition(scene, "A", 0) != "B":
		_fail("revisited puzzle lost the edit")
	scene.get_node("CanvasLayer/UIRoot/Margin/Columns/LeftColumn/PuzzleNavigation/ReturnButton").pressed.emit()
	await get_tree().process_frame
	var selection := scene.get_node("CanvasLayer/PuzzleSelection") as Control
	if not selection.visible:
		_fail("Return did not open the puzzle list")
	scene.queue_free()

func _apply_solution(source: TTableRes, solution: Dictionary) -> TTableRes:
	var table := Globals.deep_copy_table(source)
	for state_row in table.rows:
		var dest: Array = solution[state_row.state]
		state_row.row[0] = str(dest[0])
		state_row.row[1] = str(dest[1])
	return table

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
