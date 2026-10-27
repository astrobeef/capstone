extends Node

@export
var table: TTableRes

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var puzzle_res := PuzzleRes.new(table)
	puzzle_res.create_user_table()
