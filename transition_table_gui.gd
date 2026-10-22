@tool
extends Control
class_name TransitionTableGUI

const OB_META_PREV_SELECT = "prev_selected"
const OB_META_INIT_SELECT = "init_selected"
const OB_META_ORIGIN_STATE = "origin_state"
const NO_DESTINATION_ID = 1000

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

signal transition_selected(origin_state: String, new_destination: String, previous_destination: String)

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
		_add_header_input("No table assigned", "EmptyTable")
		return
	_grid.columns = table.inputs.size() + 1
	_add_header_state("", "HeaderState")
	for input_index in range(table.inputs.size()):
		_add_header_input(table.inputs[input_index],"HeaderInput_%d" % input_index)
	for state_index in range(table.rows.size()):
		var state_row := table.rows[state_index]
		if state_row == null:
			continue
		_add_header_state(state_row.state,"HeaderState_%d" % state_index)
		for input_index in range(table.inputs.size()):
			var destination := ""
			if input_index < state_row.row.size():
				destination = state_row.row[input_index]
			_add_transition(state_row.state, destination,"Transition_%d_%d" % [state_index, input_index])

func _add_header_input(value: String, node_name: String) -> void:
	_add_label(value, node_name, Color("#c7ff98"), Color("#0f180e"), 6, 20)

func _add_header_state(value: String, node_name: String) -> void:
	_add_label(value, node_name, Color("#c5fdff"), Color("#070b11"), 6, 20)

func _add_label(value: String, node_name: String, font_color: Color, font_outline_color: Color, outline_size: int, font_size: int) -> void:
	var label := Label.new()
	label.name = node_name
	label.text = value
	label.custom_minimum_size = Vector2(80, 28)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", font_color)
	label.add_theme_color_override("font_outline_color", font_outline_color)
	label.add_theme_constant_override("outline_size", outline_size)
	label.add_theme_font_size_override("font_size", font_size)
	_grid.add_child(label)
	if Engine.is_editor_hint():
		label.owner = get_tree().edited_scene_root

func _add_transition(origin_state: String, dest_state: String, node_name: String) -> void:
	var ob := OptionButton.new()
	ob.name = node_name
	ob.custom_minimum_size = Vector2(80, 28)
	ob.alignment = HORIZONTAL_ALIGNMENT_CENTER
	ob.add_theme_color_override("font_color", Color.WHITE)
	ob.add_theme_font_size_override("font_size", 20)
	for i in range(0, table.states.size()):
		ob.add_item(table.states[i], i)
		if table.states[i] == dest_state:
			ob.select(i)
	ob.item_selected.connect(_on_item_selected.bind(ob))
	# Set meta property to store previous select state
	ob.set_meta(OB_META_PREV_SELECT, ob.selected)
	ob.set_meta(OB_META_INIT_SELECT, ob.selected)
	ob.set_meta(OB_META_ORIGIN_STATE, origin_state)
	ob.add_item("", NO_DESTINATION_ID)
	_grid.add_child(ob)
	if Engine.is_editor_hint():
		ob.owner = get_tree().edited_scene_root

func _on_item_selected(selected_index: int, source: OptionButton):
	var init_index := source.get_meta(OB_META_INIT_SELECT) as int
	var prev_index := source.get_meta(OB_META_PREV_SELECT) as int
	var origin_state := source.get_meta(OB_META_ORIGIN_STATE) as String
	source.set_meta(OB_META_PREV_SELECT, selected_index)
	print("User selected [id:%d] (\"%s\") on \"%s\", which had initial [id:%d] (\"%s\") and had previous [id:%d] (\"%s\")" % [source.get_item_id(selected_index), source.get_item_text(selected_index), source.name, source.get_item_id(init_index), source.get_item_text(init_index), source.get_item_id(prev_index), source.get_item_text(prev_index)])
	transition_selected.emit(origin_state, source.get_item_text(selected_index), source.get_item_text(prev_index))
