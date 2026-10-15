@tool
extends Control
class_name TransitionTableGUI

@export
var do_rebuild_table: bool:
	set(value):
		if value:
			rebuild_table()

@export
var table: TTableRes

var _grid: GridContainer

var _grid_parent: Node:
	get():
		return $PanelContainer/MarginContainer

func _ready() -> void:
	rebuild_table()

func rebuild_table() -> void:
	if not is_inside_tree():
		return
	_grid = _grid_parent.get_node_or_null("GeneratedTable") as GridContainer
	if _grid != null:
		for child in _grid.get_children():
			_grid.remove_child(child)
			child.queue_free()
	else:
		_grid = GridContainer.new()
		_grid.name = "GeneratedTable"
		_grid_parent.add_child(_grid)
	if Engine.is_editor_hint():
		_grid.owner = get_tree().edited_scene_root
	if table == null:
		_grid.columns = 1
		_add_label("No table assigned", "EmptyTable")
		return
	_grid.columns = table.inputs.size() + 1
	_add_label("", "HeaderState")
	for input_index in range(table.inputs.size()):
		_add_label(table.inputs[input_index],"HeaderInput_%d" % input_index)
	for state_index in range(table.rows.size()):
		var state_row := table.rows[state_index]
		if state_row == null:
			continue
		_add_label(state_row.state,"State_%d" % state_index)
		for input_index in range(table.inputs.size()):
			var destination := ""
			if input_index < state_row.row.size():
				destination = state_row.row[input_index]
			_add_line_edit(destination,"Transition_%d_%d" % [state_index, input_index])

func _add_label(value: String, node_name: String) -> void:
	var label := Label.new()
	label.name = node_name
	label.text = value
	label.custom_minimum_size = Vector2(80, 28)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 6)
	label.add_theme_font_size_override("font_size", 20)
	_grid.add_child(label)
	if Engine.is_editor_hint():
		label.owner = get_tree().edited_scene_root

func _add_line_edit(value: String, node_name: String) -> void:
	var le := LineEdit.new()
	le.name = node_name
	le.text = value
	le.custom_minimum_size = Vector2(80, 36)
	le.alignment = HORIZONTAL_ALIGNMENT_CENTER
	le.add_theme_color_override("font_color", Color.BLACK)
	le.add_theme_color_override("caret_color", Color.BLACK)
	le.add_theme_font_size_override("font_size", 20)
	var field := StyleBoxFlat.new()
	field.bg_color = Color.WHITE
	field.content_margin_left = 6
	field.content_margin_right = 6
	le.add_theme_stylebox_override("normal", field)
	_grid.add_child(le)
	if Engine.is_editor_hint():
		le.owner = get_tree().edited_scene_root
