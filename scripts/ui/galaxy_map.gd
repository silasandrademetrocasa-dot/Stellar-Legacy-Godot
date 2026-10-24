extends Control
## Mapa de rotas para ORIENTACAO, nao teleporte remoto.
const Routes = preload("res://scripts/world_routes.gd")
var faction := "1"
var current_map := "1-1"

func set_route_view(next_faction: String, map_id: String) -> void:
    faction = next_faction
    current_map = map_id
    queue_redraw()

func _positions() -> Dictionary:
    var result := {}
    var coords := [Vector2(0.11, 0.26), Vector2(0.31, 0.26), Vector2(0.51, 0.26), Vector2(0.71, 0.26), Vector2(0.71, 0.49), Vector2(0.51, 0.49), Vector2(0.31, 0.49), Vector2(0.11, 0.49)]
    for i in range(8):
        result["%s-%d" % [faction, i + 1]] = coords[i]
    for i in range(1, 4):
        result["U-%d" % i] = Vector2(0.16 + (i - 1) * 0.29, 0.83)
        result["4-%d" % i] = Vector2(0.15 + (i - 1) * 0.29, 0.66)
    for i in range(Routes.ASTRAL_MAPS.size()):
        result[Routes.ASTRAL_MAPS[i]] = Vector2(0.13 + float(i) * 0.33, 0.95)
    return result

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.04, 0.09, 0.97), true)
    draw_rect(Rect2(Vector2.ZERO, size), Color(0.24, 0.49, 0.7), false, 2)
    draw_string(ThemeDB.fallback_font, Vector2(20, 28), "ROTAS GALACTICAS  |  %s" % Routes.FACTION_NAMES.get(faction, ""), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.86, 0.94, 1.0))
    var pos := _positions()
    var content := Rect2(Vector2(12, 40), size - Vector2(24, 47))
    for link in Routes.link_keys(faction):
        if pos.has(link[0]) and pos.has(link[1]):
            draw_line(content.position + pos[link[0]] * content.size, content.position + pos[link[1]] * content.size, Color(0.26, 0.51, 0.68, 0.7), 2)
    for label in pos.keys():
        var p: Vector2 = content.position + pos[label] * content.size
        var active := str(label) == current_map
        var c := Color(0.47, 1, 0.58) if active else (Color(1, 0.58, 0.48) if str(label).begins_with("4-") else Color(0.44, 0.72, 1))
        draw_circle(p, 10 if active else 7, c)
        draw_string(ThemeDB.fallback_font, p + Vector2(-12, -13), str(label), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color.WHITE)
    draw_string(ThemeDB.fallback_font, Vector2(18, size.y - 11), "Portais fisicos no mapa | Sem teleporte pelo painel", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.68, 0.81, 0.9))
