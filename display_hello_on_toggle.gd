extends CheckButton

@export
var rtl: RichTextLabel	## This is the text "Hello, world"

var rtl_b: RichTextLabel:
	get():
		return get_parent().get_parent().find_child("RichTextLabel")

var rtl_c: RichTextLabel

func _enter_tree() -> void:
	self.toggled.connect(_on_toggled)
	rtl_c = $"../../PanelContainer2/MarginContainer/RichTextLabel"
	rtl.visible = self.button_pressed

func _on_toggled(is_toggled: bool) -> void:
	rtl.visible = is_toggled

# this is a function
func _on_toggled_editor(toggled_on: bool) -> void:
	print("_on_toggled_editor from editor")
