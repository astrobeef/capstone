extends Node
class_name AutoCommands
# A Singleton (`Autoload`) script to execute global commands.

func _enter_tree() -> void:
	# Ensure this class can always execute
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	_input_fullscreen()
	_input_exit()

func _input_fullscreen():
	if Input.is_action_just_pressed("fullscreen_toggle"):
		toggle_fullscreen()

func toggle_fullscreen():
	if DisplayServer.window_get_mode(0) != DisplayServer.WINDOW_MODE_FULLSCREEN:
		_enable_fullscreen()
	else:
		_disable_fullscreen()

func is_fullscreen() -> bool:
	return DisplayServer.window_get_mode(0) == DisplayServer.WINDOW_MODE_FULLSCREEN

func _enable_fullscreen():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN, 0)
func _disable_fullscreen():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED, 0)
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)

func _input_exit():
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
