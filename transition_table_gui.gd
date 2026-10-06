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

var grid: GridContainer

var _grid_parent: Node:
	get():
		return $PanelContainer/MarginContainer

func _ready() -> void:
	rebuild_table()

func rebuild_table() -> void:
	if not is_inside_tree():
		return
	grid = _grid_parent.get_node_or_null("GeneratedTable") as GridContainer
	if grid != null:
		for child in grid.get_children():
			grid.remove_child(child)
			child.queue_free()
	else:
		grid = GridContainer.new()
		grid.name = "GeneratedTable"
		_grid_parent.add_child(grid)
	if Engine.is_editor_hint():
		grid.owner = get_tree().edited_scene_root
	if table == null:
		grid.columns = 1
		_add_label("No table assigned", "EmptyTable")
		return
	grid.columns = table.inputs.size() + 1
	_add_label("", "HeaderState")
	for input_index in range(table.inputs.size()):
		_add_label(
			table.inputs[input_index],
			"HeaderInput_%d" % input_index
		)
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
	grid.add_child(label)
	if Engine.is_editor_hint():
		label.owner = get_tree().edited_scene_root

func _add_line_edit(value: String, node_name: String) -> void:
	var le := LineEdit.new()
	le.name = node_name
	le.text = value
	le.custom_minimum_size = Vector2(80, 28)
	le.alignment = HORIZONTAL_ALIGNMENT_CENTER
	grid.add_child(le)
	if Engine.is_editor_hint():
		le.owner = get_tree().edited_scene_root
