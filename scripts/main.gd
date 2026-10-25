extends Node3D
## Stellar Legacy Godot G0.7 - combate local, coleta e progressao demonstrativa.
## NAO autentica, NAO consulta Render/Supabase, NAO altera producao.

const Routes = preload("res://scripts/world_routes.gd")
const MinimapUI = preload("res://scripts/ui/mini_map.gd")
const GalaxyUI = preload("res://scripts/ui/galaxy_map.gd")
const CombatWorld = preload("res://scripts/world/combat_world.gd")
const FleetSupport = preload("res://scripts/world/fleet_support.gd")
const StellarHUD = preload("res://scripts/ui/stellar_hud.gd")
const StellarWallet = preload("res://scripts/systems/stellar_wallet.gd")
const ShipBalance = preload("res://scripts/data/ship_balance.gd")
const EquipmentState = preload("res://scripts/systems/equipment_state.gd")
const PilotProgress = preload("res://scripts/systems/pilot_progress.gd")
const HubStore = preload("res://scripts/systems/stellar_hub.gd")
const AstralTrials = preload("res://scripts/systems/astral_trials.gd")
const AstralEnvironment = preload("res://scripts/world/astral_environment.gd")
const FactionBase = preload("res://scripts/world/faction_base.gd")
const SAVE_PATH := "user://stellar_legacy_godot_g015_test.json"
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
const ARRIVAL_DISTANCE := 2.2
const CHASE_DISTANCE := 46.0
const DOUBLE_TAP_MS := 420

var ship_anchor: Node3D
var ship_visual: Node3D
var game_camera: Camera3D
var sky: WorldEnvironment
var portal_root: Node3D
var faction_base
var astral_environment: Node3D
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
var combat_world
var support_fleet
var target_button: Button
var fire_button: Button
var drones_button: Button
var aux_button: Button
var combat_label: Label
var target_label: Label
var status_label: Label
var hp_bar: ProgressBar
var shield_bar: ProgressBar
var target_hp_bar: ProgressBar
var target_shield_bar: ProgressBar
var firing_held := false
var hp: float = 104000.0
var shield := 8000.0
var MAX_HP: float = 104000.0
var MAX_SHIELD: float = 8000.0
var combat_recovery_clock := 0.0
# Comandos locais: destino, perseguição, mira e disparo independente do servidor.
var destination := Vector3.ZERO
var destination_active := false
var chase_target := false
var auto_fire_enabled := false
var last_enemy_tapped: Node3D
var last_tap_ms := -1000
var last_tap_screen := Vector2(-9999, -9999)
var marker: MeshInstance3D
var travel_heading := 0.0
var ui_shell
var selected_ammo := 0
var show_fps := true
var starfield: MultiMeshInstance3D
var equipment_state
var wallet
var pilot_progress
var hub_store
var astral_trials
var graphics_quality: String = "MEDIO"
var cinematic_light: DirectionalLight3D
var relay_visual: Node3D
var relay_ring: MeshInstance3D
var active_touch := -1
var world_mouse_dragging := false
var drag_last_position := Vector2(-5000.0, -5000.0)
var drag_update_clock := 0.0
var afterburner: Node3D
var exhausts: Array[MeshInstance3D] = []



func _ready() -> void:
    equipment_state = EquipmentState.new()
    wallet = StellarWallet.new()
    pilot_progress = PilotProgress.new()
    hub_store = HubStore.new()
    astral_trials = AstralTrials.new()
    _read_local_profile()
    # G0.13: o inventario antigo recebe um kit inicial unico; naves nao compradas ficam bloqueadas.
    if not equipment_state.owns_ship(current_ship):
        current_ship = "AURORA"
        _write_local_profile()
    _create_world()
    set_graphics_quality(graphics_quality, false)
    _create_hud()
    _install_new_hud()
    _set_ship(current_ship)
    _on_equipment_changed()
    select_ammunition(selected_ammo)
    _rebuild_portals()
    _populate_local_world()
    pilot_progress.visit_map(current_map)
    support_fleet.apply_equipment(equipment_state)
    _refresh_ui()
    get_viewport().size_changed.connect(_layout_hud)
    _layout_hud()

func _process(delta: float) -> void:
    if ship_anchor == null:
        return
    # O resultado de uma chamada dinamica no HUD e Variant: declarar bool explicitamente.
    var blocked: bool = galaxy_panel.visible
    if ui_shell != null and is_instance_valid(ui_shell) and ui_shell.has_method("modal_open"):
        blocked = blocked or bool(ui_shell.call("modal_open"))
    var manual_turn := int(right_held or Input.is_key_pressed(KEY_D)) - int(left_held or Input.is_key_pressed(KEY_A))
    var manual_thrust := thrust_held or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
    var manual_brake := brake_held or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)
    if (manual_turn != 0 or manual_thrust or manual_brake) and not blocked:
        _clear_autonavigation()
        # G0.5: a ordem de movimento NUNCA cancela o travamento nem o tiro.

    var desired_speed := 0.0
    var local_max_speed: float = MAX_SPEED * (float(ShipBalance.get_ship(current_ship).get("speed", 320)) / 320.0) + equipment_state.bonus("MOTORES") if equipment_state != null else MAX_SPEED
    var unit: Node3D = combat_world.get_selected_enemy()
    var firing_now := auto_fire_enabled or firing_held or Input.is_key_pressed(KEY_SPACE)
    var movement_vector := Vector3.ZERO
    var has_navigation := false

    # Dois vetores independentes: deslocamento (travel_heading) e mira (heading).
    # O toque no mapa troca apenas o destino. O alvo e o disparo permanecem ativos.
    if not blocked and destination_active:
        var toward := destination - ship_anchor.position
        toward.y = 0.0
        var remaining := toward.length()
        if remaining <= ARRIVAL_DISTANCE:
            _clear_autonavigation()
        else:
            movement_vector = toward.normalized()
            has_navigation = true
            desired_speed = minf(local_max_speed, sqrt(maxf(0.0, 2.0 * DECELERATION * (remaining - ARRIVAL_DISTANCE))))
    elif not blocked and chase_target and unit != null:
        var to_enemy := unit.global_position - ship_anchor.global_position
        to_enemy.y = 0.0
        if to_enemy.length() > CHASE_DISTANCE:
            movement_vector = to_enemy.normalized()
            has_navigation = true
            desired_speed = minf(local_max_speed, sqrt(maxf(0.0, 2.0 * DECELERATION * (to_enemy.length() - CHASE_DISTANCE))))
    elif not blocked:
        travel_heading += float(manual_turn) * TURN_RATE * delta
        movement_vector = Vector3(sin(travel_heading), 0.0, cos(travel_heading))
        desired_speed = local_max_speed if manual_thrust and not manual_brake else 0.0

    if has_navigation:
        travel_heading = atan2(movement_vector.x, movement_vector.z)
    # Visual do casco aponta para o alvo durante tiro; nave transladando em outra direção.
    var facing := travel_heading
    if not blocked and firing_now and unit != null and unit.visible:
        var aim_dir := unit.global_position - ship_anchor.global_position
        aim_dir.y = 0.0
        if aim_dir.length_squared() > 0.01:
            facing = atan2(aim_dir.x, aim_dir.z)
    heading = lerp_angle(heading, facing, minf(TURN_RATE * delta * 1.5, 1.0))
    ship_anchor.rotation.y = heading
    speed = move_toward(speed, desired_speed if not blocked else 0.0, (ACCELERATION if desired_speed > speed else DECELERATION) * delta)
    ship_anchor.position += movement_vector * speed * delta
    _animate_engine(delta)
    ship_anchor.position.x = clampf(ship_anchor.position.x, -118.0, 118.0)
    ship_anchor.position.z = clampf(ship_anchor.position.z, -88.0, 88.0)
    combat_world.collect_nearby(ship_anchor.global_position)
    if hub_store != null and Routes.is_pvp(current_map):
        var relay_event: String = hub_store.relay_tick(current_map, faction, ship_anchor.position.length(), delta)
        if not relay_event.is_empty() and ui_shell != null:
            ui_shell.show_notification(relay_event)
            _update_relay_color()
    if relay_ring != null and is_instance_valid(relay_ring):
        relay_ring.rotate_y(delta * 0.5)
    if destination_active and ship_anchor.position.distance_to(destination) <= ARRIVAL_DISTANCE:
        _clear_autonavigation()
        speed = 0.0

    if not blocked and firing_now and unit != null and unit.visible:
        if ship_anchor.position.distance_to(unit.global_position) <= combat_world.LASER_RANGE:
            if selected_ammo == 4:
                combat_world.fire_missile_from_player()
            else:
                combat_world.fire_from_player()
    if unit == null and auto_fire_enabled:
        auto_fire_enabled = false
        fire_button.text = "LASER"
        chase_target = false

    combat_recovery_clock = maxf(0.0, combat_recovery_clock - delta)
    if combat_recovery_clock <= 0.0:
        var has_repairer: bool = equipment_state != null and equipment_state.equipped("EXTRAS").has("REPARADOR COMUM")
        if aux_enabled():
            shield = minf(MAX_SHIELD, shield + 85.0 * delta)
        elif has_repairer:
            hp = minf(MAX_HP, hp + 18.0 * delta)
    var desired_camera := ship_anchor.position + Vector3(0, 23, 19)
    game_camera.global_position = game_camera.global_position.lerp(desired_camera, minf(delta * 5.0, 1.0))
    game_camera.look_at(ship_anchor.position, Vector3.UP)
    warp_cooldown = maxf(0.0, warp_cooldown - delta)
    ui_tick -= delta
    if ui_tick <= 0.0:
        ui_tick = 0.12
        _refresh_ui()

func _clear_autonavigation() -> void:
    destination_active = false
    chase_target = false
    if marker != null:
        marker.visible = false

func _set_destination(point: Vector3) -> void:
    destination = Vector3(clampf(point.x, -118.0, 118.0), 0.0, clampf(point.z, -88.0, 88.0))
    destination_active = true
    chase_target = false
    # A nave mantém o tiro ativo e o NPC selecionado ao receber novo destino.
    if marker != null:
        marker.position = destination + Vector3.UP * 0.02
        marker.visible = true
    # O HUD atualiza a cada 0.12s; nao reconstruir interface a cada drag.

func _on_world_tap(screen_point: Vector2, reported_double: bool = false) -> void:
    if galaxy_panel.visible:
        return
    var tapped_enemy: Node3D = combat_world.enemy_at_screen(screen_point, game_camera)
    if tapped_enemy != null:
        var ms := Time.get_ticks_msec()
        var is_double := tapped_enemy == last_enemy_tapped and (reported_double or (ms - last_tap_ms <= DOUBLE_TAP_MS and last_tap_screen.distance_to(screen_point) <= 55.0))
        last_enemy_tapped = tapped_enemy
        last_tap_ms = ms
        last_tap_screen = screen_point
        combat_world.select_enemy(tapped_enemy)
        _clear_autonavigation()
        chase_target = true
        if is_double:
            auto_fire_enabled = true
            fire_button.text = "PARAR LASER"
        # Toque simples troca o alvo sem interromper fogo já habilitado.
        _refresh_ui()
        return
    last_enemy_tapped = null
    var chosen_drop: Dictionary = combat_world.loot_at_screen(screen_point, game_camera)
    if not chosen_drop.is_empty():
        var point: Vector3 = chosen_drop["position"]
        _set_destination(point)
        combat_world._message("Indo coletar caixa estelar")
        return
    var origin := game_camera.project_ray_origin(screen_point)
    var direction := game_camera.project_ray_normal(screen_point)
    var ground = Plane(Vector3.UP, 0.0).intersects_ray(origin, direction)
    if ground is Vector3:
        _set_destination(ground)

func _screen_destination(screen_point: Vector2) -> void:
    if galaxy_panel.visible or (ui_shell != null and ui_shell.modal_open()):
        return
    var origin: Vector3 = game_camera.project_ray_origin(screen_point)
    var direction: Vector3 = game_camera.project_ray_normal(screen_point)
    var ground: Variant = Plane(Vector3.UP, 0.0).intersects_ray(origin, direction)
    if ground is Vector3:
        _set_destination(ground)

func _unhandled_input(event: InputEvent) -> void:
    # Recebe somente toques nao capturados pelo HUD, menus ou minimapa.
    if event is InputEventScreenTouch:
        var finger := event as InputEventScreenTouch
        if finger.index == 0:
            if finger.pressed:
                active_touch = finger.index
                drag_last_position = finger.position
                _on_world_tap(finger.position, finger.double_tap)
            else:
                active_touch = -1
            get_viewport().set_input_as_handled()
    elif event is InputEventScreenDrag:
        var finger_drag := event as InputEventScreenDrag
        if active_touch == finger_drag.index:
            # Rota continua seguindo a posicao atual do dedo sem cancelar laser.
            if finger_drag.position.distance_squared_to(drag_last_position) >= 3.0:
                drag_last_position = finger_drag.position
                _screen_destination(finger_drag.position)
            get_viewport().set_input_as_handled()
    elif event is InputEventMouseButton and not OS.has_feature("mobile"):
        var mouse := event as InputEventMouseButton
        if mouse.button_index == MOUSE_BUTTON_LEFT:
            world_mouse_dragging = mouse.pressed
            if mouse.pressed:
                drag_last_position = mouse.position
                _on_world_tap(mouse.position, mouse.double_click)
            get_viewport().set_input_as_handled()
    elif event is InputEventMouseMotion and world_mouse_dragging and not OS.has_feature("mobile"):
        var move := event as InputEventMouseMotion
        if move.position.distance_squared_to(drag_last_position) >= 9.0:
            drag_last_position = move.position
            _screen_destination(move.position)
        get_viewport().set_input_as_handled()

func _select_next_target() -> void:
    combat_world.select_nearest()
    if combat_world.get_selected_enemy() != null:
        if not destination_active:
            chase_target = true

func _toggle_auto_fire() -> void:
    if combat_world.get_selected_enemy() == null:
        combat_world._message("Toque em um NPC para escolher o alvo")
        return
    auto_fire_enabled = not auto_fire_enabled
    fire_button.text = "PARAR LASER" if auto_fire_enabled else "LASER"
    if auto_fire_enabled and not destination_active:
        chase_target = true

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
    light.shadow_enabled = false
    cinematic_light = light
    add_child(light)
    ship_anchor = Node3D.new()
    ship_anchor.name = "PlayerShip"
    add_child(ship_anchor)
    _create_engine_effect()
    game_camera = Camera3D.new()
    game_camera.current = true
    game_camera.fov = 56.0
    game_camera.position = Vector3(0, 23, 19)
    add_child(game_camera)
    game_camera.look_at(Vector3.ZERO, Vector3.UP)
    portal_root = Node3D.new()
    portal_root.name = "Portals"
    add_child(portal_root)
    astral_environment = AstralEnvironment.new()
    astral_environment.name = "AstralEnvironment"
    add_child(astral_environment)
    combat_world = CombatWorld.new()
    combat_world.name = "CombatWorld"
    add_child(combat_world)
    combat_world.player_node = ship_anchor
    combat_world.incoming_damage.connect(_receive_local_damage)
    combat_world.enemy_destroyed.connect(_on_enemy_destroyed)
    combat_world.loot_collected.connect(_on_loot_collected)
    combat_world.astral_wave_finished.connect(_on_astral_wave_finished)
    support_fleet = FleetSupport.new()
    support_fleet.name = "SupportFleet"
    add_child(support_fleet)
    support_fleet.player_node = ship_anchor
    support_fleet.combat_world = combat_world
    _make_starfield()
    _make_border()
    _make_navigation_marker()

func _create_engine_effect() -> void:
    afterburner = Node3D.new()
    afterburner.name = "LocalThrusterFX"
    ship_anchor.add_child(afterburner)
    for i in range(2):
        var jet := MeshInstance3D.new()
        var mesh := SphereMesh.new()
        mesh.radius = 0.23
        mesh.height = 1.1
        mesh.radial_segments = 8
        mesh.rings = 5
        var mat := StandardMaterial3D.new()
        mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        mat.albedo_color = Color(0.07, 0.56, 1.0, 0.76)
        mat.emission_enabled = true
        mat.emission = Color(0.04, 0.48, 1.0)
        mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        mesh.material = mat
        jet.mesh = mesh
        jet.position = Vector3(-0.7 if i == 0 else 0.7, 0.0, 1.2)
        afterburner.add_child(jet)
        exhausts.append(jet)

func _animate_engine(delta: float) -> void:
    if afterburner == null:
        return
    var strength := clampf(speed / (MAX_SPEED + 12.0), 0.0, 1.0)
    afterburner.rotation.y += delta * 0.15
    for i in range(exhausts.size()):
        var jet := exhausts[i]
        jet.scale = Vector3(0.45 + strength * 0.42, 0.38 + strength * 0.18, 0.35 + strength * 0.8)
        jet.visible = strength > 0.06

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
    starfield = instance
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

func _make_navigation_marker() -> void:
    var ring := TorusMesh.new()
    ring.inner_radius = 0.85
    ring.outer_radius = 1.1
    var material := StandardMaterial3D.new()
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    material.albedo_color = Color(1.0, 0.9, 0.32, 0.8)
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    ring.material = material
    marker = MeshInstance3D.new()
    marker.name = "DestinationRing"
    marker.mesh = ring
    marker.visible = false
    add_child(marker)

func _make_button(caption: String) -> Button:
    var btn := Button.new()
    btn.text = caption
    btn.add_theme_font_size_override("font_size", 16)
    btn.custom_minimum_size = Vector2(74, 55)
    hud.add_child(btn)
    return btn

func _make_combat_bar(tint: Color) -> ProgressBar:
    var bar := ProgressBar.new()
    bar.show_percentage = false
    bar.max_value = 100.0
    bar.value = 100.0
    bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var fg := StyleBoxFlat.new()
    fg.bg_color = tint
    fg.corner_radius_top_left = 3
    fg.corner_radius_top_right = 3
    fg.corner_radius_bottom_left = 3
    fg.corner_radius_bottom_right = 3
    var bg := StyleBoxFlat.new()
    bg.bg_color = Color(0.06, 0.09, 0.16, 0.93)
    bar.add_theme_stylebox_override("fill", fg)
    bar.add_theme_stylebox_override("background", bg)
    hud.add_child(bar)
    return bar

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
    help_label = _make_label("TOQUE NO MAPA PARA MOVER  •  TOQUE NO NPC PARA SEGUIR  •  2 TOQUES PARA ATACAR", 12)
    portal_hint = _make_label("", 14)
    combat_label = _make_label("HP / ESC", 12)
    target_label = _make_label("SEM ALVO", 13)
    status_label = _make_label("NPCs e drones de teste", 12)
    hp_bar = _make_combat_bar(Color(0.25, 0.9, 0.52))
    shield_bar = _make_combat_bar(Color(0.26, 0.68, 1.0))
    target_hp_bar = _make_combat_bar(Color(1.0, 0.38, 0.37))
    target_shield_bar = _make_combat_bar(Color(0.8, 0.48, 1.0))
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
    target_button = _make_button("ALVO")
    target_button.pressed.connect(_select_next_target)
    fire_button = _make_button("LASER")
    fire_button.pressed.connect(_toggle_auto_fire)
    drones_button = _make_button("DRONES ON")
    drones_button.pressed.connect(_toggle_drones)
    aux_button = _make_button("AUX-9 ON")
    aux_button.pressed.connect(_toggle_aux)
    mini_map = MinimapUI.new()
    mini_map.name = "MiniMap"
    mini_map.mouse_filter = Control.MOUSE_FILTER_STOP
    mini_map.destination_requested.connect(_set_destination)
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
    help_label.size = Vector2(minf(s.x - 228.0, 750.0), 22)
    faction_select.position = Vector2(s.x - 334, 7)
    faction_select.size = Vector2(130, 38)
    ship_select.position = Vector2(s.x - 199, 7)
    ship_select.size = Vector2(185, 38)
    mini_map.position = Vector2(s.x - 208, 57)
    mini_map.size = Vector2(194, 129)
    combat_label.position = Vector2(12, 86)
    combat_label.size = Vector2(345, 19)
    hp_bar.position = Vector2(12, 109)
    hp_bar.size = Vector2(minf(305.0, s.x * 0.47), 9)
    shield_bar.position = Vector2(12, 124)
    shield_bar.size = hp_bar.size
    target_label.position = Vector2(12, 149)
    target_label.size = Vector2(minf(400.0, s.x * 0.6), 25)
    target_hp_bar.position = Vector2(12, 176)
    target_hp_bar.size = Vector2(minf(305.0, s.x * 0.47), 8)
    target_shield_bar.position = Vector2(12, 190)
    target_shield_bar.size = target_hp_bar.size
    status_label.position = Vector2(12, 207)
    status_label.size = Vector2(minf(420.0, s.x * 0.63), 30)
    drones_button.position = Vector2(s.x - 205, 194)
    drones_button.size = Vector2(100, 41)
    aux_button.position = Vector2(s.x - 101, 194)
    aux_button.size = Vector2(92, 41)
    portal_hint.position = Vector2(12, s.y - 93)
    portal_hint.size = Vector2(minf(s.x - 24, 550), 30)
    warp_button.position = Vector2(12, s.y - 60)
    warp_button.size = Vector2(113, 45)
    route_button.position = Vector2(132, s.y - 60)
    route_button.size = Vector2(93, 45)
    target_button.position = Vector2(232, s.y - 60)
    target_button.size = Vector2(93, 45)
    fire_button.position = Vector2(332, s.y - 60)
    fire_button.size = Vector2(100, 45)
    var w := minf(620.0, s.x - 28.0)
    var h := minf(430.0, s.y - 35.0)
    galaxy_panel.position = (s - Vector2(w, h)) * 0.5
    galaxy_panel.size = Vector2(w, h)
    galaxy_map.position = Vector2.ZERO
    galaxy_map.size = Vector2(w, h)
    close_galaxy.position = Vector2(w - 112, 10)
    close_galaxy.size = Vector2(103, 38)
    galaxy_map.queue_redraw()
    if ui_shell != null:
        ui_shell.relayout(s)

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
        label.text = ("PORTAL " + Routes.astral_label(target)) if Routes.is_astral(target) else target
        label.position = Vector3(0, 6.8, 0)
        label.font_size = 50
        label.pixel_size = 0.01
        label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        label.no_depth_test = true
        gate.add_child(label)
        portals.append({"dest": target, "pos": p, "node": gate})
    _build_relay_visual()
    _build_faction_base()
    if astral_environment != null:
        astral_environment.reset_arena(current_map, graphics_quality)
    var bg := Color(0.018, 0.009, 0.045) if Routes.is_pvp(current_map) else (Color(0.006, 0.035, 0.055) if Routes.is_universe(current_map) else Color(0.008, 0.014, 0.036))
    if Routes.is_astral(current_map):
        bg = Routes.ASTRAL_COLORS[current_map].darkened(0.93)
    sky.environment.background_color = bg
    galaxy_map.set_route_view(faction, current_map)
    _refresh_ui()

func _build_faction_base() -> void:
    faction_base = null
    if current_map != "%s-1" % faction:
        return
    faction_base = FactionBase.new()
    faction_base.position = Vector3(0.0, -4.5, 44.0)
    portal_root.add_child(faction_base)
    faction_base.build(faction)
    faction_base.set_quality(graphics_quality)

func near_faction_base() -> bool:
    return faction_base != null and is_instance_valid(faction_base) and ship_anchor != null and Vector2(ship_anchor.global_position.x, ship_anchor.global_position.z).distance_to(Vector2(faction_base.global_position.x, faction_base.global_position.z)) < 29.0

func open_faction_base() -> void:
    if near_faction_base():
        if ui_shell != null:
            ui_shell._open_modal("HANGAR")
    elif ui_shell != null:
        ui_shell.show_notification("APROXIME-SE DA BASE DA FACCAO EM X-1")

func _build_relay_visual() -> void:
    relay_visual = null
    relay_ring = null
    if not Routes.is_pvp(current_map):
        return
    relay_visual = Node3D.new()
    relay_visual.name = "ReleEstelar_Offline_4X"
    portal_root.add_child(relay_visual)
    for i in range(6):
        var spire := MeshInstance3D.new()
        var column := CylinderMesh.new()
        column.top_radius = 0.18
        column.bottom_radius = 0.48
        column.height = 6.5
        spire.mesh = column
        var metal := StandardMaterial3D.new()
        metal.albedo_color = Color(0.13, 0.25, 0.4)
        metal.metallic = 0.78
        metal.roughness = 0.28
        spire.material_override = metal
        var theta: float = TAU * float(i) / 6.0
        spire.position = Vector3(cos(theta) * 6.0, 3.0, sin(theta) * 6.0)
        relay_visual.add_child(spire)
    var core := MeshInstance3D.new()
    var capsule := SphereMesh.new()
    capsule.radius = 1.8
    capsule.height = 3.6
    core.mesh = capsule
    core.position = Vector3(0, 4.1, 0)
    relay_visual.add_child(core)
    relay_ring = MeshInstance3D.new()
    var torus := TorusMesh.new()
    torus.inner_radius = 5.0
    torus.outer_radius = 5.35
    relay_ring.mesh = torus
    relay_ring.position = Vector3(0, 1.4, 0)
    relay_visual.add_child(relay_ring)
    var tag := Label3D.new()
    tag.text = "RELE %s  |  CAPTURA LOCAL" % current_map
    tag.font_size = 44
    tag.pixel_size = 0.012
    tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    tag.no_depth_test = true
    tag.position = Vector3(0, 9.0, 0)
    relay_visual.add_child(tag)
    _update_relay_color()

func _update_relay_color() -> void:
    if relay_visual == null or not is_instance_valid(relay_visual):
        return
    var owner: String = str(hub_store.relay_owners.get(current_map, ""))
    var tint := Color(0.28, 0.84, 1.0)
    match owner:
        "1": tint = Color(0.22, 0.65, 1.0)
        "2": tint = Color(1.0, 0.26, 0.29)
        "3": tint = Color(0.37, 1.0, 0.42)
    var glow := StandardMaterial3D.new()
    glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    glow.albedo_color = tint
    glow.emission_enabled = true
    glow.emission = tint
    if relay_ring != null:
        relay_ring.material_override = glow
    var central: Node = relay_visual.get_child(6)
    if central is MeshInstance3D:
        (central as MeshInstance3D).material_override = glow

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
    telemetry.text = "MAPA %s  |  %s  |  NAVE %s  |  VEL %d  |  FPS %d" % [current_map, Routes.FACTION_NAMES.get(faction, ""), current_ship, roundi(speed), Engine.get_frames_per_second()]
    if nearest_portal >= 0:
        var target := str(portals[nearest_portal]["dest"])
        var available := Routes.can_preview(current_map, target, faction)
        portal_hint.text = "PORTAL %s  |  %s" % [target, "PRONTO PARA VIAJAR" if available else "ACESSO BLOQUEADO"]
        warp_button.disabled = not available or warp_cooldown > 0
    else:
        portal_hint.text = "Toque no cenário/minimapa para navegar; aproxime-se do portal para VIAJAR"
        warp_button.disabled = true
    var points: Array[Vector3] = []
    for portal in portals:
        points.append(portal["pos"])
    mini_map.update_state(current_map, ship_anchor.position, points, nearest_portal, combat_world.enemy_positions(), destination, destination_active, combat_world.loot_positions())
    combat_label.text = "HP %d / %d   ESC %d / %d" % [roundi(hp), roundi(MAX_HP), roundi(shield), roundi(MAX_SHIELD)]
    hp_bar.value = 100.0 * hp / MAX_HP
    shield_bar.value = 100.0 * shield / MAX_SHIELD
    var target: Dictionary = combat_world.target_status()
    var has_target := not target.is_empty()
    target_hp_bar.visible = has_target
    target_shield_bar.visible = has_target
    if has_target:
        target_label.text = "%s  •  %dm" % [str(target["name"]), roundi(float(target["distance"]))]
        target_hp_bar.value = 100.0 * float(target["hp"]) / maxf(1.0, float(target["max_hp"]))
        target_shield_bar.value = 100.0 * float(target["shield"]) / maxf(1.0, float(target["max_shield"]))
    else:
        target_label.text = "SEM ALVO  •  toque no NPC ou use ALVO"
    status_label.text = "%s  |  KOs locais: %d" % [combat_world.status_message if combat_world.status_clock > 0.0 else "NPCs: %d ativos" % combat_world.enemy_positions().size(), combat_world.kills]
    # As barras antigas ficam ocultas; nova interface agora mostra o combate.
    if ui_shell != null:
        target_hp_bar.visible = false
        target_shield_bar.visible = false
        ui_shell.refresh()

func _travel_nearest() -> void:
    var selected := _nearest_index()
    if selected < 0 or warp_cooldown > 0.0:
        return
    var target: String = portals[selected]["dest"]
    if not Routes.can_preview(current_map, target, faction):
        return
    _clear_autonavigation()
    auto_fire_enabled = false
    fire_button.text = "LASER"
    var source := current_map
    if Routes.is_astral(source):
        astral_trials.leave()
    if Routes.is_astral(target):
        if not astral_trials.consume_entry(target):
            if ui_shell != null:
                ui_shell.show_notification("CHAVE ASTRAL NECESSARIA: CENTRAL > PORTAIS > MATERIALIZAR (OFFLINE)")
            return
        astral_trials.begin(target)
        hp = MAX_HP
        shield = MAX_SHIELD
    current_map = target
    pilot_progress.visit_map(current_map)
    _rebuild_portals()
    _populate_local_world()
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
    travel_heading = heading
    ship_anchor.rotation.y = heading
    speed = 0.0
    firing_held = false
    support_fleet.snap_to_player()
    warp_cooldown = 1.5
    _write_local_profile()
    _refresh_ui()

func _toggle_galaxy() -> void:
    galaxy_panel.visible = not galaxy_panel.visible
    if galaxy_panel.visible:
        galaxy_panel.move_to_front()
        firing_held = false
        _clear_autonavigation()
        auto_fire_enabled = false
        fire_button.text = "LASER"
        galaxy_map.set_route_view(faction, current_map)
        left_held = false
        right_held = false
        thrust_held = false
        brake_held = false

func _return_to_center() -> void:
    _clear_autonavigation()
    auto_fire_enabled = false
    fire_button.text = "LASER"
    ship_anchor.position = Vector3.ZERO
    speed = 0.0
    _refresh_ui()

func _on_faction_selected(index: int) -> void:
    if index < 0 or index >= Routes.FACTIONS.size():
        return
    faction = Routes.FACTIONS[index]
    current_map = "%s-1" % faction
    pilot_progress.visit_map(current_map)
    _return_to_center()
    support_fleet.snap_to_player()
    _rebuild_portals()
    _populate_local_world()
    _write_local_profile()

func _on_ship_selected(index: int) -> void:
    if index >= 0 and index < SHIP_IDS.size():
        change_ship_for_hangar(SHIP_IDS[index])

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
    equipment_state.set_active_ship(ship_id)
    var profile: Dictionary = ShipBalance.get_ship(ship_id)
    var old_max: float = maxf(1.0, MAX_HP)
    MAX_HP = float(profile.get("hp", MAX_HP))
    hp = clampf(hp / old_max * MAX_HP, 1.0, MAX_HP)
    ship_select.select(maxi(0, SHIP_IDS.find(ship_id)))
    _write_local_profile()
    if ui_shell != null:
        ui_shell.refresh()

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
    selected_ammo = clampi(int(parsed.get("ammo", 0)), 0, 4)
    show_fps = bool(parsed.get("show_fps", true))
    var saved_quality: String = str(parsed.get("quality", "MEDIO"))
    graphics_quality = saved_quality if saved_quality in ["BAIXO", "MEDIO", "ALTO"] else "MEDIO"

func _write_local_profile() -> void:
    var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if f != null:
        var saved_map: String = ("%s-1" % faction) if Routes.is_astral(current_map) else current_map
        f.store_string(JSON.stringify({"faction": faction, "map": saved_map, "ship": current_ship, "ammo": selected_ammo, "show_fps": show_fps, "quality": graphics_quality}))

# Extensao G0.3: a navegacao G0.2 permanece intacta.
func _populate_local_world() -> void:
    var points: Array[Vector3] = []
    for portal in portals:
        points.append(portal["pos"])
    if Routes.is_astral(current_map):
        combat_world.configure_astral(current_map, astral_trials.wave)
    else:
        combat_world.configure(current_map, points)

func _on_astral_wave_finished(wave_number: int) -> void:
    if not Routes.is_astral(current_map) or wave_number != astral_trials.wave:
        return
    var completed: bool = astral_trials.record_wave()
    if completed:
        var reward: int = int(AstralTrials.ARENAS[current_map]["reward"])
        pilot_progress.total_xp += reward
        pilot_progress.credits += reward
        pilot_progress._event("Portal %s concluido: +%d XP / CRED" % [Routes.astral_label(current_map),reward])
        pilot_progress._save()
        if ui_shell != null:
            ui_shell.show_notification("PORTAL %s CONCLUIDO! 3 ONDAS  |  +%d XP / CRED (TESTE)" % [Routes.astral_label(current_map), reward])
        return
    if ui_shell != null:
        ui_shell.show_notification("ONDA %d COMPLETA!  PREPARANDO ONDA %d" % [wave_number, astral_trials.wave])
    get_tree().create_timer(1.8).timeout.connect(_start_next_astral_wave.bind(current_map,astral_trials.wave))

func _start_next_astral_wave(expected_map: String, next_wave: int) -> void:
    if current_map == expected_map and Routes.is_astral(current_map) and astral_trials.wave == next_wave and not astral_trials.finished:
        combat_world.configure_astral(current_map,next_wave)

## Perfil de qualidade nao altera GLBs, suas texturas, a escala das malhas ou modelos NPC.
## Apenas ambiente, sombras do cenario, estrelas e efeitos auxiliares variam.
func set_graphics_quality(profile: String, persist: bool = true) -> void:
    if profile not in ["BAIXO", "MEDIO", "ALTO"]:
        return
    graphics_quality = profile
    if sky != null and sky.environment != null:
        sky.environment.ambient_light_energy = 0.70 if profile == "BAIXO" else (0.84 if profile == "MEDIO" else 1.03)
    if cinematic_light != null:
        cinematic_light.light_energy = 1.15 if profile == "BAIXO" else (1.48 if profile == "MEDIO" else 1.85)
        cinematic_light.shadow_enabled = profile == "ALTO"
    if starfield != null:
        starfield.visible = profile != "BAIXO" and (ui_shell == null or ui_shell.demo_starfield_visible)
    if afterburner != null:
        afterburner.visible = profile != "BAIXO"
    if faction_base != null and is_instance_valid(faction_base):
        faction_base.set_quality(profile)
    if astral_environment != null and Routes.is_astral(current_map):
        astral_environment.reset_arena(current_map,profile)
    if persist:
        _write_local_profile()
        if ui_shell != null:
            ui_shell.show_notification("GRAFICOS %s  |  GLBs SEM REDUCAO" % profile)

func _on_enemy_destroyed(display_name: String, map_id: String, _where: Vector3) -> void:
    var reward: Dictionary = pilot_progress.defeated_enemy(display_name, map_id)
    astral_trials.award_fragments(1)
    var announcement: String = "+%d XP  +%d CREDITOS (TESTE)" % [int(reward["xp"]), int(reward["credits"])]
    if ui_shell != null:
        ui_shell.show_notification(announcement)

func _on_loot_collected(_map_id: String) -> void:
    var reward: Dictionary = pilot_progress.collected_box()
    astral_trials.award_fragments(2)
    var announcement: String = "CAIXA +%d XP / +%d CREDITOS (TESTE)" % [int(reward["xp"]), int(reward["credits"])]
    if ui_shell != null:
        ui_shell.show_notification(announcement)

func _receive_local_damage(amount: float) -> void:
    combat_recovery_clock = 4.0
    var absorbed := minf(shield, amount)
    shield -= absorbed
    hp = maxf(0.0, hp - (amount - absorbed))
    if hp <= 0.0:
        hp = MAX_HP
        shield = MAX_SHIELD
        _return_to_center()
        combat_world._message("Nave recuperada para novos testes (sem custo)")

func aux_enabled() -> bool:
    return support_fleet != null and support_fleet.aux_enabled

# Suporte nao pode ser ligado/desligado em combate: equipar no hangar.
func _toggle_drones() -> void:
    if ui_shell != null:
        ui_shell.show_notification("INSTALE DRONES NO HANGAR > DRONES")

func _toggle_aux() -> void:
    if ui_shell != null:
        ui_shell.show_notification("INSTALE AUX-9 NO HANGAR > AUX-9")


# G0.5: Shell HUD desacoplada para expansao futura sem crescer o script principal.
func _install_new_hud() -> void:
    var to_hide: Array[Control] = [header, telemetry, help_label, portal_hint, ship_select,
        faction_select, warp_button, route_button, target_button, fire_button,
        drones_button, aux_button, combat_label, target_label, status_label,
        hp_bar, shield_bar, target_hp_bar, target_shield_bar]
    for ctrl in to_hide:
        ctrl.visible = false
    ui_shell = StellarHUD.new()
    ui_shell.name = "GameHUD_G05"
    hud.add_child(ui_shell)
    ui_shell.setup(self, mini_map)
    # Painel de rotas já existente permanece acima do HUD novo.
    galaxy_panel.move_to_front()
    _layout_hud()

func select_ammunition(index: int) -> void:
    selected_ammo = clampi(index, 0, 4)
    match selected_ammo:
        0:
            combat_world.player_laser_damage = 425.0
        1:
            combat_world.player_laser_damage = 565.0
        2:
            combat_world.player_laser_damage = 735.0
        3:
            combat_world.player_laser_damage = 905.0
        4:
            pass
    if equipment_state != null:
        combat_world.player_laser_damage += equipment_state.bonus("ARMAS")
    if combat_world.get_selected_enemy() != null:
        auto_fire_enabled = true
    _write_local_profile()
    if ui_shell != null:
        ui_shell.refresh()

func toggle_fps() -> void:
    show_fps = not show_fps
    _write_local_profile()
    if ui_shell != null:
        ui_shell.refresh()

func set_test_faction(index: int) -> void:
    _on_faction_selected(index)
    faction_select.select(index)

func change_ship_for_hangar(ship_id: String) -> void:
    if ship_id in SHIP_IDS and equipment_state.owns_ship(ship_id):
        _set_ship(ship_id)
    elif ui_shell != null:
        ui_shell.show_notification("NAVE NAO ADQUIRIDA. ACESSE A LOJA ESTELAR")

func _on_equipment_changed() -> void:
    # Recalcula os valores DEMONSTRATIVOS mantendo o disparo ativo.
    var base_damage: float = [425.0, 565.0, 735.0, 905.0, 425.0][selected_ammo]
    combat_world.player_laser_damage = base_damage + equipment_state.bonus("ARMAS")
    var old_shield_capacity: float = maxf(1.0, MAX_SHIELD)
    MAX_SHIELD = maxf(8000.0, 8000.0 + equipment_state.bonus("ESCUDOS"))
    shield = clampf(shield * MAX_SHIELD / old_shield_capacity, 0.0, MAX_SHIELD)
    if support_fleet != null:
        support_fleet.apply_equipment(equipment_state)
    if ui_shell != null:
        ui_shell.refresh()
