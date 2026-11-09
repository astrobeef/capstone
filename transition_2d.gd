@tool
extends Node2D
class_name Transition2D

@export
var start_point := Vector2.ZERO:
	set(value):
		start_point = value
		queue_redraw()
@export
var control_point_1 := Vector2(25, -50):
	set(value):
		control_point_1 = value
		queue_redraw()
@export
var control_point_2 := Vector2(115, -50):
	set(value):
		control_point_2 = value
		queue_redraw()
@export
var end_point := Vector2(140, 0):
	set(value):
		end_point = value
		queue_redraw()

@export
var label_position := Vector2(70, -55):
	set(value):
		label_position = value
		_refresh_label()

const SEGMENTS := 32
const LINE_WIDTH := 3.0
const ARROW_LENGTH := 12.0
const ARROW_HALF_WIDTH := 6.0

var _symbols: Array[String] = ["0"]

func _ready() -> void:
	_refresh_label()

func set_inputs(symbols: Array[String]) -> void:
	_symbols = symbols.duplicate()
	visible = not _symbols.is_empty()
	_refresh_label()

func _refresh_label() -> void:
	if not is_node_ready():
		return
	var label := $InputLabel as Label
	label.text = ", ".join(_symbols)
	label.reset_size()
	label.position = label_position - label.size / 2.0

func _draw() -> void:
	var points := PackedVector2Array()
	for index in range(SEGMENTS + 1):
		var t := float(index) / SEGMENTS
		points.append(start_point.bezier_interpolate(
			control_point_1, control_point_2, end_point, t))
	var direction := end_point - control_point_2
	if direction.is_zero_approx():
		direction = end_point - points[SEGMENTS - 1]
	if direction.is_zero_approx():
		return
	direction = direction.normalized()
	var side := Vector2(-direction.y, direction.x)
	var base := end_point - direction * ARROW_LENGTH
	for index in range(points.size() - 2, -1, -1):
		var distance := (points[index] - base).dot(direction)
		if distance <= 0.0:
			var next_distance := (points[index + 1] - base).dot(direction)
			var join_point := points[index].lerp(points[index + 1], -distance / (next_distance - distance))
			points.resize(index + 1)
			points.append(join_point)
			break
	draw_polyline(points, Color.WHITE, LINE_WIDTH, true)
	draw_colored_polygon(PackedVector2Array([end_point, base + side * ARROW_HALF_WIDTH, base - side * ARROW_HALF_WIDTH,]), Color.WHITE)
