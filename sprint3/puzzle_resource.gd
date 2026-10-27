extends Resource
class_name PuzzleRes

@export
var title: String

@export
var source_table: TTableRes

@export
var test_inputs: Array[String]

@export
var expected_acceptance: Array[bool]

func _init(source: TTableRes):
	source_table = source

func create_user_table() -> TTableRes:
	var user_table: TTableRes = source_table.duplicate(true)
	return user_table

func evaluate(t: TTableRes) -> Array[bool]:
	return Eval.table_acceptance_of_inputs(t, test_inputs)

func is_puzzle_solved(results: Array[bool]) -> bool:
	return results == expected_acceptance