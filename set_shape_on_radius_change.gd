@tool
extends Node
# NOTE: Neglecting a classname since this class is not (currently) referenced elsewhere
# A dependent class to DrawCircle2D, enabling automatic radius change for the parent CollisionShape2D
# as the radius of the DrawCircle2D is changed.
# NOTE: This easily could've been a script attached directly to the `CollisionShape2D`, but separating offers more clarity between purpose.

var _draw_circle: DrawCircle2D:
	get():
		return get_parent().get_parent().get_parent()

var _collision_shape_2D: CollisionShape2D:
	get():
		return get_parent()

func _enter_tree() -> void:
	if !Engine.is_editor_hint():
		# As of now, radius cannot be changed at runtime. So no need to listen for changes.
		return
	# Ensure connection isn't made twice (this would never happen at runtime, but @tool scripts can be silly)
	if !_draw_circle.radius_changed.is_connected(_on_radius_changed):
		# Uses deferred flag to run at end of frame (not necessary but it showcases flags)
		_draw_circle.radius_changed.connect(_on_radius_changed, ConnectFlags.CONNECT_DEFERRED)

func _ready() -> void:
	_on_radius_changed(_draw_circle.effective_radius)

# On `radius_changed` emitted from `_draw_circle`, change this shape's radius
func _on_radius_changed(new: float):
	(_collision_shape_2D.shape as CircleShape2D).radius = new
