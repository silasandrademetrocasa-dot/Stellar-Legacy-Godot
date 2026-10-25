extends Control
## Minimap visual local; nenhuma consulta de rede.

signal destination_requested(world_pos: Vector3)

const WORLD_HALF := Vector2(120.0, 90.0)
var current_map := "1-1"
var ship_pos := Vector3.ZERO
var portal_points: Array[Vector3] = []
var focused_portal := -1
var enemy_points: Array[Vector3] = []
var loot_points: Array[Vector3] = []
var ore_points: Array[Vector3] = []
var bonus_points: Array[Vector3] = []
var destination: Vector3 = Vector3.ZERO
var destination_active := false

func update_state(map_id: String, new_ship_pos: Vector3, points: Array[Vector3], selected: int, enemies: Array[Vector3] = [], next_destination: Vector3 = Vector3.ZERO, has_destination: bool = false, boxes: Array[Vector3] = [], ores: Array[Vector3] = [], bonuses: Array[Vector3] = []) -> void:
    current_map = map_id
    ship_pos = new_ship_pos
    portal_points = points
    focused_portal = selected
    enemy_points = enemies
    loot_points = boxes
    ore_points = ores
    bonus_points = bonuses
    destination = next_destination
    destination_active = has_destination
    queue_redraw()

func _to_screen(p: Vector3) -> Vector2:
    var uv := Vector2((p.x + WORLD_HALF.x) / (2.0 * WORLD_HALF.x), (p.z + WORLD_HALF.y) / (2.0 * WORLD_HALF.y))
    return Vector2(7.0, 25.0) + uv * (size - Vector2(14.0, 32.0))

var touch_held := false
var mouse_held := false

func _send_destination(pointer: Vector2) -> void:
    var bounds := size - Vector2(14.0, 32.0)
    if bounds.x <= 0.0 or bounds.y <= 0.0:
        return
    var uv := (pointer - Vector2(7.0, 25.0)) / bounds
    uv = uv.clamp(Vector2.ZERO, Vector2.ONE)
    destination_requested.emit(Vector3((uv.x * 2.0 - 1.0) * WORLD_HALF.x, 0.0, (uv.y * 2.0 - 1.0) * WORLD_HALF.y))

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        var finger := event as InputEventScreenTouch
        if finger.index == 0:
            touch_held = finger.pressed
            if finger.pressed:
                _send_destination(finger.position)
            accept_event()
    elif event is InputEventScreenDrag:
        var movement := event as InputEventScreenDrag
        if touch_held and movement.index == 0:
            _send_destination(movement.position)
            accept_event()
    elif event is InputEventMouseButton:
        var mouse := event as InputEventMouseButton
        if mouse.button_index == MOUSE_BUTTON_LEFT:
            mouse_held = mouse.pressed
            if mouse.pressed:
                _send_destination(mouse.position)
            accept_event()
    elif event is InputEventMouseMotion and mouse_held:
        var move := event as InputEventMouseMotion
        _send_destination(move.position)
        accept_event()

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
    if current_map in ["1-1", "2-1", "3-1"]:
        var base_point: Vector2 = _to_screen(Vector3(0.0, 0.0, 44.0))
        var diamond := PackedVector2Array([base_point + Vector2(0, -7), base_point + Vector2(7, 0), base_point + Vector2(0, 7), base_point + Vector2(-7, 0)])
        draw_colored_polygon(diamond, Color(0.12, 0.81, 1.0))
        draw_circle(base_point, 2.0, Color(0.04, 0.09, 0.19))
        draw_string(ThemeDB.fallback_font, base_point + Vector2(9, 4), "BASE", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.52, 0.91, 1.0))
    if current_map.begins_with("4-"):
        var relay_location: Vector2 = _to_screen(Vector3.ZERO)
        draw_arc(relay_location, 7.0, 0.0, TAU, 16, Color(0.24, 0.94, 1.0), 1.8)
        draw_circle(relay_location, 2.6, Color(0.95, 0.72, 0.23))
    for enemy in enemy_points:
        draw_circle(_to_screen(enemy), 2.9, Color(1.0, 0.39, 0.4))
    for box in loot_points:
        var pixel: Vector2 = _to_screen(box)
        draw_rect(Rect2(pixel - Vector2(2.5, 2.5), Vector2(5.0, 5.0)), Color(1.0, 0.83, 0.27), true)
    for ore in ore_points:
        var pix: Vector2 = _to_screen(ore)
        var crystal: PackedVector2Array = PackedVector2Array([pix + Vector2(0,-3.5),pix + Vector2(3.5,0),pix + Vector2(0,3.5),pix + Vector2(-3.5,0)])
        draw_colored_polygon(crystal, Color(0.23, 0.91, 0.98))
    for bonus in bonus_points:
        var pix: Vector2 = _to_screen(bonus)
        draw_rect(Rect2(pix - Vector2(3.1, 3.1), Vector2(6.2, 6.2)), Color(1.0, 0.68, 0.22), true)
        draw_circle(pix, 1.8, Color(1.0, 0.98, 0.62))
    if destination_active:
        var p := _to_screen(destination)
        draw_line(_to_screen(ship_pos), p, Color(0.88, 0.95, 0.46, 0.65), 1.2)
        draw_arc(p, 6.5, 0.0, TAU, 14, Color(1.0, 0.91, 0.4), 1.4)
    draw_circle(_to_screen(ship_pos), 4.5, Color(0.46, 1, 0.55))
