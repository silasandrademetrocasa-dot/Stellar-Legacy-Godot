extends Control
## Stellar Legacy G0.5 - HUD Android horizontal + hangar/loja 3D em SubViewport.
## Interface local de demonstracao: sem compras, saldo real ou consultas a rede.

const C_BG := Color(0.018, 0.036, 0.074, 0.95)
const C_EDGE := Color(0.15, 0.43, 0.65, 0.8)
const C_HI := Color(0.25, 0.82, 0.95)
const C_GOLD := Color(1.0, 0.78, 0.35)
const C_WHITE := Color(0.88, 0.96, 1.0)
const C_MUTED := Color(0.5, 0.66, 0.78)
const SHIP_IDS := ["AURORA", "BASTION", "BULWARK", "KENSEI", "LEVIATHAN", "LYNX", "MERIDIAN", "PATHFINDER", "PHANTOM", "PIONEER", "RAPTOR", "SERAPH", "VALKYRIE"]
const WEAPON_NAMES := ["PLS-1", "PLS-2", "PLS-3", "PLS-4", "CMT-1"]
const DRONE_ITEMS := [
    ["Drone Alfa", "res://assets/drones/drone_a.glb"],
    ["Drone Beta", "res://assets/drones/drone_b.glb"],
    ["Drone Gama", "res://assets/drones/drone_c.glb"],
    ["Drone Delta", "res://assets/drones/drone_d.glb"],
    ["Drone Epsilon", "res://assets/drones/drone_e.glb"],
    ["Drone Comum", "res://assets/drones/drone_common.glb"],
    ["Drone Elite", "res://assets/drones/drone_elite.glb"],
]

var game
var map_widget: Control
var top_panel: Panel
var top_title: Label
var top_subtitle: Label
var top_buttons: Array[Button] = []
var vitals_panel: Panel
var vitals_title: Label
var vitals_hp: ProgressBar
var vitals_shield: ProgressBar
var target_panel: Panel
var target_title: Label
var target_detail: Label
var nav_panel: Panel
var minimap_caption: Label
var info_line: Label
var action_panel: Panel
var warp_btn: Button
var target_btn: Button
var aux_btn: Button
var drone_btn: Button
var weapon_panel: Panel
var weapon_buttons: Array[Button] = []
var fire_btn: Button
var modal_overlay: Control
var modal_box: Panel
var modal_title: Label
var modal_info: Label
var modal_body: Control
var close_btn: Button
var list_scroll: ScrollContainer
var item_stack: VBoxContainer
var preview_wrap: SubViewportContainer
var preview_vp: SubViewport
var preview_root: Node3D
var preview_mesh: Node3D
var preview_cam: Camera3D
var preview_note: Label
var preview_title: Label
var choose_btn: Button
var category_row: HBoxContainer
var modal_kind := ""
var selected_item: Dictionary = {}
var catalogue: Array[Dictionary] = []
var active_category := ""
var demo_starfield_visible := true
var layout_size := Vector2(960, 540)

func setup(root, minimap: Control) -> void:
    game = root
    map_widget = minimap
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _create_shell()
    _create_modal()
    relayout(get_viewport_rect().size)
    refresh()

func _style_box(bg: Color, edge: Color = C_EDGE, radius: int = 9) -> StyleBoxFlat:
    var sty := StyleBoxFlat.new()
    sty.bg_color = bg
    sty.border_width_left = 1
    sty.border_width_right = 1
    sty.border_width_top = 1
    sty.border_width_bottom = 1
    sty.border_color = edge
    sty.corner_radius_top_left = radius
    sty.corner_radius_top_right = radius
    sty.corner_radius_bottom_left = radius
    sty.corner_radius_bottom_right = radius
    sty.content_margin_left = 5
    sty.content_margin_right = 5
    sty.content_margin_top = 4
    sty.content_margin_bottom = 4
    return sty

func _panel(parent: Control, bg: Color = C_BG) -> Panel:
    var p := Panel.new()
    p.mouse_filter = Control.MOUSE_FILTER_STOP
    p.add_theme_stylebox_override("panel", _style_box(bg))
    parent.add_child(p)
    return p

func _label(parent: Node, text_value: String, font_size: int = 14, color: Color = C_WHITE) -> Label:
    var l := Label.new()
    l.text = text_value
    l.add_theme_font_size_override("font_size", font_size)
    l.add_theme_color_override("font_color", color)
    l.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(l)
    return l

func _button(parent: Node, caption: String, font_size: int = 14) -> Button:
    var b := Button.new()
    b.text = caption
    b.add_theme_color_override("font_color", C_WHITE)
    b.add_theme_color_override("font_hover_color", Color.WHITE)
    b.add_theme_font_size_override("font_size", font_size)
    b.add_theme_stylebox_override("normal", _style_box(Color(0.042, 0.085, 0.145, 0.98), Color(0.16, 0.39, 0.53)))
    b.add_theme_stylebox_override("hover", _style_box(Color(0.073, 0.19, 0.28, 0.98), C_HI))
    b.add_theme_stylebox_override("pressed", _style_box(Color(0.1, 0.33, 0.44, 0.98), C_HI))
    b.add_theme_stylebox_override("disabled", _style_box(Color(0.035, 0.058, 0.085, 0.85), Color(0.12, 0.2, 0.28)))
    parent.add_child(b)
    return b

func _bar(parent: Control, fill: Color) -> ProgressBar:
    var b := ProgressBar.new()
    b.max_value = 100
    b.value = 100
    b.show_percentage = false
    b.mouse_filter = Control.MOUSE_FILTER_IGNORE
    b.add_theme_stylebox_override("background", _style_box(Color(0.025, 0.047, 0.08, 0.99), Color(0.1, 0.19, 0.27), 4))
    b.add_theme_stylebox_override("fill", _style_box(fill, fill, 4))
    parent.add_child(b)
    return b

func _create_shell() -> void:
    top_panel = _panel(self)
    top_title = _label(top_panel, "STELLAR LEGACY", 19, C_HI)
    top_subtitle = _label(top_panel, "GODOT  |  PROTOTIPO OFFLINE", 10, C_MUTED)
    for item in ["HANGAR", "BATALHA", "MAPAS", "LOJA", "CONFIG"]:
        var b := _button(top_panel, item, 13)
        b.pressed.connect(_on_top_button.bind(item))
        top_buttons.append(b)

    vitals_panel = _panel(self)
    vitals_title = _label(vitals_panel, "PILOTO  |  PIONEER", 13, C_WHITE)
    vitals_hp = _bar(vitals_panel, Color(0.23, 0.82, 0.48))
    vitals_shield = _bar(vitals_panel, Color(0.24, 0.64, 0.98))
    target_panel = _panel(self)
    target_title = _label(target_panel, "ALVO  |  NAO SELECIONADO", 12, C_GOLD)
    target_detail = _label(target_panel, "Toque NPC: selecionar  |  2 toques: disparar", 11, C_MUTED)

    nav_panel = _panel(self)
    minimap_caption = _label(nav_panel, "NAVEGACAO TATICA", 12, C_HI)
    map_widget.reparent(nav_panel)
    map_widget.visible = true

    info_line = _label(self, "Toque no mapa para navegar. O ataque continua durante o deslocamento.", 12, C_WHITE)
    action_panel = _panel(self)
    warp_btn = _button(action_panel, "VIAJAR", 13)
    warp_btn.pressed.connect(func() -> void: game._travel_nearest())
    target_btn = _button(action_panel, "ALVO", 13)
    target_btn.pressed.connect(func() -> void: game._select_next_target())
    drone_btn = _button(action_panel, "DRONES", 12)
    drone_btn.pressed.connect(func() -> void:
        game._toggle_drones()
        refresh())
    aux_btn = _button(action_panel, "AUX-9", 12)
    aux_btn.pressed.connect(func() -> void:
        game._toggle_aux()
        refresh())

    weapon_panel = _panel(self)
    for i in range(WEAPON_NAMES.size()):
        var w := _button(weapon_panel, WEAPON_NAMES[i], 12)
        w.pressed.connect(_pick_ammo.bind(i))
        weapon_buttons.append(w)
    fire_btn = _button(weapon_panel, "ATACAR", 15)
    fire_btn.pressed.connect(func() -> void: game._toggle_auto_fire(); refresh())

func _create_modal() -> void:
    modal_overlay = Control.new()
    modal_overlay.visible = false
    modal_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(modal_overlay)
    var shadow := ColorRect.new()
    shadow.color = Color(0.004, 0.008, 0.025, 0.82)
    shadow.mouse_filter = Control.MOUSE_FILTER_STOP
    shadow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    modal_overlay.add_child(shadow)
    modal_box = _panel(modal_overlay, Color(0.022, 0.047, 0.087, 0.99))
    modal_title = _label(modal_box, "HANGAR", 22, C_HI)
    modal_info = _label(modal_box, "Visualizacao 3D local, sem rede.", 12, C_MUTED)
    close_btn = _button(modal_box, "FECHAR  X", 13)
    close_btn.pressed.connect(close_modal)
    modal_body = Control.new()
    modal_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
    modal_box.add_child(modal_body)

    category_row = HBoxContainer.new()
    category_row.add_theme_constant_override("separation", 6)
    modal_body.add_child(category_row)
    list_scroll = ScrollContainer.new()
    list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    list_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
    modal_body.add_child(list_scroll)
    item_stack = VBoxContainer.new()
    item_stack.add_theme_constant_override("separation", 3)
    item_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    list_scroll.add_child(item_stack)

    preview_wrap = SubViewportContainer.new()
    preview_wrap.stretch = true
    preview_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
    modal_body.add_child(preview_wrap)
    preview_vp = SubViewport.new()
    preview_vp.size = Vector2i(480, 320)
    preview_vp.own_world_3d = true
    preview_vp.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
    preview_wrap.add_child(preview_vp)
    var env := WorldEnvironment.new()
    var background := Environment.new()
    background.background_mode = Environment.BG_COLOR
    background.background_color = Color(0.011, 0.027, 0.064)
    background.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    background.ambient_light_color = Color(0.45, 0.69, 1.0)
    background.ambient_light_energy = 0.85
    env.environment = background
    preview_vp.add_child(env)
    preview_root = Node3D.new()
    preview_root.name = "Vitrine3D"
    preview_vp.add_child(preview_root)
    preview_cam = Camera3D.new()
    preview_cam.fov = 50
    preview_cam.position = Vector3(0, 5, 14)
    preview_cam.current = true
    preview_vp.add_child(preview_cam)
    preview_cam.look_at(Vector3.ZERO, Vector3.UP)
    var key := DirectionalLight3D.new()
    key.rotation_degrees = Vector3(-43, -36, -16)
    key.light_energy = 2.0
    preview_vp.add_child(key)
    var rim := DirectionalLight3D.new()
    rim.rotation_degrees = Vector3(-27, 150, 20)
    rim.light_energy = 1.2
    rim.light_color = Color(0.18, 0.75, 1.0)
    preview_vp.add_child(rim)
    var ring := MeshInstance3D.new()
    var torus := TorusMesh.new()
    torus.inner_radius = 3.0
    torus.outer_radius = 3.12
    var mat := StandardMaterial3D.new()
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.albedo_color = Color(0.16, 0.64, 0.89)
    mat.emission_enabled = true
    mat.emission = Color(0.14, 0.52, 0.84)
    torus.material = mat
    ring.mesh = torus
    ring.position = Vector3(0, -1.8, 0)
    preview_vp.add_child(ring)
    preview_title = _label(modal_body, "", 17, C_WHITE)
    preview_note = _label(modal_body, "Modelos GLB originais armazenados no dispositivo.", 11, C_MUTED)
    choose_btn = _button(modal_body, "EQUIPAR NAVE NO TESTE", 13)
    choose_btn.pressed.connect(_equip_preview)

func _process(delta: float) -> void:
    if modal_overlay.visible and preview_mesh != null and is_instance_valid(preview_mesh):
        preview_mesh.rotation.y += delta * 0.53

func modal_open() -> bool:
    return modal_overlay != null and modal_overlay.visible

func _on_top_button(item: String) -> void:
    if item == "MAPAS":
        close_modal()
        game._toggle_galaxy()
    else:
        _open_modal(item)

func _open_modal(kind: String) -> void:
    modal_kind = kind
    modal_overlay.visible = true
    modal_title.text = {"HANGAR":"HANGAR GALACTICO", "LOJA":"VITRINE GALACTICA", "BATALHA":"CENTRAL DE BATALHA", "CONFIG":"CONFIGURACOES"}.get(kind, kind)
    modal_info.text = "G0.5 | ambiente de testes local | progresso e compras nao sao gravados no servidor"
    var show_gallery := kind in ["HANGAR", "LOJA"]
    category_row.visible = show_gallery
    list_scroll.visible = true
    preview_wrap.visible = show_gallery
    preview_title.visible = show_gallery
    preview_note.visible = show_gallery
    choose_btn.visible = kind == "HANGAR"
    _clear_dynamic_rows()
    if show_gallery:
        _build_categories()
        _select_category("NAVES")
    elif kind == "BATALHA":
        _build_battle_menu()
    elif kind == "CONFIG":
        _build_settings_menu()
    relayout(layout_size)

func _clear_dynamic_rows() -> void:
    for child in category_row.get_children():
        child.queue_free()
    for child in item_stack.get_children():
        child.queue_free()

func _build_categories() -> void:
    for category in ["NAVES", "DRONES", "AUX-9", "EQUIPAMENTOS"]:
        var btn := _button(category_row, category, 12)
        btn.custom_minimum_size = Vector2(96, 33)
        btn.pressed.connect(_select_category.bind(category))

func _ship_catalog() -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    for ship_id in SHIP_IDS:
        result.append({"name": ship_id.capitalize(), "path": "res://assets/ships/SL_%s_FINAL.glb" % ship_id, "id": ship_id, "source": "GLB ORIGINAL"})
    return result

func _select_category(category: String) -> void:
    active_category = category
    selected_item = {}
    for child in item_stack.get_children():
        child.queue_free()
    catalogue.clear()
    match category:
        "NAVES":
            catalogue = _ship_catalog()
        "DRONES":
            for d in DRONE_ITEMS:
                catalogue.append({"name": str(d[0]), "path": str(d[1]), "id": "", "source": "GLB ORIGINAL"})
        "AUX-9":
            catalogue.append({"name":"AUX-9", "path":"res://assets/aux/aux9.glb", "id":"", "source":"GLB ORIGINAL"})
        "EQUIPAMENTOS":
            for n in ["PLS-1", "PLS-2", "PLS-3", "PLS-4", "SIP-2", "CMT-1", "Módulo de Escudo", "Motor Estelar"]:
                catalogue.append({"name": n, "path":"", "id":"", "source":"CONCEITO 3D PROVISORIO"})
    for i in range(catalogue.size()):
        var row := _button(item_stack, str(catalogue[i]["name"]), 14)
        row.custom_minimum_size = Vector2(160, 35)
        row.pressed.connect(_select_item.bind(i))
    if catalogue.size() > 0:
        _select_item(0)

func _select_item(index: int) -> void:
    if index < 0 or index >= catalogue.size():
        return
    selected_item = catalogue[index]
    preview_title.text = str(selected_item["name"]).to_upper()
    preview_note.text = str(selected_item["source"]) + "  |  ROTACAO 360  |  ARQUIVO LOCAL"
    choose_btn.disabled = modal_kind != "HANGAR" or str(selected_item.get("id", "")) == ""
    _load_preview(str(selected_item.get("path", "")))

func _load_preview(path: String) -> void:
    if preview_mesh != null and is_instance_valid(preview_mesh):
        preview_mesh.queue_free()
        preview_mesh = null
    if path != "":
        var res := load(path) as PackedScene
        if res != null:
            preview_mesh = res.instantiate() as Node3D
    if preview_mesh == null:
        preview_mesh = Node3D.new()
        var symbol := MeshInstance3D.new()
        var concept := CylinderMesh.new()
        concept.top_radius = 0.7
        concept.bottom_radius = 1.0
        concept.height = 2.2
        var material := StandardMaterial3D.new()
        material.metallic = 0.8
        material.roughness = 0.24
        material.albedo_color = C_HI
        concept.material = material
        symbol.mesh = concept
        symbol.rotation.z = PI / 2.0
        preview_mesh.add_child(symbol)
    preview_root.add_child(preview_mesh)
    # Cada vitrine tem um SubViewport unico, criado apenas quando o menu e aberto.
    preview_mesh.scale = Vector3.ONE
    preview_mesh.position = Vector3.ZERO
    preview_mesh.rotation = Vector3(0.12, 0, 0.0)

func _equip_preview() -> void:
    var ship_id := str(selected_item.get("id", ""))
    if modal_kind == "HANGAR" and ship_id != "":
        game.change_ship_for_hangar(ship_id)
        close_modal()

func _add_menu_row(caption: String, action: Callable) -> void:
    var b := _button(item_stack, caption, 15)
    b.custom_minimum_size = Vector2(200, 43)
    b.pressed.connect(action)

func _build_battle_menu() -> void:
    _add_menu_row("SELECIONAR PROXIMO ALVO", func() -> void:
        game._select_next_target()
        close_modal()
    )
    _add_menu_row("ATIVAR / PAUSAR DISPARO", func() -> void:
        game._toggle_auto_fire()
        close_modal()
    )
    _add_menu_row("LIGAR / DESLIGAR DRONES", func() -> void:
        game._toggle_drones()
        refresh()
    )
    _add_menu_row("LIGAR / DESLIGAR AUX-9", func() -> void:
        game._toggle_aux()
        refresh()
    )
    _add_menu_row("IR ATE ALVO (SEGUIR)", func() -> void:
        game.chase_target = true
        game.destination_active = false
        close_modal()
    )
    _add_menu_row("CANCELAR MOVIMENTO", func() -> void:
        game._clear_autonavigation()
        close_modal()
    )
    _add_menu_row("PLS-1 A PLS-4 / CMT-1: NO RODAPE", func() -> void:
        close_modal()
    )

func _build_settings_menu() -> void:
    _add_menu_row("ALTERNAR INDICADOR FPS", func() -> void:
        game.toggle_fps()
        refresh()
    )
    _add_menu_row("LIGAR / DESLIGAR ESTRELAS", func() -> void:
        demo_starfield_visible = not demo_starfield_visible
        game.starfield.visible = demo_starfield_visible
    )
    _add_menu_row("FACCAO: TERRA (TESTE)", func() -> void:
        game.set_test_faction(0)
        close_modal()
    )
    _add_menu_row("FACCAO: MARTE (TESTE)", func() -> void:
        game.set_test_faction(1)
        close_modal()
    )
    _add_menu_row("FACCAO: JUPITER (TESTE)", func() -> void:
        game.set_test_faction(2)
        close_modal()
    )
    _add_menu_row("AJUSTES NAO ALTERAM CONTA REAL", func() -> void:
        close_modal()
    )

func _pick_ammo(index: int) -> void:
    game.select_ammunition(index)
    refresh()

func close_modal() -> void:
    modal_overlay.visible = false
    if preview_mesh != null and is_instance_valid(preview_mesh):
        preview_mesh.queue_free()
        preview_mesh = null

func refresh() -> void:
    if game == null or not is_instance_valid(game) or game.ship_anchor == null:
        return
    top_subtitle.text = "MAPA %s   /   %s    %s" % [game.current_map, str(game.current_ship), ("%d FPS" % Engine.get_frames_per_second()) if game.show_fps else ""]
    vitals_title.text = "PILOTO  |  HP %d  /  ESC %d" % [roundi(game.hp), roundi(game.shield)]
    vitals_hp.value = 100.0 * game.hp / game.MAX_HP
    vitals_shield.value = 100.0 * game.shield / game.MAX_SHIELD
    var unit = game.combat_world.get_selected_enemy()
    if unit != null:
        target_title.text = "ALVO: %s" % str(unit.display_name)
        var distance := roundi(game.ship_anchor.global_position.distance_to(unit.global_position))
        target_detail.text = "%dm  |  HP %d  ESC %d   %s" % [distance, roundi(unit.hp), roundi(unit.shield), "ATACANDO" if game.auto_fire_enabled else "TRAVADO"]
    else:
        target_title.text = "ALVO: NENHUM"
        target_detail.text = "Toque NPC / 2 toques para atacar"
    minimap_caption.text = "MAPA  %s  |  TOQUE PARA IR" % game.current_map
    var pidx: int = game._nearest_index()
    warp_btn.disabled = pidx < 0 or game.warp_cooldown > 0.0
    drone_btn.text = "DRONES ON" if game.support_fleet.drones_enabled else "DRONES OFF"
    aux_btn.text = "AUX-9 ON" if game.support_fleet.aux_enabled else "AUX-9 OFF"
    fire_btn.text = "PARAR TIRO" if game.auto_fire_enabled else "ATACAR"
    for i in range(weapon_buttons.size()):
        var b := weapon_buttons[i]
        b.text = WEAPON_NAMES[i] + ("  ●" if i == game.selected_ammo else "")
        b.add_theme_color_override("font_color", C_GOLD if i == game.selected_ammo else C_WHITE)
    if game.auto_fire_enabled and game.destination_active:
        info_line.text = "MOVIMENTO + ATAQUE  |  travamento mantido no alvo  |  alcance %dm" % roundi(game.combat_world.LASER_RANGE)
    elif game.destination_active:
        info_line.text = "ROTA ATIVA  |  toque no NPC para selecionar sem perder controles"
    else:
        info_line.text = "Toque no mapa para ir  |  dois toques no NPC para atacar  |  disparo nao cancela movimento"

func relayout(view_size: Vector2) -> void:
    layout_size = view_size
    size = view_size
    var w := view_size.x
    var h := view_size.y
    var compact := w < 780.0
    top_panel.position = Vector2.ZERO
    top_panel.size = Vector2(w, 50)
    top_title.position = Vector2(11, 3)
    top_title.size = Vector2(145, 27)
    top_subtitle.position = Vector2(12, 29)
    top_subtitle.size = Vector2(250, 16)
    var menu_start := 260.0 if not compact else 168.0
    var btn_w := (w - menu_start - 12.0) / 5.0 - 5.0
    for i in range(top_buttons.size()):
        top_buttons[i].position = Vector2(menu_start + i * (btn_w + 5.0), 6)
        top_buttons[i].size = Vector2(btn_w, 37)
        top_buttons[i].add_theme_font_size_override("font_size", 11 if compact else 13)
    var map_w := clampf(w * 0.22, 145.0, 216.0)
    var map_h := 153.0
    nav_panel.position = Vector2(w - map_w - 9, 57)
    nav_panel.size = Vector2(map_w, map_h)
    minimap_caption.position = Vector2(9, 4)
    minimap_caption.size = Vector2(map_w - 18, 19)
    map_widget.position = Vector2(6, 26)
    map_widget.size = Vector2(map_w - 12, map_h - 32)
    vitals_panel.position = Vector2(9, 58)
    vitals_panel.size = Vector2(clampf(w * 0.34, 186, 315), 80)
    vitals_title.position = Vector2(9, 5)
    vitals_title.size = Vector2(vitals_panel.size.x - 15, 23)
    vitals_hp.position = Vector2(9, 35)
    vitals_hp.size = Vector2(vitals_panel.size.x - 18, 11)
    vitals_shield.position = Vector2(9, 54)
    vitals_shield.size = Vector2(vitals_panel.size.x - 18, 11)
    target_panel.position = Vector2(9, 145)
    target_panel.size = Vector2(vitals_panel.size.x, 62)
    target_title.position = Vector2(9, 4)
    target_title.size = Vector2(target_panel.size.x - 18, 24)
    target_detail.position = Vector2(9, 30)
    target_detail.size = Vector2(target_panel.size.x - 18, 25)
    var action_h := 47.0
    var bottom_y := h - 60.0
    action_panel.position = Vector2(10, bottom_y)
    action_panel.size = Vector2(minf(350.0, w * 0.40), action_h + 4.0)
    var action_button_w := (action_panel.size.x - 16) / 4.0
    for i in range(4):
        var ab: Button = [warp_btn, target_btn, drone_btn, aux_btn][i]
        ab.position = Vector2(5 + i * action_button_w, 4)
        ab.size = Vector2(action_button_w - 3, action_h - 4)
        ab.add_theme_font_size_override("font_size", 11 if compact else 12)
    weapon_panel.position = Vector2(action_panel.position.x + action_panel.size.x + 7.0, bottom_y)
    weapon_panel.size = Vector2(w - weapon_panel.position.x - 10.0, action_h + 4.0)
    var weapon_button_w := (weapon_panel.size.x - 14.0) / 6.0
    for i in range(5):
        weapon_buttons[i].position = Vector2(5 + i * weapon_button_w, 4)
        weapon_buttons[i].size = Vector2(weapon_button_w - 3.0, action_h - 4)
        weapon_buttons[i].add_theme_font_size_override("font_size", 10 if compact else 12)
    fire_btn.position = Vector2(5 + 5 * weapon_button_w, 4)
    fire_btn.size = Vector2(weapon_button_w - 3, action_h - 4)
    fire_btn.add_theme_font_size_override("font_size", 11 if compact else 13)
    info_line.position = Vector2(12, h - 84)
    info_line.size = Vector2(w - 25, 22)
    info_line.add_theme_font_size_override("font_size", 11 if compact else 12)

    modal_overlay.position = Vector2.ZERO
    modal_overlay.size = view_size
    var modal_w := minf(w - 26.0, 890.0)
    var modal_h := minf(h - 35.0, 480.0)
    modal_box.position = (view_size - Vector2(modal_w, modal_h)) * 0.5
    modal_box.size = Vector2(modal_w, modal_h)
    modal_title.position = Vector2(16, 8)
    modal_title.size = Vector2(modal_w - 160, 28)
    modal_info.position = Vector2(16, 37)
    modal_info.size = Vector2(modal_w - 26, 22)
    close_btn.position = Vector2(modal_w - 122, 10)
    close_btn.size = Vector2(108, 37)
    modal_body.position = Vector2(12, 64)
    modal_body.size = Vector2(modal_w - 24, modal_h - 75)
    var body_w := modal_body.size.x
    var body_h := modal_body.size.y
    var cat_h := 40.0 if category_row.visible else 0.0
    category_row.position = Vector2(5, 0)
    category_row.size = Vector2(body_w - 10, cat_h)
    var left_w := maxf(160.0, body_w * 0.35)
    list_scroll.position = Vector2(0, cat_h + 4)
    list_scroll.size = Vector2(left_w, body_h - cat_h - 8)
    if preview_wrap.visible:
        preview_wrap.position = Vector2(left_w + 8, cat_h + 4)
        preview_wrap.size = Vector2(body_w - left_w - 8, maxf(100, body_h - cat_h - 78))
        preview_title.position = Vector2(left_w + 18, body_h - 64)
        preview_title.size = Vector2(body_w - left_w - 22, 27)
        preview_note.position = Vector2(left_w + 18, body_h - 36)
        preview_note.size = Vector2(body_w - left_w - 20, 20)
        choose_btn.position = Vector2(left_w + 10, body_h - 105)
        choose_btn.size = Vector2(minf(220, body_w - left_w - 24), 31)
    else:
        list_scroll.position = Vector2(12, 8)
        list_scroll.size = Vector2(body_w - 24, body_h - 20)
