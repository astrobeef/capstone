extends HBoxContainer

signal previous_requested
signal next_requested
signal return_requested

var _prev_button: Button:
	get():
		return get_node_or_null("./PreviousButton")

var _next_button: Button:
	get():
		return get_node_or_null("./NextButton")

var _return_button: Button:
	get():
		return get_node_or_null("./ReturnButton")

func _ready() -> void:
	_prev_button.pressed.connect(func(): previous_requested.emit())
	_next_button.pressed.connect(func(): next_requested.emit())
	_return_button.pressed.connect(func(): return_requested.emit())

func set_navigation_available(can_previous: bool, can_next: bool) -> void:
	_prev_button.disabled = not can_previous
	_next_button.disabled = not can_next
