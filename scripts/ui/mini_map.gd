extends Control
## Minimap visual local; nenhuma consulta de rede.

const WORLD_HALF := Vector2(120.0, 90.0)
var current_map := "1-1"
var ship_pos := Vector3.ZERO
var portal_points: Array[Vector3] = []
var focused_portal := -1

func update_state(map_id: String, new_ship_pos: Vector3, points: Array[Vector3], selected: int) -> void:
    current_map = map_id
    ship_pos = new_ship_pos
    portal_points = points
    focused_portal = selected
    queue_redraw()

func _to_screen(p: Vector3) -> Vector2:
    var uv := Vector2((p.x + WORLD_HALF.x) / (2.0 * WORLD_HALF.x), (p.z + WORLD_HALF.y) / (2.0 * WORLD_HALF.y))
    return Vector2(7.0, 25.0) + uv * (size - Vector2(14.0, 32.0))

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, size), Color(0.018, 0.038, 0.085, 0.9), true)
    draw_rect(Rect2(Vector2.ZERO, size), Color(0.22, 0.42, 0.68), false, 1.4)
    draw_string(ThemeDB.fallback_font, Vector2(9, 17), "MAPA %s" % current_map, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.8, 0.93, 1.0))
    var mid := _to_screen(Vector3.ZERO)
    draw_line(Vector2(mid.x, 25), Vector2(mid.x, size.y - 7), Color(0.14, 0.25, 0.39, 0.9), 1)
    draw_line(Vector2(7, mid.y), Vector2(size.x - 7, mid.y), Color(0.14, 0.25, 0.39, 0.9), 1)
    for i in range(portal_points.size()):
        var col := Color(1, 0.83, 0.36) if i == focused_portal else Color(0.35, 0.85, 1)
        draw_circle(_to_screen(portal_points[i]), 4.2, col)
    draw_circle(_to_screen(ship_pos), 4.5, Color(0.46, 1, 0.55))
