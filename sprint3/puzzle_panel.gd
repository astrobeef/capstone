extends PanelContainer
class_name PuzzlePanel

signal check_requested()
signal restore_requested()

@onready var _title_label: Label = $Layout/TitleLabel
@onready var _requirements_label: Label = $Layout/RequirementsLabel
@onready var _results_label: Label = $Layout/ResultsLabel
@onready var _summary_label: Label = $Layout/SummaryLabel
@onready var _check_button: Button = $Layout/Buttons/CheckButton
@onready var _restore_button: Button = $Layout/Buttons/RestoreButton

func _ready() -> void:
	_check_button.pressed.connect(_on_check_pressed)
	_restore_button.pressed.connect(_on_restore_pressed)
	_check_button.focus_next = _check_button.get_path_to(_restore_button)
	_check_button.focus_previous = _check_button.get_path_to(_restore_button)
	_restore_button.focus_next = _restore_button.get_path_to(_check_button)
	_restore_button.focus_previous = _restore_button.get_path_to(_check_button)
	_check_button.grab_focus.call_deferred()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if event.is_action_pressed(&"ui_focus_next"):
		if _move_focus(1):
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"ui_focus_prev"):
		if _move_focus(-1):
			get_viewport().set_input_as_handled()

func _move_focus(step: int) -> bool:
	var buttons: Array[Button] = [_check_button, _restore_button]
	var index := buttons.find(get_viewport().gui_get_focus_owner())
	if index == -1:
		var owner := get_viewport().gui_get_focus_owner()
		if owner != null:
			return false
		buttons[0 if step > 0 else 1].grab_focus()
		return true
	buttons[posmod(index + step, buttons.size())].grab_focus()
	return true

func configure_puzzle(title: String, requirements_text: String) -> void:
	_title_label.text = title
	_requirements_label.text = requirements_text
	clear_results()

func show_results(results_text: String, solved: bool) -> void:
	_results_label.text = results_text
	if solved:
		_summary_label.text = "Puzzle solved"
	else:
		_summary_label.text = "Requirements not yet met"

func clear_results() -> void:
	_results_label.text = ""
	_summary_label.text = ""

func _on_check_pressed() -> void:
	check_requested.emit()

func _on_restore_pressed() -> void:
	restore_requested.emit()
