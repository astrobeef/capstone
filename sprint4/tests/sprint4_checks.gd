extends Node

const SIZE_SMALL := Vector2i(1280, 720)
const SIZE_LARGE := Vector2i(1920, 1080)

var _failures: PackedStringArray = []
var _report: PackedStringArray = []
var _docs: Array[Dictionary] = []

func _ready() -> void:
	_check_documents()
	_check_resources()
	_check_navigation_buttons()
	await _check_scene()
	_write_report()
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
	print("FAIL: %s" % message)

func _check_documents() -> void:
	var tiers := FileAccess.get_file_as_string("res://sprint4/puzzles/difficulty_tiers.md")
	for name in ["beginner_01.tres", "beginner_02.tres", "intermediate_01.tres", "intermediate_02.tres", "advanced_01.tres", "advanced_02.tres"]:
		if not tiers.contains(name):
			_fail("difficulty tiers do not name %s" % name)
	_check_risks()
	_check_form()
	_docs = _parse_solutions(FileAccess.get_file_as_string("res://sprint4/puzzles/solutions.md"))
	if _docs.size() != 6:
		_fail("solutions.md parsed %d puzzles, expected 6" % _docs.size())

func _check_risks() -> void:
	var text := FileAccess.get_file_as_string("res://sprint4/sprint_risks.md")
	var count := 0
	var high := 0
	for raw_line in text.split("\n"):
		var line := raw_line.strip_edges()
		if not line.begins_with("| S4-"):
			continue
		var cells := _cells(line)
		count += 1
		if cells.size() < 7:
			_fail("%s risk row is missing a field" % cells[0] if cells.size() > 0 else "risk row")
			continue
		if not ["Low", "Medium", "High"].has(cells[2]) or not ["Low", "Medium", "High"].has(cells[3]):
			_fail("%s likelihood/impact is off" % cells[0])
		if cells[4].is_empty() or cells[5].length() < 20 or cells[6].length() < 20:
			_fail("%s needs a monitoring contact, mitigation, and trigger" % cells[0])
		if cells[3] == "High":
			high += 1
			var trigger := cells[6].to_lower()
			if not (trigger.contains("standup") or trigger.contains("discuss") or trigger.contains("team") or trigger.contains("talk")):
				_fail("%s high-impact trigger does not bring the team back" % cells[0])
	if count < 6:
		_fail("risk register has %d rows" % count)
	if high < 1:
		_fail("risk register has no high-impact row")
	_report.append("RK-T1/RK-T2: %d risks, %d high-impact" % [count, high])

func _check_form() -> void:
	var form := FileAccess.get_file_as_string("res://sprint4/playtesting/feedback_form.md").to_lower()
	for phrase in ["instruction", "transition", "result", "navigation", "difficul", "participant code", "anything else", "return to puzzles"]:
		if not form.contains(phrase):
			_fail("feedback form is missing '%s'" % phrase)
	_report.append("PT-T2: form covers the session notes activities. Approval line is still blank.")

func _parse_solutions(text: String) -> Array[Dictionary]:
	var puzzles: Array[Dictionary] = []
	var current: Dictionary = {}
	var mode := ""
	for raw_line in text.split("\n"):
		var line := raw_line.strip_edges()
		if line.begins_with("## "):
			if not current.is_empty():
				puzzles.append(current)
			current = {"id": line.trim_prefix("## ").strip_edges(), "solution": [], "expected": []}
			mode = ""
			continue
		if current.is_empty():
			continue
		if line.begins_with("### "):
			var heading := line.trim_prefix("### ").strip_edges()
			if heading == "Solution transitions":
				mode = "solution"
			elif heading == "Expected results":
				mode = "expected"
			else:
				mode = ""
			continue
		if line.begins_with("- Resource:"):
			current["resource"] = line.trim_prefix("- Resource:").strip_edges()
		elif line.begins_with("- Title:"):
			current["title"] = line.trim_prefix("- Title:").strip_edges()
		elif line.begins_with("- Tier:"):
			current["tier"] = line.trim_prefix("- Tier:").strip_edges()
		elif line.begins_with("- Starting failures:"):
			current["start_failures"] = _quoted(line)
		elif mode == "solution" and _is_data_row(line, "state"):
			var cells := _cells(line)
			current["solution"].append({"state": cells[0], "on0": cells[1], "on1": cells[2]})
		elif mode == "expected" and _is_data_row(line, "input"):
			var cells := _cells(line)
			current["expected"].append({"input": _unquote(cells[0]), "accept": cells[1] == "Accept"})
	if not current.is_empty():
		puzzles.append(current)
	return puzzles

func _check_resources() -> void:
	var beginner := 0
	var later := 0
	for doc in _docs:
		var id: String = doc["id"]
		var puzzle := load(str(doc["resource"])) as PuzzleRes
		if puzzle == null:
			_fail("%s did not load" % id)
			continue
		if puzzle.title != str(doc["title"]):
			_fail("%s title is '%s'" % [id, puzzle.title])
		var expected: Array = doc["expected"]
		if expected.size() != puzzle.test_inputs.size():
			_fail("%s requirement count does not match the resource" % id)
			continue
		var saw_empty := false
		for index in expected.size():
			var row: Dictionary = expected[index]
			if str(row["input"]) != puzzle.test_inputs[index] or bool(row["accept"]) != puzzle.expected_acceptance[index]:
				_fail("%s requirement %d does not match solutions.md" % [id, index])
			if str(row["input"]).is_empty():
				saw_empty = true
		if not saw_empty:
			_fail("%s does not include the empty string" % id)
		var start_results := Eval.table_acceptance_of_inputs(puzzle.source_table, puzzle.test_inputs)
		var solution_table := _solution_table(puzzle, doc["solution"])
		var solved_results := Eval.table_acceptance_of_inputs(solution_table, puzzle.test_inputs)
		var actual_failures: PackedStringArray = []
		var start_lines: PackedStringArray = []
		var solved_lines: PackedStringArray = []
		var solved_ok := true
		for index in puzzle.test_inputs.size():
			var input := puzzle.test_inputs[index]
			var expect_accept: bool = puzzle.expected_acceptance[index]
			start_lines.append(_result_line(input, expect_accept, start_results[index]))
			solved_lines.append(_result_line(input, expect_accept, solved_results[index]))
			if start_results[index] != expect_accept:
				actual_failures.append(input)
			if solved_results[index] != expect_accept:
				solved_ok = false
		if actual_failures.is_empty():
			_fail("%s starting table already passes" % id)
		if not solved_ok:
			_fail("%s solution does not pass" % id)
		var documented: Array = doc["start_failures"]
		if documented.size() != actual_failures.size():
			_fail("%s documents failures %s but evaluator found %s" % [id, documented, actual_failures])
		else:
			for failure_input in documented:
				if not actual_failures.has(str(failure_input)):
					_fail("%s failure list does not match the evaluator" % id)
		var diffs := _diff_count(puzzle.source_table, solution_table)
		_check_tier(id, str(doc["tier"]), puzzle, diffs)
		if str(doc["tier"]) == "Beginner":
			beginner += 1
		else:
			later += 1
		_report.append("%s start: %s" % [id, "; ".join(start_lines)])
		_report.append("%s solved: %s" % [id, "; ".join(solved_lines)])
	if beginner < 2 or later < 3:
		_fail("expected 2 beginner and at least 3 later puzzles, found %d and %d" % [beginner, later])

func _check_tier(id: String, tier: String, puzzle: PuzzleRes, diffs: int) -> void:
	var states := puzzle.source_table.rows.size()
	var requirements := puzzle.test_inputs.size()
	var rejects := 0
	for accept in puzzle.expected_acceptance:
		if not accept:
			rejects += 1
	var problems: PackedStringArray = []
	match tier:
		"Beginner":
			if states != 2 or requirements < 4 or rejects < 1 or diffs < 1 or diffs > 2:
				problems.append("states %d reqs %d diffs %d" % [states, requirements, diffs])
		"Intermediate":
			if states < 2 or states > 3 or requirements < 6 or diffs != 2:
				problems.append("states %d reqs %d diffs %d" % [states, requirements, diffs])
		"Advanced":
			if states < 4 or requirements < 10 or diffs < 4:
				problems.append("states %d reqs %d diffs %d" % [states, requirements, diffs])
		_:
			problems.append("unknown tier")
	if not problems.is_empty():
		_fail("%s does not meet %s: %s" % [id, tier, ", ".join(problems)])

func _check_navigation_buttons() -> void:
	var nav := (load("res://sprint4/puzzle_navigation.tscn") as PackedScene).instantiate()
	add_child(nav)
	if not (nav is HBoxContainer):
		_fail("navigation root is not an HBoxContainer")
	var counts := {"previous": 0, "next": 0, "return": 0}
	nav.previous_requested.connect(func() -> void: counts["previous"] = int(counts["previous"]) + 1)
	nav.next_requested.connect(func() -> void: counts["next"] = int(counts["next"]) + 1)
	nav.return_requested.connect(func() -> void: counts["return"] = int(counts["return"]) + 1)
	nav.get_node("PreviousButton").pressed.emit()
	nav.get_node("NextButton").pressed.emit()
	nav.get_node("ReturnButton").pressed.emit()
	if int(counts["previous"]) != 1 or int(counts["next"]) != 1 or int(counts["return"]) != 1:
		_fail("navigation signals were %s" % counts)
	nav.set_navigation_available(false, true)
	if not nav.get_node("PreviousButton").disabled or nav.get_node("NextButton").disabled:
		_fail("set_navigation_available(false, true) did not stick")
	nav.set_navigation_available(true, false)
	if nav.get_node("PreviousButton").disabled or not nav.get_node("NextButton").disabled:
		_fail("set_navigation_available(true, false) did not stick")
	if nav.get_node("ReturnButton").disabled:
		_fail("Return was disabled")
	nav.queue_free()

func _check_scene() -> void:
	if _docs.size() != 6:
		_fail("skipped the scene check")
		return
	var sub := SubViewport.new()
	sub.size = SIZE_SMALL
	sub.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	sub.disable_3d = true
	add_child(sub)
	var scene := (load("res://sprint3/dfa_puzzle.tscn") as PackedScene).instantiate()
	sub.add_child(scene)
	for _i in 8:
		await get_tree().process_frame
	var progression = scene.get_node("PuzzleProgression")
	if progression.puzzles.size() != _docs.size():
		_fail("scene has %d puzzles, solutions.md has %d" % [progression.puzzles.size(), _docs.size()])
		return
	for index in _docs.size():
		if progression.puzzles[index].title != str(_docs[index]["title"]):
			_fail("scene puzzle %d is '%s'" % [index, progression.puzzles[index].title])
	await _check_layout(scene, sub, "UI-T1", "beginner_01")
	sub.size = SIZE_LARGE
	for _i in 3:
		await get_tree().process_frame
	await _check_layout(scene, sub, "UI-T4", "beginner_01")
	sub.size = SIZE_SMALL
	for _i in 3:
		await get_tree().process_frame

	var previous := scene.get_node("CanvasLayer/PuzzleNavigation/PreviousButton") as Button
	var next := scene.get_node("CanvasLayer/PuzzleNavigation/NextButton") as Button
	if not previous.disabled or not next.disabled:
		_fail("first puzzle should disable Previous and Next")
	if _apply_solution(scene, _docs[0]["solution"]) != "":
		_fail("could not enter beginner_01")
		return
	_press_check(scene)
	if _summary(scene) != "Puzzle solved" or next.disabled or not progression.completed[0]:
		_fail("solving beginner_01 did not unlock Next")
	next.pressed.emit()
	await get_tree().process_frame
	if _title(scene) != str(_docs[1]["title"]):
		_fail("Next opened '%s'" % _title(scene))
	if _set_transition(scene, "A", 0, "B") != "":
		_fail("could not edit beginner_02")
		return
	previous.pressed.emit()
	await get_tree().process_frame
	next.pressed.emit()
	await get_tree().process_frame
	if _read_transition(scene, "A", 0) != "B":
		_fail("revisited puzzle lost the edit")
	if not progression.completed[0] or previous.disabled:
		_fail("completion did not stick after leaving the solved puzzle")

	for index in range(1, _docs.size()):
		if _title(scene) != str(_docs[index]["title"]):
			_fail("expected %s, scene shows '%s'" % [_docs[index]["title"], _title(scene)])
			break
		if _apply_solution(scene, _docs[index]["solution"]) != "":
			_fail("could not enter %s" % _docs[index]["id"])
			break
		_press_check(scene)
		if _summary(scene) != "Puzzle solved":
			_fail("%s did not solve in the scene" % _docs[index]["id"])
			break
		_assert_controls(scene, sub, str(_docs[index]["id"]))
		if index < _docs.size() - 1:
			if next.disabled:
				_fail("Next stayed disabled after %s" % _docs[index]["id"])
				break
			next.pressed.emit()
			await get_tree().process_frame
		elif not next.disabled or previous.disabled:
			_fail("last puzzle should disable Next only")
	await _check_layout(scene, sub, "UI-T1", "advanced")
	sub.size = SIZE_LARGE
	for _i in 3:
		await get_tree().process_frame
	await _check_layout(scene, sub, "UI-T4", "advanced")
	scene.get_node("CanvasLayer/PuzzleNavigation/ReturnButton").pressed.emit()
	await get_tree().process_frame
	var selection := scene.get_node("CanvasLayer/PuzzleSelection") as Control
	var panel_scroll := scene.get_node("CanvasLayer/PanelScroll") as Control
	if not selection.visible or panel_scroll.visible:
		_fail("Return did not open the puzzle list")
	else:
		_report.append("UI-T3: solved Ends in 1, edited At least one 1, left, and the edit was still there. Last puzzle disables Next. Return opens the puzzle list.")

func _check_layout(scene: Node, sub: SubViewport, test_id: String, label: String) -> void:
	var viewport := Vector2(sub.size)
	for path in ["CanvasLayer/PanelScroll", "CanvasLayer/MarginContainer", "CanvasLayer/PuzzleNavigation", "CanvasLayer/DiagramLegend"]:
		var node := scene.get_node_or_null(path) as Control
		if node == null or not _inside(node.get_global_rect(), viewport):
			_fail("%s %s %s rect is outside %s" % [test_id, label, path, viewport])
		elif node != null:
			_report.append("%s %s %s %s" % [test_id, label, path, node.get_global_rect()])
	_assert_controls(scene, sub, "%s %s" % [test_id, label])

func _assert_controls(scene: Node, sub: SubViewport, label: String) -> void:
	var viewport := Vector2(sub.size)
	var table := scene.get_node_or_null("CanvasLayer/MarginContainer/TransitionTableGUI") as TransitionTableGUI
	if table == null or table.table == null:
		_fail("%s has no transition table" % label)
		return
	var grid := table.get_node_or_null("MarginContainer/GeneratedTable")
	if grid == null:
		_fail("%s table did not build" % label)
		return
	var buttons := 0
	for child in grid.get_children():
		if child is OptionButton:
			buttons += 1
			if not _inside((child as Control).get_global_rect(), viewport):
				_fail("%s dropdown %s is outside the window" % [label, child.name])
	if buttons != table.table.rows.size() * table.table.inputs.size():
		_fail("%s has %d dropdowns" % [label, buttons])
	var automata := scene.get_node("Automata2D")
	var seen := 0
	for state in automata.get_children():
		if state is State2D:
			seen += 1
			var name_label := state.get_node_or_null("NameLabel") as Label
			if name_label == null or name_label.text != state.name:
				_fail("%s state %s label is wrong" % [label, state.name])
			if state.global_position.x < 0.0 or state.global_position.y < 0.0 or state.global_position.x > viewport.x or state.global_position.y > viewport.y:
				_fail("%s state %s is outside the window" % [label, state.name])
	if seen != table.table.rows.size():
		_fail("%s shows %d states" % [label, seen])

func _apply_solution(scene: Node, rows: Array) -> String:
	for row in rows:
		for input_index in 2:
			var destination := str(row["on0"] if input_index == 0 else row["on1"])
			var error := _set_transition(scene, str(row["state"]), input_index, destination)
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
	var grid := scene.get_node_or_null("CanvasLayer/MarginContainer/TransitionTableGUI/MarginContainer/GeneratedTable")
	if grid == null:
		return null
	for child in grid.get_children():
		if child is OptionButton and str(child.get_meta("origin_state")) == origin and int(child.get_meta("input_index")) == input_index:
			return child
	return null

func _press_check(scene: Node) -> void:
	scene.get_node("CanvasLayer/PanelScroll/PuzzlePanel/Layout/Buttons/CheckButton").pressed.emit()

func _summary(scene: Node) -> String:
	return scene.get_node("CanvasLayer/PanelScroll/PuzzlePanel/Layout/SummaryLabel").text

func _title(scene: Node) -> String:
	return scene.get_node("CanvasLayer/PanelScroll/PuzzlePanel/Layout/TitleLabel").text

func _solution_table(puzzle: PuzzleRes, rows: Array) -> TTableRes:
	var table := Globals.deep_copy_table(puzzle.source_table)
	for row in rows:
		for state_row in table.rows:
			if state_row.state == str(row["state"]):
				state_row.row[0] = str(row["on0"])
				state_row.row[1] = str(row["on1"])
	return table

func _diff_count(start: TTableRes, solution: TTableRes) -> int:
	var diffs := 0
	for index in start.rows.size():
		for input_index in start.rows[index].row.size():
			if start.rows[index].row[input_index] != solution.rows[index].row[input_index]:
				diffs += 1
	return diffs

func _inside(rect: Rect2, viewport: Vector2) -> bool:
	return rect.size.x > 8.0 and rect.size.y > 8.0 and rect.position.x >= -1.0 and rect.position.y >= -1.0 and rect.end.x <= viewport.x + 1.0 and rect.end.y <= viewport.y + 1.0

func _result_line(input: String, expected: bool, actual: bool) -> String:
	var shown := "(empty)" if input.is_empty() else "\"%s\"" % input
	var outcome := "Pass" if expected == actual else "Fail"
	return "%s expected %s actual %s %s" % [shown, "Accept" if expected else "Reject", "Accept" if actual else "Reject", outcome]

func _quoted(line: String) -> Array[String]:
	var found: Array[String] = []
	var regex := RegEx.new()
	regex.compile("\"([^\"]*)\"")
	for match in regex.search_all(line):
		found.append(match.get_string(1))
	return found

func _cells(line: String) -> PackedStringArray:
	var cells: PackedStringArray = []
	for part in line.split("|"):
		var cell := part.strip_edges()
		if not cell.is_empty():
			cells.append(cell)
	return cells

func _is_data_row(line: String, header_name: String) -> bool:
	return line.begins_with("|") and not line.contains("---") and not line.contains(header_name)

func _unquote(value: String) -> String:
	var text := value.strip_edges()
	if text.begins_with("\"") and text.ends_with("\"") and text.length() >= 2:
		return text.substr(1, text.length() - 2)
	return text

func _write_report() -> void:
	var lines: PackedStringArray = []
	lines.append("# Sprint 4 check")
	lines.append("")
	lines.append("- Scene: sprint3/dfa_puzzle.tscn")
	lines.append("- Branch: %s" % _git(["rev-parse", "--abbrev-ref", "HEAD"]))
	lines.append("- Sizes: 1280x720 and 1920x1080, headless, one machine")
	lines.append("")
	for line in _report:
		lines.append("- %s" % line)
	if _failures.is_empty():
		lines.append("- Result: passed")
	else:
		lines.append("- Result: failed")
		for failure in _failures:
			lines.append("- %s" % failure)
	var path := ProjectSettings.globalize_path("res://sprint4/tests/verification_record.md")
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	file.store_string("\n".join(lines) + "\n")
	file.close()

func _git(args: PackedStringArray) -> String:
	var output: Array = []
	if OS.execute("git", args, output, true) != 0:
		return "unavailable"
	var text := ""
	for line in output:
		text += str(line)
	return text.strip_edges()
