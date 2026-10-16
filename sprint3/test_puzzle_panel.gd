extends Control

var _check_count := 0
var _restore_count := 0
var _show_solved := false

@onready var _panel: PuzzlePanel = $PuzzlePanel
@onready var _signal_counts: Label = $SignalCounts

func _ready() -> void:
	_panel.check_requested.connect(_on_check_requested)
	_panel.restore_requested.connect(_on_restore_requested)
	_panel.configure_puzzle("Sample puzzle", "01 — expected Reject\n11 — expected Accept\n0 — expected Accept")
	_update_counts()

func _on_check_requested() -> void:
	_check_count += 1
	_show_solved = not _show_solved
	var results := "01 — expected Reject, actual Reject — Pass\n11 — expected Accept, actual Accept — Pass"
	if not _show_solved:
		results += "\n0 — expected Accept, actual Reject — Fail"
	_panel.show_results(results, _show_solved)
	_update_counts()

func _on_restore_requested() -> void:
	_restore_count += 1
	_panel.clear_results()
	_update_counts()

func _update_counts() -> void:
	_signal_counts.text = "Check signals: %d    Restore signals: %d" % [_check_count, _restore_count]
