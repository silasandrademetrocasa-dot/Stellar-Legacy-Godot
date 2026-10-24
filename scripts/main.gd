extends Node3D
## Stellar Legacy Godot G0.2 - navegacao experimental local.
## NAO autentica, NAO consulta Render/Supabase, NAO altera producao.

const Routes = preload("res://scripts/world_routes.gd")
const MinimapUI = preload("res://scripts/ui/mini_map.gd")
const GalaxyUI = preload("res://scripts/ui/galaxy_map.gd")
const SAVE_PATH := "user://stellar_legacy_godot_test.json"
const SHIP_IDS := [
    "AURORA", "BASTION", "BULWARK", "KENSEI", "LEVIATHAN",
    "LYNX", "MERIDIAN", "PATHFINDER", "PHANTOM", "PIONEER",
    "RAPTOR", "SERAPH", "VALKYRIE"
]
const MAX_SPEED := 21.0
const ACCELERATION := 20.0
const DECELERATION := 16.0
const TURN_RATE := 2.6
const WARP_DISTANCE := 10.0

var ship_anchor: Node3D
var ship_visual: Node3D
var game_camera: Camera3D
var sky: WorldEnvironment
var portal_root: Node3D
var hud_layer: CanvasLayer
var hud: Control
var header: Label
var telemetry: Label
var help_label: Label
var portal_hint: Label
var ship_select: OptionButton
var faction_select: OptionButton
var mini_map: Control
var galaxy_map: Control
var galaxy_panel: Panel
var close_galaxy: Button
var warp_button: Button
var route_button: Button
var left_button: Button
var right_button: Button
var thrust_button: Button
var brake_button: Button
var left_held := false
var right_held := false
var thrust_held := false
var brake_held := false
var speed := 0.0
var heading := 0.0
var current_ship := "PIONEER"
var faction := "1"
var current_map := "1-1"
var portals: Array[Dictionary] = []
var nearest_portal := -1
var ui_tick := 0.0
var warp_cooldown := 0.0

func _ready() -> void:
    _read_local_profile()
    _create_world()
    _create_hud()
    _set_ship(current_ship)
    _rebuild_portals()
    _refresh_ui()
    get_viewport().size_changed.connect(_layout_hud)
    _layout_hud()

func _process(delta: float) -> void:
    if ship_anchor == null:
        return
    var turn := int(right_held or Input.is_key_pressed(KEY_D)) - int(left_held or Input.is_key_pressed(KEY_A))
    if galaxy_panel.visible:
        turn = 0
    heading += float(turn) * TURN_RATE * delta
    ship_anchor.rotation.y = heading
    var forward := thrust_held or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
    var braking := brake_held or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN) or galaxy_panel.visible
    speed = move_toward(speed, MAX_SPEED if forward and not braking else 0.0, (ACCELERATION if forward and not braking else DECELERATION) * delta)
    ship_anchor.position += ship_anchor.global_transform.basis.z * speed * delta
    ship_anchor.position.x = clampf(ship_anchor.position.x, -118.0, 118.0)
    ship_anchor.position.z = clampf(ship_anchor.position.z, -88.0, 88.0)
    var desired := ship_anchor.position + Vector3(0, 23, 19)
    game_camera.global_position = game_camera.global_position.lerp(desired, minf(delta * 5.0, 1.0))
    game_camera.look_at(ship_anchor.position, Vector3.UP)
    warp_cooldown = maxf(0.0, warp_cooldown - delta)
    ui_tick -= delta
    if ui_tick <= 0.0:
        ui_tick = 0.11
        _refresh_ui()

func _unhandled_key_input(event: InputEvent) -> void:
    if not (event is InputEventKey):
        return
    var key := event as InputEventKey
    if not key.pressed or key.echo:
        return
    match key.keycode:
        KEY_E: _travel_nearest()
        KEY_M: _toggle_galaxy()
        KEY_R: _return_to_center()

func _create_world() -> void:
    sky = WorldEnvironment.new()
    sky.name = "Cosmos"
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.008, 0.014, 0.036)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.54, 0.66, 0.97)
    env.ambient_light_energy = 0.75
    sky.environment = env
    add_child(sky)
    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-50, 27, -12)
    light.light_energy = 1.55
    add_child(light)
    ship_anchor = Node3D.new()
    ship_anchor.name = "PlayerShip"
    add_child(ship_anchor)
    game_camera = Camera3D.new()
    game_camera.current = true
    game_camera.fov = 56.0
    game_camera.position = Vector3(0, 23, 19)
    add_child(game_camera)
    game_camera.look_at(Vector3.ZERO, Vector3.UP)
    portal_root = Node3D.new()
    portal_root.name = "Portals"
    add_child(portal_root)
    _make_starfield()
    _make_border()

func _make_starfield() -> void:
    var sphere := SphereMesh.new()
    sphere.radius = 0.075
    sphere.height = 0.15
    var mat := StandardMaterial3D.new()
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.albedo_color = Color(0.48, 0.68, 1.0)
    sphere.material = mat
    var multi := MultiMesh.new()
    multi.transform_format = MultiMesh.TRANSFORM_3D
    multi.mesh = sphere
    multi.instance_count = 360
    var rng := RandomNumberGenerator.new()
    rng.seed = 50464
    for i in range(multi.instance_count):
        multi.set_instance_transform(i, Transform3D(Basis(), Vector3(rng.randf_range(-210, 210), -5.0, rng.randf_range(-210, 210))))
    var instance := MultiMeshInstance3D.new()
    instance.name = "Starfield"
    instance.multimesh = multi
    add_child(instance)

func _make_border() -> void:
    var mat := StandardMaterial3D.new()
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.albedo_color = Color(0.1, 0.22, 0.38, 0.45)
    for edge in range(4):
        var wall := MeshInstance3D.new()
        wall.name = "WorldLimit%d" % edge
        var mesh := BoxMesh.new()
        mesh.size = Vector3(240.0, 0.07, 0.25) if edge < 2 else Vector3(0.25, 0.07, 180.0)
        mesh.material = mat
        wall.mesh = mesh
        wall.position = Vector3(0, -0.15, -90.0 if edge == 0 else 90.0) if edge < 2 else Vector3(-120.0 if edge == 2 else 120.0, -0.15, 0)
        add_child(wall)

func _make_button(caption: String) -> Button:
    var btn := Button.new()
    btn.text = caption
    btn.add_theme_font_size_override("font_size", 16)
    btn.custom_minimum_size = Vector2(74, 55)
    hud.add_child(btn)
    return btn

func _make_label(value: String, font_size: int = 15) -> Label:
    var label := Label.new()
    label.text = value
    label.add_theme_color_override("font_color", Color(0.83, 0.93, 1))
    label.add_theme_font_size_override("font_size", font_size)
    hud.add_child(label)
    return label

func _create_hud() -> void:
    hud_layer = CanvasLayer.new()
    add_child(hud_layer)
    hud = Control.new()
    hud.mouse_filter = Control.MOUSE_FILTER_PASS
    hud_layer.add_child(hud)
    header = _make_label("STELLAR LEGACY  |  GODOT", 17)
    telemetry = _make_label("", 14)
    help_label = _make_label("OFFLINE  •  TESTE DE NAVEGACAO", 12)
    portal_hint = _make_label("", 14)
    ship_select = OptionButton.new()
    ship_select.tooltip_text = "Modelos GLB instalados localmente"
    for ship_id in SHIP_IDS:
        ship_select.add_item(ship_id)
    ship_select.item_selected.connect(_on_ship_selected)
    hud.add_child(ship_select)
    faction_select = OptionButton.new()
    for id in Routes.FACTIONS:
        faction_select.add_item(Routes.FACTION_NAMES[id])
    faction_select.item_selected.connect(_on_faction_selected)
    hud.add_child(faction_select)
    warp_button = _make_button("VIAJAR")
    warp_button.pressed.connect(_travel_nearest)
    route_button = _make_button("ROTAS")
    route_button.pressed.connect(_toggle_galaxy)
    left_button = _make_button("◀")
    right_button = _make_button("▶")
    thrust_button = _make_button("AVANCAR")
    brake_button = _make_button("PARAR")
    left_button.button_down.connect(func() -> void: left_held = true)
    left_button.button_up.connect(func() -> void: left_held = false)
    right_button.button_down.connect(func() -> void: right_held = true)
    right_button.button_up.connect(func() -> void: right_held = false)
    thrust_button.button_down.connect(func() -> void: thrust_held = true)
    thrust_button.button_up.connect(func() -> void: thrust_held = false)
    brake_button.button_down.connect(func() -> void: brake_held = true)
    brake_button.button_up.connect(func() -> void: brake_held = false)
    mini_map = MinimapUI.new()
    mini_map.name = "MiniMap"
    mini_map.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hud.add_child(mini_map)
    galaxy_panel = Panel.new()
    galaxy_panel.visible = false
    galaxy_panel.mouse_filter = Control.MOUSE_FILTER_STOP
    hud.add_child(galaxy_panel)
    galaxy_map = GalaxyUI.new()
    galaxy_map.mouse_filter = Control.MOUSE_FILTER_IGNORE
    galaxy_panel.add_child(galaxy_map)
    close_galaxy = Button.new()
    close_galaxy.text = "FECHAR ✕"
    close_galaxy.pressed.connect(_toggle_galaxy)
    galaxy_panel.add_child(close_galaxy)
    ship_select.select(maxi(0, SHIP_IDS.find(current_ship)))
    faction_select.select(maxi(0, Routes.FACTIONS.find(faction)))

func _layout_hud() -> void:
    if hud == null:
        return
    var s := get_viewport().get_visible_rect().size
    hud.size = s
    header.position = Vector2(12, 7)
    header.size = Vector2(maxf(180, s.x - 370), 26)
    telemetry.position = Vector2(12, 32)
    telemetry.size = Vector2(maxf(200, s.x - 30), 26)
    help_label.position = Vector2(12, 57)
    help_label.size = Vector2(310, 22)
    faction_select.position = Vector2(s.x - 334, 7)
    faction_select.size = Vector2(130, 38)
    ship_select.position = Vector2(s.x - 199, 7)
    ship_select.size = Vector2(185, 38)
    mini_map.position = Vector2(s.x - 208, 57)
    mini_map.size = Vector2(194, 129)
    portal_hint.position = Vector2(12, s.y - 143)
    portal_hint.size = Vector2(minf(s.x - 24, 550), 30)
    warp_button.position = Vector2(12, s.y - 107)
    warp_button.size = Vector2(113, 45)
    route_button.position = Vector2(132, s.y - 107)
    route_button.size = Vector2(93, 45)
    left_button.position = Vector2(12, s.y - 55)
    left_button.size = Vector2(80, 49)
    right_button.position = Vector2(98, s.y - 55)
    right_button.size = Vector2(80, 49)
    thrust_button.position = Vector2(s.x - 221, s.y - 68)
    thrust_button.size = Vector2(125, 62)
    brake_button.position = Vector2(s.x - 91, s.y - 68)
    brake_button.size = Vector2(78, 62)
    var w := minf(620.0, s.x - 28.0)
    var h := minf(430.0, s.y - 35.0)
    galaxy_panel.position = (s - Vector2(w, h)) * 0.5
    galaxy_panel.size = Vector2(w, h)
    galaxy_map.position = Vector2.ZERO
    galaxy_map.size = Vector2(w, h)
    close_galaxy.position = Vector2(w - 112, 10)
    close_galaxy.size = Vector2(103, 38)
    galaxy_map.queue_redraw()

func _rebuild_portals() -> void:
    for item in portal_root.get_children():
        item.queue_free()
    portals.clear()
    nearest_portal = -1
    var destinations: Array[String] = Routes.neighbors(current_map, faction)
    for target in destinations:
        var p: Vector3 = Routes.portal_point(current_map, target, faction)
        var gate := Node3D.new()
        gate.name = "Portal_to_" + target
        gate.position = p
        portal_root.add_child(gate)
        var model := load(Routes.portal_model(target)) as PackedScene
        if model != null:
            var visual := model.instantiate() as Node3D
            if visual != null:
                gate.add_child(visual)
                visual.scale = Vector3.ONE * 1.45
        var label := Label3D.new()
        label.text = target
        label.position = Vector3(0, 6.8, 0)
        label.font_size = 50
        label.pixel_size = 0.01
        label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        label.no_depth_test = true
        gate.add_child(label)
        portals.append({"dest": target, "pos": p, "node": gate})
    var bg := Color(0.018, 0.009, 0.045) if Routes.is_pvp(current_map) else (Color(0.006, 0.035, 0.055) if Routes.is_universe(current_map) else Color(0.008, 0.014, 0.036))
    sky.environment.background_color = bg
    galaxy_map.set_route_view(faction, current_map)
    _refresh_ui()

func _nearest_index() -> int:
    var selected := -1
    var min_dist := WARP_DISTANCE
    for i in range(portals.size()):
        var p: Vector3 = portals[i]["pos"]
        var d := ship_anchor.position.distance_to(p)
        if d <= min_dist:
            min_dist = d
            selected = i
    return selected

func _refresh_ui() -> void:
    if hud == null or ship_anchor == null:
        return
    nearest_portal = _nearest_index()
    telemetry.text = "MAPA %s  |  %s  |  NAVE %s  |  VEL %d" % [current_map, Routes.FACTION_NAMES.get(faction, ""), current_ship, roundi(speed)]
    if nearest_portal >= 0:
        var target := str(portals[nearest_portal]["dest"])
        var available := Routes.can_preview(current_map, target, faction)
        portal_hint.text = "PORTAL %s  |  %s" % [target, "PRONTO PARA VIAJAR" if available else "ACESSO BLOQUEADO"]
        warp_button.disabled = not available or warp_cooldown > 0
    else:
        portal_hint.text = "Aproxime-se de um portal marcado no minimapa para viajar"
        warp_button.disabled = true
    var points: Array[Vector3] = []
    for portal in portals:
        points.append(portal["pos"])
    mini_map.update_state(current_map, ship_anchor.position, points, nearest_portal)

func _travel_nearest() -> void:
    var selected := _nearest_index()
    if selected < 0 or warp_cooldown > 0.0:
        return
    var target: String = portals[selected]["dest"]
    if not Routes.can_preview(current_map, target, faction):
        return
    var source := current_map
    current_map = target
    _rebuild_portals()
    var entry := Vector3.ZERO
    for portal in portals:
        if str(portal["dest"]) == source:
            entry = portal["pos"]
            break
    var toward_center := -entry.normalized()
    if toward_center.length() < 0.1:
        toward_center = Vector3(0, 0, 1)
    ship_anchor.position = entry + toward_center * 16.0
    heading = atan2(toward_center.x, toward_center.z)
    ship_anchor.rotation.y = heading
    speed = 0.0
    warp_cooldown = 1.5
    _write_local_profile()
    _refresh_ui()

func _toggle_galaxy() -> void:
    galaxy_panel.visible = not galaxy_panel.visible
    if galaxy_panel.visible:
        galaxy_map.set_route_view(faction, current_map)
        left_held = false
        right_held = false
        thrust_held = false
        brake_held = false

func _return_to_center() -> void:
    ship_anchor.position = Vector3.ZERO
    speed = 0.0
    _refresh_ui()

func _on_faction_selected(index: int) -> void:
    if index < 0 or index >= Routes.FACTIONS.size():
        return
    faction = Routes.FACTIONS[index]
    current_map = "%s-1" % faction
    _return_to_center()
    _rebuild_portals()
    _write_local_profile()

func _on_ship_selected(index: int) -> void:
    if index >= 0 and index < SHIP_IDS.size():
        _set_ship(SHIP_IDS[index])

func _set_ship(ship_id: String) -> void:
    var file := "res://assets/ships/SL_%s_FINAL.glb" % ship_id
    var res := load(file) as PackedScene
    if res == null:
        push_warning("GLB ausente: " + file)
        return
    var inst := res.instantiate() as Node3D
    if inst == null:
        return
    if ship_visual != null:
        ship_visual.queue_free()
    ship_visual = inst
    ship_visual.name = ship_id
    ship_anchor.add_child(ship_visual)
    current_ship = ship_id
    ship_select.select(maxi(0, SHIP_IDS.find(ship_id)))
    _write_local_profile()

func _read_local_profile() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if f == null:
        return
    var parsed = JSON.parse_string(f.get_as_text())
    if not (parsed is Dictionary):
        return
    var saved_faction := str(parsed.get("faction", "1"))
    var saved_map := str(parsed.get("map", "1-1"))
    var saved_ship := str(parsed.get("ship", "PIONEER"))
    if saved_faction in Routes.FACTIONS:
        faction = saved_faction
    if Routes.valid_map(saved_map) and (saved_map.begins_with(faction + "-") or saved_map.begins_with("4-") or saved_map.begins_with("U-")):
        current_map = saved_map
    if saved_ship in SHIP_IDS:
        current_ship = saved_ship

func _write_local_profile() -> void:
    var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if f != null:
        f.store_string(JSON.stringify({"faction": faction, "map": current_map, "ship": current_ship}))
