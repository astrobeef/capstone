@tool
extends Node2D
class_name State2D

@export
var label_name := "a":
	set(value):
		label_name = value
		_refreshVisuals()

@export
var is_start := false:
	set(value):
		is_start = value
		_refreshVisuals()

@export
var is_accepting := false:
	set(value):
		is_accepting = value
		_refreshVisuals()

@onready var _nameLabel: Label = $NameLabel
@onready var _startLabel: Label = $StartLabel
@onready var _currentLabel: Label = $CurrentLabel
@onready var _acceptRing: Node2D = $AcceptRing2D

func _ready() -> void:
	_refreshVisuals()

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
