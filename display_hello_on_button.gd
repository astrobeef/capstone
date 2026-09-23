extends CheckButton

# Get RTL each time
var rich_text_label_a:
	get():
		return $"../../PanelContainer2/RichTextLabel"

# Set reference in _enter_tree()
var rich_text_label_b: RichTextLabel

# Set reference through editor
@export
var rich_text_label_c: RichTextLabel

# Called when this nod enters the scene tree
func _enter_tree() -> void:
	rich_text_label_b = self.get_parent().get_parent().find_child("RichTextLabel")
	# Initialize visiblity state by this button's pressed state (which is used to store toggle state)
	rich_text_label_b.visible = self.button_pressed
	self.toggled.connect(_on_toggled_code)

# Connected to toggled signal via _enter_tree() above
func _on_toggled_code(is_toggled: bool):
	rich_text_label_a.visible = is_toggled
	print("is_toggled? ", is_toggled)
	print("RTL Label = \"%s\"" % rich_text_label_a.text)

# Connected to toggled signal via editor
func _on_toggled_editor(toggled_on: bool) -> void:
	print("_on_toggled_editor: I'm doing nothing, but I'm here.")
