@tool
extends Node2D
class_name StateRole2D
## #44 Create States
## Add this as a child of a DrawCircle2D to turn that circle into an automaton state.
## Draws the state's name, a double ring for accepting, a start arrow for start,
## and a tooltip with the definition on hover.

@export var state_name := "q_0"
@export var is_start := false
@export var is_accepting := false
@export var label_color := Color.WHITE

const FONT_SIZE := 16
const TOOLTIP_FONT_SIZE := 13
const START_TOOLTIP := "Start state: the automaton begins reading input here."
const ACCEPT_TOOLTIP := "Accepting state: if input ends here, the result is ACCEPT."

func _process(_delta: float) -> void:
    queue_redraw()

func _circle() -> DrawCircle2D:
    return get_parent() as DrawCircle2D

func _draw() -> void:
    var c := _circle()
    if c == null:
        return
    var font := ThemeDB.fallback_font

    var name_w := font.get_string_size(state_name, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x
    draw_string(font, Vector2(-name_w / 2.0, FONT_SIZE * 0.35), state_name, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, label_color)

    if is_accepting:
        draw_circle(Vector2.ZERO, c.radius - 6.0, c.stroke_color, false, 2.0)

    if is_start:
        var tip := Vector2(-c.effective_radius, 0)
        var tail := tip + Vector2(-40, 0)
        draw_line(tail, tip, c.stroke_color, 2.0, true)
        draw_colored_polygon(PackedVector2Array([tip, tip + Vector2(-10, -6), tip + Vector2(-10, 6)]), c.stroke_color)

    if not Engine.is_editor_hint() and _is_hovered(c):
        var text := _tooltip_text()
        if text != "":
            var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, TOOLTIP_FONT_SIZE).x
            var pos := Vector2(-w / 2.0, -c.effective_radius - 14)
            draw_rect(Rect2(pos + Vector2(-6, -16), Vector2(w + 12, 22)), Color(0, 0, 0, 0.85))
            draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, TOOLTIP_FONT_SIZE, Color.WHITE)

func _is_hovered(c: DrawCircle2D) -> bool:
    return to_local(get_global_mouse_position()).length() <= c.effective_radius

func _tooltip_text() -> String:
    if is_start and is_accepting:
        return START_TOOLTIP + " " + ACCEPT_TOOLTIP
    if is_start:
        return START_TOOLTIP
    if is_accepting:
        return ACCEPT_TOOLTIP
    return ""
