extends Button
# One automaton state (q_0 or q_1). Button is used so tooltips work.
# Practice for #44 Create States.

@export var state_name: String = "q_0"
@export var is_start: bool = false
@export var is_accepting: bool = false

func _ready() -> void:
	text = state_name
	custom_minimum_size = Vector2(80, 80)

	if is_start:
		tooltip_text = "Start state: the automaton begins reading input here."
		modulate = Color(0.6, 0.8, 1.0)  # blue
	elif is_accepting:
		tooltip_text = "Accepting state: if input ends here, the result is ACCEPT."
		modulate = Color(0.6, 1.0, 0.6)  # green
