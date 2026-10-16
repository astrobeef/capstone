extends PanelContainer
class_name PuzzlePanel

signal check_requested()
signal restore_requested()

@onready var _title_label: Label = $Layout/TitleLabel
@onready var _requirements_label: Label = $Layout/RequirementsLabel
@onready var _results_label: Label = $Layout/ResultsLabel
@onready var _summary_label: Label = $Layout/SummaryLabel

func _ready() -> void:
	$Layout/Buttons/CheckButton.pressed.connect(_on_check_pressed)
	$Layout/Buttons/RestoreButton.pressed.connect(_on_restore_pressed)

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
