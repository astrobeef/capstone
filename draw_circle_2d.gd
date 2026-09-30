@tool
extends Node2D
class_name DrawCircle2D	# Giving a class name so this class can be referenced in `set_shape_on_radius_changed.gd`
# This class is a @tool script, which means it can execute in the Editor.
# Allowing it to run in Editor means we can see the shape drawn in Editor,
# Rather than just at runtime.
# Two circles are drawn: one for fill and one for stroke.
# The class is optimized to neglect draws if the fill has 0.0 for alpha,
# or if the stroke has a width of 0.0.

# Emits the effective radius when the radius or width are changed
signal radius_changed(neweffective_radius: float)

@export
var radius: float:	## Radius of the circle in pixels (half of width adds to this)
	get():
		return _radius
	set(value):
		if value != _radius:
			_radius = value
			radius_changed.emit(effective_radius)

var _radius := 32.0

@export
var stroke_width: float:		## Width of the stroke in pixels (this enlarges the shape by half its value (cause it expands in&out), effectively adding to the radius).
	get():
		return _stroke_width
	set(value):
		if value != _stroke_width:
			_stroke_width = value
			radius_changed.emit(effective_radius)

var _stroke_width := 2.0

var effective_radius: float:	## The radius of the circle with width added.
	get():
		return _radius + (stroke_width / 2.0)

@export
var fill_color := Color.BLACK	## Color of the inner circle. Set alpha to 0.0 to neglect fill.

@export
var stroke_color := Color.WHITE		## Color of the stroke.

# Godot built-in. Ctrl+Click `_physics_process` to read more.
func _physics_process(delta: float) -> void:
	if self.is_node_ready():
		# The `_draw` function requires redraws to draw to the screen upon node changes.
		queue_redraw()

# Godot built-in. Ctrl+Click `_draw` to read more.
func _draw() -> void:
	# Draw fill
	if fill_color.a > 0.0 && radius > 0.0:
		# Godot built-in function
		draw_circle(Vector2.ZERO, radius, fill_color, true)
	# Draw stroke
	if stroke_width > 0.0:
		# Godot built-in function
		draw_circle(Vector2.ZERO, radius, stroke_color, false, stroke_width)
