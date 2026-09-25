extends Control

# practice scene: flip the switch, say hi (or dont)

# grabbed by unique name, no path counting required
@onready var greetingLabel: Label = %GreetingLabel

# grabbed with a plain path once the tree is ready
@onready var toggleButton: Button = $Center/Card/Rows/ToggleButton

# assigned in the inspector
@export var statusLabel: Label

var flipCount := 0


func _ready() -> void:
	# start the label in sync with whatever the button says
	_showGreeting(toggleButton.button_pressed)

	# hooked up in code with a lambda, keeps things short and sweet
	toggleButton.toggled.connect(func(isOn: bool) -> void:
		_showGreeting(isOn)
	)


func _showGreeting(isOn: bool) -> void:
	greetingLabel.visible = isOn
	statusLabel.text = "greeting is %s" % ("on" if isOn else "off")
	print("toggled: ", isOn, " | label says: \"", greetingLabel.text, "\"")


# hooked up through the editor node tab, just counts flips
func _onToggleButtonToggled(_isOn: bool) -> void:
	flipCount += 1
	print("flip count: ", flipCount, " (not flipping out yet)")
