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
var _innerRing: DrawCircle2D:
	get():
		return get_node_or_null("InnerRing2D")

const CURRENT_COLOR := Color.YELLOW
const DEFAULT_COLOR := Color.WHITE

func _ready() -> void:
	_refreshVisuals()
	set_current(false)

# labels do not exist until ready, so the setters have to wait their turn like everyone else
func _refreshVisuals() -> void:
	if not is_node_ready():
		return
	_nameLabel.text = label_name
	_startLabel.get_parent().visible = is_start
	_acceptRing.visible = is_accepting

# shows which state the dfa is sitting in, the others can watch from the sidelines
# the inner ring turns yellow and the "current" label shows, so it never relies on color alone
func set_current(value: bool) -> void:
	_currentLabel.visible = value
	_currentLabel.get_parent().visible = value
	_innerRing.stroke_color = CURRENT_COLOR if value else DEFAULT_COLOR
