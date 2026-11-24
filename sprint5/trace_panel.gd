extends PanelContainer
class_name TracePanel

## Manual trace panel (#155). Lets the player pick one of the puzzle's listed
## strings, begin a trace, step through it, and reset it. This panel only
## displays state and emits requests; the execution lives in Automata2D.

signal begin_requested(input_string: String)
signal step_requested()
signal reset_requested()

const EMPTY_LABEL := "(empty)"

@onready var _input_selector: OptionButton = $VBoxContainer/InputSelector
@onready var _begin_button: Button = $VBoxContainer/ButtonRow/BeginButton
@onready var _step_button: Button = $VBoxContainer/ButtonRow/StepButton
@onready var _reset_button: Button = $VBoxContainer/ButtonRow/ResetButton
@onready var _state_label: Label = $VBoxContainer/StateLabel
@onready var _progress_label: Label = $VBoxContainer/ProgressLabel
@onready var _outcome_label: Label = $VBoxContainer/OutcomeLabel

func _ready() -> void:
	_begin_button.pressed.connect(_on_begin_pressed)
	_step_button.pressed.connect(func(): step_requested.emit())
	_reset_button.pressed.connect(func(): reset_requested.emit())
	clear_trace()

## Fills the selector with the puzzle's listed strings. The real string is kept
## in item metadata; "" is only shown as "(empty)".
func configure_inputs(inputs: Array[String]) -> void:
	_input_selector.clear()
	for input_string in inputs:
		_input_selector.add_item(EMPTY_LABEL if input_string.is_empty() else input_string)
		_input_selector.set_item_metadata(_input_selector.item_count - 1, input_string)
	if _input_selector.item_count > 0:
		_input_selector.select(0)
	clear_trace()

## Shows the state of a running or finished trace. `accepted` only matters when
## `finished` is true.
func show_trace(current_state: String, consumed: int, total: int, finished: bool, accepted: bool) -> void:
	_state_label.text = "Current state: %s" % current_state
	_progress_label.text = "Symbols consumed: %d of %d" % [consumed, total]
	if finished:
		_outcome_label.text = "Result: Accept" if accepted else "Result: Reject"
	else:
		_outcome_label.text = "Trace in progress"
	_input_selector.disabled = not finished
	_begin_button.disabled = _input_selector.item_count == 0
	_step_button.disabled = finished
	_reset_button.disabled = false

## Returns the panel to its "no trace" state: Step and Reset off, selection on.
func clear_trace() -> void:
	_state_label.text = "Current state: none"
	_progress_label.text = "Symbols consumed: none"
	_outcome_label.text = "No trace running"
	var has_inputs := _input_selector.item_count > 0
	_input_selector.disabled = not has_inputs
	_begin_button.disabled = not has_inputs
	_step_button.disabled = true
	_reset_button.disabled = true

func _on_begin_pressed() -> void:
	if _input_selector.item_count == 0:
		return
	var chosen: String = _input_selector.get_item_metadata(_input_selector.selected)
	begin_requested.emit(chosen)

