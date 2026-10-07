@tool
extends Node2D
class_name State2D

signal condition_type_changed(old: CONDITION_TYPE, new: CONDITION_TYPE)
enum CONDITION_TYPE {START = -1, INTER = 0, FINAL = 1}
@export
var condition_type: CONDITION_TYPE:
	get():
		return _condition_type
	set(type):
		if type != _condition_type:
			condition_type_changed.emit(_condition_type, type)
			_condition_type = type

var _condition_type: CONDITION_TYPE = CONDITION_TYPE.INTER

@export
var label_name := "a"

var _label:
	get():
		return get_node("DrawCircle2D/Label")

func _enter_tree() -> void:
	condition_type_changed.connect(_on_type_changed, ConnectFlags.CONNECT_DEFERRED)

func _ready() -> void:
	_on_type_changed(CONDITION_TYPE.START, CONDITION_TYPE.INTER)
	_label.text = label_name

func _on_type_changed(_old: CONDITION_TYPE, new: CONDITION_TYPE):
	self.get_node("DrawCircle2D/DrawCircle2D-Accept").visible = new == CONDITION_TYPE.FINAL
