extends Control
const Design = preload("res://scripts/ui/design/galactic_theme.gd")
func _ready() -> void:
    custom_minimum_size = Vector2(144, 144)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    resized.connect(queue_redraw)
func _draw() -> void:
    var center := size * 0.5
    var radius := minf(size.x, size.y) * 0.38
    draw_arc(center, radius, -PI * 0.2, PI * 1.35, 64, Design.BORDER, 1.0, true)
    draw_arc(center, radius * 0.79, PI * 0.55, PI * 1.9, 48, Design.ION, 2.0, true)
    var points := PackedVector2Array([center + Vector2(0, -radius * 0.7), center + Vector2(radius * 0.36, radius * 0.45), center, center + Vector2(-radius * 0.36, radius * 0.45), center + Vector2(0, -radius * 0.7)])
    draw_polyline(points, Design.TEXT, 2.0, true)
    draw_line(center + Vector2(-radius * 1.12, 0), center + Vector2(radius * 1.12, 0), Design.BORDER, 1.0, true)
    for angle in [0.3, 2.0, 4.3]:
        draw_circle(center + Vector2(cos(angle), sin(angle)) * radius, 3, Design.AMBER)
