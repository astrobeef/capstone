extends CheckButton

var label_by_path: RichTextLabel:
	get:
		return $"../../PanelContainer2/RichTextLabel"

var label_by_search: RichTextLabel

@export var label_by_export: RichTextLabel

func _enter_tree() -> void:
	label_by_search = get_parent().get_parent().find_child("RichTextLabel")
	_show_selected(button_pressed)
	toggled.connect(_when_toggled_in_code)

func _when_toggled_in_code(toggled_on: bool) -> void:
	_show_selected(toggled_on)
	print("switch is ", toggled_on)
	print("label says: ", label_by_path.text)

func _show_selected(selected: bool) -> void:
	var tint := Color(1, 1, 1, 1) if selected else Color(0.72, 0.72, 0.72, 1)
	get_parent().modulate = tint
	label_by_path.get_parent().modulate = tint
	label_by_search.visible = true

func _when_toggled_in_editor(toggled_on: bool) -> void:
	print("editor hook ran: ", toggled_on)
