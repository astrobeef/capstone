extends Control
class_name TransitionTableGUI

@export
var table: TTableRes
## EXAMPLE:
##   || 0 | 1
## A || A | B
## B || C | B
## C || B | B

func _ready() -> void:
	if table == null:
		return
	table.print_inputs()
	for r in table.rows:
		if r != null:
			r.print_transitions()
