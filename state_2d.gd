@tool
extends Node2D
class_name State2D

@export
## Set in automata_2d.gd
var label_name := "a":
	set(value):
		label_name = value
		_refreshVisuals()

@export
## Set in automata_2d.gd
var is_start := false:
	set(value):
		is_start = value
		_refreshVisuals()

@export
## Set in automata_2d.gd
var is_accepting := false:
	set(value):
		is_accepting = value
		_refreshVisuals()

var _nameLabel: Label:
	get():
		return get_node_or_null("NameLabel")
var _startLabel: Label:
	get():
		return get_node_or_null("PanelContainer/VBoxContainer/StartContainer/StartLabel")
var _currentLabel: Label:
	get():
		return get_node_or_null("PanelContainer/VBoxContainer/CurrentContainer/CurrentLabel")
var _acceptRing: DrawCircle2D:
	get():
		return get_node_or_null("AcceptRing2D")

func _ready() -> void:
	_refreshVisuals()
	set_current(false)

# labels do not exist until ready, so the setters have to wait their turn like everyone else
func _refreshVisuals() -> void:
	if not is_node_ready():
		return
	_nameLabel.text = label_name
	_startLabel.visible = is_start
	_acceptRing.visible = is_accepting

# shows which state the dfa is sitting in, the others can watch from the sidelines
func set_current(value: bool) -> void:
	_currentLabel.visible = value
