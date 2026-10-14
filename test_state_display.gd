extends Node2D

@onready var stateA: State2D = $StateA
@onready var stateB: State2D = $StateB

# a moves in, a moves out, b gets the promotion
func _ready() -> void:
	stateA.set_current(true)
	stateA.set_current(false)
	stateB.set_current(true)
