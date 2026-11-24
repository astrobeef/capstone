extends Node

## Headless checks for the trace panel (#155) and the layout (#157), no execution code needed.
## Run: Godot --headless --path . res://sprint5/tests/trace_panel_checks.tscn

var _failures: PackedStringArray = []
var _requests: Array = []

func _ready() -> void:
	await _check_panel_alone()
	await _check_state_visuals()
	await _check_layout()
	if _failures.is_empty():
		print("TRACE PANEL CHECKS PASSED")
		get_tree().quit(0)
	else:
		for failure in _failures:
			print("FAIL: %s" % failure)
		get_tree().quit(1)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)

func _check_panel_alone() -> void:
	var panel: TracePanel = load("res://sprint5/trace_panel.tscn").instantiate()
	add_child(panel)
	await get_tree().process_frame
	panel.begin_requested.connect(func(s: String): _requests.append("begin:" + s))
	panel.step_requested.connect(func(): _requests.append("step"))
	panel.reset_requested.connect(func(): _requests.append("reset"))
	var step: Button = panel.get_node("VBoxContainer/ButtonRow/StepButton")
	var reset: Button = panel.get_node("VBoxContainer/ButtonRow/ResetButton")
	var begin: Button = panel.get_node("VBoxContainer/ButtonRow/BeginButton")
	var selector: OptionButton = panel.get_node("VBoxContainer/InputSelector")
	# no inputs yet
	_expect(begin.disabled and step.disabled and reset.disabled, "empty panel should disable all buttons")
	panel.configure_inputs(["", "1", "101"] as Array[String])
	_expect(selector.item_count == 3, "selector should list 3 strings")
	_expect(selector.get_item_text(0) == "(empty)", "empty string should be shown as (empty)")
	_expect(selector.get_item_metadata(0) == "", "(empty) must keep the real empty string")
	_expect(not begin.disabled and step.disabled and reset.disabled and not selector.disabled, "cleared state: only Begin and selector enabled")
	begin.pressed.emit()
	_expect(_requests == ["begin:"], "Begin on (empty) should send the empty string, got %s" % [_requests])
	selector.select(2)
	begin.pressed.emit()
	_expect(_requests.back() == "begin:101", "Begin should send the selected string")
	panel.show_trace("A", 0, 3, false, false)
	_expect(not step.disabled and not reset.disabled and selector.disabled, "tracing: Step/Reset on, selector locked")
	_expect(panel.get_node("VBoxContainer/StateLabel").text == "Current state: A", "state label")
	_expect(panel.get_node("VBoxContainer/ProgressLabel").text == "Symbols consumed: 0 of 3", "progress label")
	_expect(panel.get_node("VBoxContainer/OutcomeLabel").text == "Trace in progress", "in-progress message")
	step.pressed.emit()
	reset.pressed.emit()
	_expect(_requests.slice(-2) == ["step", "reset"], "each button should produce one request")
	panel.show_trace("B", 3, 3, true, true)
	_expect(step.disabled and not reset.disabled and not selector.disabled, "finished: Step off, Reset on, selector unlocked")
	_expect(panel.get_node("VBoxContainer/OutcomeLabel").text == "Result: Accept", "accept outcome")
	panel.show_trace("A", 3, 3, true, false)
	_expect(panel.get_node("VBoxContainer/OutcomeLabel").text == "Result: Reject", "reject outcome")
	panel.clear_trace()
	_expect(step.disabled and reset.disabled and not selector.disabled and not begin.disabled, "clear returns to cleared state")
	panel.queue_free()

func _check_state_visuals() -> void:
	var state: State2D = load("res://state_2d.tscn").instantiate()
	add_child(state)
	await get_tree().process_frame
	var ring: DrawCircle2D = state.get_node("InnerRing2D")
	var accept: DrawCircle2D = state.get_node("AcceptRing2D")
	for combo in [[false, false], [true, false], [false, true], [true, true]]:
		state.is_start = combo[0]
		state.is_accepting = combo[1]
		state.set_current(true)
		_expect(ring.stroke_color == Color.YELLOW, "current ring should be yellow")
		_expect(state.get_node("PanelContainer/VBoxContainer/CurrentContainer/CurrentLabel").visible, "current label visible")
		_expect(accept.visible == combo[1], "accept ring follows is_accepting while current")
		_expect(state.get_node("PanelContainer/VBoxContainer/StartContainer/StartLabel").get_parent().visible == combo[0], "start label follows is_start while current")
		state.set_current(false)
		_expect(ring.stroke_color == Color.WHITE, "cleared ring should be white")
		_expect(not state.get_node("PanelContainer/VBoxContainer/CurrentContainer/CurrentLabel").visible, "current label hidden after clear")
	state.queue_free()

func _check_layout() -> void:
	var scene: Node = load("res://sprint3/dfa_puzzle.tscn").instantiate()
	add_child(scene)
	await get_tree().process_frame
	await get_tree().process_frame
	scene.get_node("PuzzleProgression").select_puzzle(0)
	await get_tree().process_frame
	var panel: TracePanel = scene.get_node("CanvasLayer/UIRoot/Margin/Columns/RightColumn/TracePanel")
	var machine: Automata2D = scene.get_node("Automata2D")
	panel._input_selector.select(1)
	panel._begin_button.pressed.emit()
	_expect(machine._trace_active and panel._input_selector.disabled, "Begin starts trace and locks selector")
	panel._reset_button.pressed.emit()
	_expect(not machine._trace_active, "Reset clears machine trace")
	_expect(not panel._input_selector.disabled and not panel._begin_button.disabled, "Reset enables selection and Begin")
	_expect(panel._step_button.disabled and panel._reset_button.disabled, "Reset disables Step and Reset")
	_expect(panel._outcome_label.text == "No trace running", "Reset clears trace display")
	for child in machine.get_children():
		if child is State2D:
			_expect(child.get_node("InnerRing2D").stroke_color == Color.WHITE, "Reset clears current-state highlight")
	panel._input_selector.select(2)
	panel._begin_button.pressed.emit()
	_expect(machine._trace_active and machine._trace_input == scene.puzzle.test_inputs[2], "Begin traces new selection after Reset")
	panel._step_button.pressed.emit()
	_expect(machine._trace_index == 1, "new trace can advance after Reset")
	panel._reset_button.pressed.emit()
	panel.configure_inputs(["", "1", "0110100110"] as Array[String])
	panel.show_trace("B", 10, 10, true, false)
	var window := get_window()
	for size in [Vector2i(1280, 720), Vector2i(1600, 900)]:
		window.size = size
		window.content_scale_size = size
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		var names := ["Margin/Columns/LeftColumn/PanelScroll", "Margin/Columns/LeftColumn/PuzzleNavigation", "Margin/Columns/RightColumn/DiagramLegend", "Margin/Columns/RightColumn/DiagramHost", "Margin/Columns/RightColumn/TracePanel", "Margin/Columns/RightColumn/TableSlot"]
		var rects := {}
		var root: Control = scene.get_node("CanvasLayer/UIRoot")
		print("viewport %s, UIRoot %s" % [get_viewport().get_visible_rect().size, root.size])
		for n in names:
			var c: Control = root.get_node(n)
			rects[n] = c.get_global_rect()
			print("  %-45s %s" % [n, rects[n]])
			_expect(Rect2(Vector2.ZERO, root.size).encloses(rects[n]), "%s outside the screen at %s" % [n, size])
		for i in range(names.size()):
			for j in range(i + 1, names.size()):
				if rects[names[i]].intersects(rects[names[j]]):
					_failures.append("%s overlaps %s at %s" % [names[i], names[j], size])
		var tp: Control = root.get_node("Margin/Columns/RightColumn/TracePanel")
		_expect(tp.size.y >= tp.get_combined_minimum_size().y - 0.5, "trace panel clipped at %s" % size)
	scene.queue_free()
