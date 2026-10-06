extends Control
class_name TransitionTableGUI

@export
var table: TTableRes
## EXAMPLE:
##   || 0 | 1
## A || A | B
## B || C | B
## C || B | B

func _init() -> void:
	var inputs: Array[String] = ["0", "1"]
	table = TTableRes.new(inputs, [TRowRes.new("A", ["A", "B"]), TRowRes.new("B", ["C", "B"]), TRowRes.new("C", ["B", "B"])])
	table.print_inputs()
	for r in table.rows:
		r.print_transitions()
