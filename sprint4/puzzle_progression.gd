extends Node
class_name PuzzleProgression

signal puzzle_selected(puzzle: PuzzleRes, working_table: TTableRes)
signal progression_changed

const SAVE_PATH := "user://puzzle_progress.cfg"
const SAVE_VERSION := 1

@export
var puzzles: Array[PuzzleRes] = []
var current_puzzle_index := -1
var completed: Array[bool] = []
var working_tables: Array[TTableRes] = []

var _resume_index := 0

func _ready() -> void:
	completed.resize(puzzles.size())
	completed.fill(false)
	working_tables.resize(puzzles.size())
	_load_progress()

func has_saved_progress() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func get_resume_index() -> int:
	if is_unlocked(_resume_index):
		return _resume_index
	return 0

func is_unlocked(index: int) -> bool:
	return index >= 0 and index < puzzles.size() and (index == 0 or completed[index - 1])

func select_puzzle(index: int) -> void:
	if not is_unlocked(index):
		return
	current_puzzle_index = index
	_resume_index = index
	if working_tables[index] == null:
		working_tables[index] = puzzles[index].create_user_table()
	puzzle_selected.emit(puzzles[index], working_tables[index])
	save_progress()

func mark_current_complete() -> void:
	if current_puzzle_index < 0 or completed[current_puzzle_index]:
		return
	var current := puzzles[current_puzzle_index]
	if not current.is_puzzle_solved(current.evaluate(working_tables[current_puzzle_index])):
		return
	completed[current_puzzle_index] = true
	progression_changed.emit()
	save_progress()

func restore_current() -> void:
	if current_puzzle_index < 0:
		return
	working_tables[current_puzzle_index] = puzzles[current_puzzle_index].create_user_table()
	select_puzzle(current_puzzle_index)

func save_progress() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("meta", "version", SAVE_VERSION)
	cfg.set_value("meta", "puzzle_count", puzzles.size())
	cfg.set_value("meta", "current_index", current_puzzle_index)
	for i in puzzles.size():
		cfg.set_value("completed", str(i), completed[i] if i < completed.size() else false)
		if i < working_tables.size() and working_tables[i] != null:
			cfg.set_value("tables", str(i), _table_to_saved(working_tables[i]))
	cfg.save(SAVE_PATH)

func _load_progress() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	if int(cfg.get_value("meta", "version", 0)) != SAVE_VERSION:
		return
	if int(cfg.get_value("meta", "puzzle_count", -1)) != puzzles.size():
		return
	_resume_index = int(cfg.get_value("meta", "current_index", 0))
	for i in puzzles.size():
		completed[i] = bool(cfg.get_value("completed", str(i), false))
		if not cfg.has_section_key("tables", str(i)):
			continue
		var saved: Variant = cfg.get_value("tables", str(i))
		if typeof(saved) != TYPE_DICTIONARY:
			continue
		var restored := _table_from_saved(puzzles[i], saved as Dictionary)
		if restored != null:
			working_tables[i] = restored
	if not is_unlocked(_resume_index):
		_resume_index = 0

func _table_to_saved(table: TTableRes) -> Dictionary:
	var rows := {}
	for state_row in table.rows:
		rows[state_row.state] = Array(state_row.row)
	return {
		"start": table.start_state,
		"accepting": Array(table.accepting_states),
		"inputs": Array(table.inputs),
		"rows": rows,
	}

func _table_from_saved(puzzle: PuzzleRes, data: Dictionary) -> TTableRes:
	if puzzle == null or puzzle.source_table == null:
		return null
	var table := puzzle.create_user_table()
	var saved_inputs: Array = data.get("inputs", [])
	var saved_accepting: Array = data.get("accepting", [])
	var saved_rows: Dictionary = data.get("rows", {})
	if str(data.get("start", "")) != table.start_state:
		return null
	if saved_inputs.size() != table.inputs.size():
		return null
	for i in table.inputs.size():
		if str(saved_inputs[i]) != table.inputs[i]:
			return null
	if saved_accepting.size() != table.accepting_states.size():
		return null
	for i in table.accepting_states.size():
		if str(saved_accepting[i]) != table.accepting_states[i]:
			return null
	if saved_rows.size() != table.rows.size():
		return null
	for state_row in table.rows:
		if not saved_rows.has(state_row.state):
			return null
		var destinations: Array = saved_rows[state_row.state]
		if destinations.size() != state_row.row.size():
			return null
		for i in destinations.size():
			var dest := str(destinations[i])
			if not table.states.has(dest):
				return null
			state_row.row[i] = dest
	return table
