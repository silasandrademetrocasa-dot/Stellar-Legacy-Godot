extends PanelContainer
const Design = preload("res://scripts/ui/design/galactic_theme.gd")
@export var accent: Color = Design.ION

func _ready() -> void:
    theme_type_variation = "GalacticPanel"
    resized.connect(queue_redraw)
    mouse_filter = Control.MOUSE_FILTER_PASS

func _draw() -> void:
    # The interrupted line and orbital registration marks form the visual motif.
    draw_line(Vector2(12, 1), Vector2(minf(48, size.x - 12), 1), accent, 2.0)
    draw_line(Vector2(size.x - 28, size.y - 1), Vector2(size.x - 12, size.y - 1), accent, 2.0)
    draw_circle(Vector2(size.x - 12, 12), 2, accent)
