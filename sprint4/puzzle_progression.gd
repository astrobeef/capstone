extends Node
class_name PuzzleProgression

signal puzzle_selected(puzzle: PuzzleRes, working_table: TTableRes)
signal progression_changed

@export
var puzzles: Array[PuzzleRes] = []
var current_puzzle_index := -1
var completed: Array[bool] = []
var working_tables: Array[TTableRes] = []

func _ready() -> void:
	completed.resize(puzzles.size())
	completed.fill(false)
	working_tables.resize(puzzles.size())

func is_unlocked(index: int) -> bool:
	return index >= 0 and index < puzzles.size() and (index == 0 or completed[index - 1])

func select_puzzle(index: int) -> void:
	if not is_unlocked(index):
		return
	current_puzzle_index = index
	if working_tables[index] == null:
		working_tables[index] = puzzles[index].create_user_table()
	puzzle_selected.emit(puzzles[index], working_tables[index])

func mark_current_complete() -> void:
	if current_puzzle_index < 0 or completed[current_puzzle_index]:
		return
	var current := puzzles[current_puzzle_index]
	if not current.is_puzzle_solved(current.evaluate(working_tables[current_puzzle_index])):
		return
	completed[current_puzzle_index] = true
	progression_changed.emit()

func restore_current() -> void:
	if current_puzzle_index < 0:
		return
	working_tables[current_puzzle_index] = puzzles[current_puzzle_index].create_user_table()
	select_puzzle(current_puzzle_index)
