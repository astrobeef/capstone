extends Control

# practice scene: flip the switch, say hi (or dont)

@onready var greetingLabel: Label = %GreetingLabel

@onready var toggleButton: Button = $Center/Card/Rows/ToggleButton

@export var statusLabel: Label

var flipCount := 0


func _ready() -> void:
	_showGreeting(toggleButton.button_pressed)

	toggleButton.toggled.connect(func(isOn: bool) -> void:
		_showGreeting(isOn)
	)


func _showGreeting(isOn: bool) -> void:
	greetingLabel.visible = isOn
	statusLabel.text = "greeting is %s" % ("on" if isOn else "off")
	print("toggled: ", isOn, " | label says: \"", greetingLabel.text, "\"")


func _onToggleButtonToggled(_isOn: bool) -> void:
	flipCount += 1
	print("flip count: ", flipCount, " (not flipping out yet)")
