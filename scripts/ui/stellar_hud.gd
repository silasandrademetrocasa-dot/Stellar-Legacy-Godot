extends Control
## Stellar Legacy G0.7 - HUD com perfil local, progressao e vitrine 3D.
## Interface local de demonstracao: sem compras, saldo real ou consultas a rede.

const C_BG := Color(0.010, 0.021, 0.049, 0.975)
const C_EDGE := Color(0.13, 0.48, 0.78, 0.94)
const C_HI := Color(0.25, 0.82, 0.95)
const C_GOLD := Color(1.0, 0.78, 0.35)
const C_WHITE := Color(0.88, 0.96, 1.0)
const C_MUTED := Color(0.5, 0.66, 0.78)
const EquipCatalog = preload("res://scripts/data/equipment_catalog.gd")
const EquipmentCommand = preload("res://scripts/ui/equipment_command.gd")
const HubCatalog = preload("res://scripts/systems/stellar_hub.gd")
const AstralCatalog = preload("res://scripts/systems/astral_trials.gd")
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
var base_btn: Button
var top_target_btn: Button
var chat_panel: Panel
var chat_title: Label
var chat_preview: RichTextLabel
var chat_input: LineEdit
var chat_send: Button
var chat_expand: Button
var chat_expanded: bool = false
var chat_messages: Array[String] = []
const CHAT_LIMIT: int = 16
const SECTOR_COLORS: Dictionary = {
    "HANGAR": Color(0.18, 0.77, 1.0), "EQUIPAMENTOS": Color(0.22, 0.85, 1.0),
    "LOJA": Color(0.98, 0.72, 0.27), "MERCADO": Color(0.98, 0.72, 0.27),
    "LEILAO": Color(0.83, 0.48, 1.0), "PREMIUM": Color(0.88, 0.48, 1.0),
    "BATALHA": Color(1.0, 0.37, 0.32), "RELES": Color(1.0, 0.42, 0.28),
    "ASTRAL": Color(0.60, 0.48, 1.0), "MAPAS": Color(0.21, 0.80, 0.99),
    "PILOTO": Color(0.40, 0.94, 0.69), "CENTRAL": Color(0.36, 0.73, 1.0),
    "MISSOES": Color(0.31, 0.88, 0.75), "PASSE": Color(0.98, 0.77, 0.28),
    "ALIANCA": Color(0.35, 0.79, 1.0), "CONFIG": Color(0.55, 0.80, 1.0),
    "REFINARIA": Color(0.95, 0.58, 0.29), "TITULOS": Color(0.95, 0.76, 0.39),
    "ADM": Color(1.0, 0.57, 0.43)
}
var warp_btn: Button
var target_btn: Button
var aux_btn: Button
var drone_btn: Button
var weapon_panel: Panel
var weapon_buttons: Array[Button] = []
var fire_btn: Button
var modal_overlay: Control
var modal_box: Panel
var sector_strip: ColorRect
var side_strip: ColorRect
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
var category_row: HFlowContainer
var modal_backdrop: TextureRect
var equip_notice: Label
var equipment_command
var equip_presets: HBoxContainer
var equip_remove: Button
var equip_copy: Button
var equip_slots: HFlowContainer
var showroom_floor: Node3D
var notification_label: Label
var notification_seconds: float = 0.0
var modal_kind := ""
var market_filter: String = "ARMAS"
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
    sty.border_width_left = 2
    sty.border_width_right = 2
    sty.border_width_top = 1
    sty.border_width_bottom = 2
    sty.border_color = edge
    sty.corner_radius_top_left = radius
    sty.corner_radius_top_right = radius
    sty.corner_radius_bottom_left = radius
    sty.corner_radius_bottom_right = radius
    sty.content_margin_left = 5
    sty.content_margin_right = 5
    sty.content_margin_top = 4
    sty.content_margin_bottom = 4
    sty.shadow_color = Color(0.00, 0.35, 0.68, 0.13)
    sty.shadow_size = 3
    sty.anti_aliasing = true
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
    top_panel = _panel(self, Color(0.007, 0.017, 0.044, 0.99))
    top_panel.add_theme_stylebox_override("panel", _style_box(Color(0.008, 0.023, 0.052, 0.99), Color(0.11, 0.63, 1.0), 10))
    top_title = _label(top_panel, "STELLAR LEGACY", 19, C_HI)
    top_title.add_theme_color_override("font_shadow_color", Color(0.1, 0.72, 1.0, 0.65))
    top_title.add_theme_constant_override("shadow_offset_x", 1)
    top_title.add_theme_constant_override("shadow_offset_y", 1)
    top_subtitle = _label(top_panel, "GODOT  |  PROTOTIPO OFFLINE", 10, C_MUTED)
    for item in ["HANGAR", "EQUIPAMENTOS", "BATALHA", "MAPAS", "LOJA", "PILOTO", "CENTRAL", "CONFIG"]:
        var b := _button(top_panel, item, 13)
        b.pressed.connect(_on_top_button.bind(item))
        if item == "EQUIPAMENTOS":
            b.text = "EQUIP."
        top_buttons.append(b)

    vitals_panel = _panel(self)
    vitals_title = _label(vitals_panel, "PILOTO  |  PIONEER", 13, C_WHITE)
    vitals_hp = _bar(vitals_panel, Color(0.23, 0.82, 0.48))
    vitals_shield = _bar(vitals_panel, Color(0.24, 0.64, 0.98))
    target_panel = _panel(self)
    target_title = _label(target_panel, "ALVO  |  NAO SELECIONADO", 12, C_GOLD)
    target_detail = _label(target_panel, "Toque NPC: selecionar  |  2 toques: disparar", 11, C_MUTED)
    top_target_btn = _button(target_panel, "+ ALVO", 11)
    top_target_btn.pressed.connect(func() -> void: game._select_next_target())

    nav_panel = _panel(self)
    minimap_caption = _label(nav_panel, "NAVEGACAO TATICA", 12, C_HI)
    map_widget.reparent(nav_panel)
    map_widget.visible = true

    info_line = _label(self, "Toque no mapa para navegar. O ataque continua durante o deslocamento.", 12, C_WHITE)
    notification_label = _label(self, "", 14, C_GOLD)
    notification_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    notification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    notification_label.visible = false
    action_panel = _panel(self)
    warp_btn = _button(action_panel, "VIAJAR", 13)
    warp_btn.pressed.connect(func() -> void: game._travel_nearest())
    target_btn = _button(action_panel, "ALVO", 13)
    target_btn.pressed.connect(func() -> void: game._select_next_target())
    # DRONES / AUX-9 nao sao controles de HUD; dependem do inventario instalado.
    base_btn = _button(action_panel, "BASE", 12)
    base_btn.pressed.connect(func() -> void: game.open_faction_base())

    weapon_panel = _panel(self)
    for i in range(WEAPON_NAMES.size()):
        var w := _button(weapon_panel, WEAPON_NAMES[i], 12)
        w.pressed.connect(_pick_ammo.bind(i))
        weapon_buttons.append(w)
    fire_btn = _button(weapon_panel, "ATACAR", 15)
    fire_btn.pressed.connect(func() -> void: game._toggle_auto_fire(); refresh())
    _build_local_chat()

func _build_local_chat() -> void:
    chat_panel = _panel(self, Color(0.008, 0.029, 0.069, 0.97))
    chat_title = _label(chat_panel, "COMUNICADOR  /  OFFLINE", 11, C_HI)
    chat_expand = _button(chat_panel, "ABRIR", 10)
    chat_expand.pressed.connect(_toggle_chat)
    chat_preview = RichTextLabel.new()
    chat_preview.bbcode_enabled = false
    chat_preview.scroll_following = true
    chat_preview.fit_content = false
    chat_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
    chat_preview.add_theme_font_size_override("normal_font_size", 11)
    chat_preview.add_theme_color_override("default_color", C_WHITE)
    chat_panel.add_child(chat_preview)
    chat_input = LineEdit.new()
    chat_input.placeholder_text = "Mensagem local..."
    chat_input.max_length = 160
    chat_input.add_theme_font_size_override("font_size", 11)
    chat_input.add_theme_color_override("font_color", C_WHITE)
    chat_input.add_theme_stylebox_override("normal", _style_box(Color(0.018, 0.052, 0.09), C_EDGE, 5))
    chat_input.text_submitted.connect(_send_chat)
    chat_panel.add_child(chat_input)
    chat_send = _button(chat_panel, "ENVIAR", 10)
    chat_send.pressed.connect(func() -> void: _send_chat(chat_input.text))
    _chat_line("SISTEMA", "Canal local ativo. Multiplayer ainda desativado.")

func _chat_line(sender: String, body: String) -> void:
    chat_messages.append("[%s] %s" % [sender, body.strip_edges().substr(0, 160)])
    while chat_messages.size() > CHAT_LIMIT:
        chat_messages.pop_front()
    if chat_preview != null:
        chat_preview.text = "\n".join(PackedStringArray(chat_messages if chat_expanded else chat_messages.slice(maxi(0, chat_messages.size() - 1))))

func _send_chat(message: String) -> void:
    var clean: String = message.strip_edges()
    if clean.is_empty():
        return
    _chat_line("PILOTO", clean)
    chat_input.clear()
    chat_input.release_focus()

func _toggle_chat() -> void:
    chat_expanded = not chat_expanded
    chat_expand.text = "RECOLHER" if chat_expanded else "ABRIR"
    chat_preview.text = "\n".join(PackedStringArray(chat_messages if chat_expanded else chat_messages.slice(maxi(0, chat_messages.size() - 1))))
    relayout(layout_size)

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
    modal_backdrop = TextureRect.new()
    modal_backdrop.texture = load("res://assets/ui/astral_interface_g09.png") as Texture2D
    modal_backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    modal_backdrop.stretch_mode = TextureRect.STRETCH_SCALE
    modal_backdrop.modulate = Color(0.63, 0.74, 0.92, 0.75)
    modal_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
    modal_box.add_child(modal_backdrop)
    sector_strip = ColorRect.new()
    sector_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
    sector_strip.color = C_HI
    modal_box.add_child(sector_strip)
    side_strip = ColorRect.new()
    side_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
    side_strip.color = C_HI
    modal_box.add_child(side_strip)
    modal_title = _label(modal_box, "HANGAR", 22, C_HI)
    modal_info = _label(modal_box, "Visualizacao 3D local, sem rede.", 12, C_MUTED)
    close_btn = _button(modal_box, "FECHAR  X", 13)
    close_btn.pressed.connect(close_modal)
    modal_body = Control.new()
    modal_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
    modal_box.add_child(modal_body)

    category_row = HFlowContainer.new()
    category_row.add_theme_constant_override("separation", 6)
    modal_body.add_child(category_row)
    list_scroll = ScrollContainer.new()
    list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    list_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
    list_scroll.scroll_deadzone = 12
    list_scroll.follow_focus = false
    list_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
    modal_body.add_child(list_scroll)
    item_stack = VBoxContainer.new()
    item_stack.add_theme_constant_override("separation", 3)
    item_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    item_stack.mouse_filter = Control.MOUSE_FILTER_PASS
    list_scroll.add_child(item_stack)

    preview_wrap = SubViewportContainer.new()
    preview_wrap.stretch = true
    preview_wrap.mouse_filter = Control.MOUSE_FILTER_STOP
    preview_wrap.gui_input.connect(_preview_touch)
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
    # Cenografia 3D leve, feita no motor: hangar, plataforma e luzes neon.
    showroom_floor = Node3D.new()
    showroom_floor.name = "ShowroomEstelar"
    preview_vp.add_child(showroom_floor)
    _build_showroom()
    preview_title = _label(modal_body, "", 17, C_WHITE)
    preview_note = _label(modal_body, "Modelos GLB originais armazenados no dispositivo.", 11, C_MUTED)
    choose_btn = _button(modal_body, "EQUIPAR NAVE NO TESTE", 13)
    choose_btn.pressed.connect(_equip_preview)
    equip_remove = _button(modal_body, "REMOVER", 12)
    equip_remove.pressed.connect(_remove_preview)
    equip_copy = _button(modal_body, "COPIAR CONFIG", 11)
    equip_copy.pressed.connect(_copy_equipment_config)
    equip_presets = HBoxContainer.new()
    equip_presets.add_theme_constant_override("separation", 6)
    modal_body.add_child(equip_presets)
    equip_slots = HFlowContainer.new()
    equip_slots.add_theme_constant_override("h_separation", 3)
    equip_slots.add_theme_constant_override("v_separation", 3)
    modal_body.add_child(equip_slots)
    equip_notice = _label(modal_body, "Equipamentos de teste: sem transacoes online.", 11, C_GOLD)
    equipment_command = EquipmentCommand.new()
    equipment_command.name = "EstacaoEquipamentosG011"
    equipment_command.visible = false
    modal_body.add_child(equipment_command)
    equipment_command.setup(game)

func _preview_touch(event: InputEvent) -> void:
    if preview_mesh == null or not is_instance_valid(preview_mesh):
        return
    if event is InputEventScreenDrag:
        var drag := event as InputEventScreenDrag
        preview_mesh.rotation.y += drag.relative.x * 0.012
        preview_mesh.rotation.x = clampf(preview_mesh.rotation.x + drag.relative.y * 0.004, -0.45, 0.55)
        preview_wrap.accept_event()
    elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        var move := event as InputEventMouseMotion
        preview_mesh.rotation.y += move.relative.x * 0.012
        preview_wrap.accept_event()

func _showroom_material(color: Color, metal: float = 0.1) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.metallic = metal
    material.roughness = 0.32
    material.emission_enabled = true
    material.emission = color * 0.52
    return material

func _build_showroom() -> void:
    var floor_mesh := CylinderMesh.new()
    floor_mesh.top_radius = 4.9
    floor_mesh.bottom_radius = 5.25
    floor_mesh.height = 0.34
    floor_mesh.radial_segments = 24
    floor_mesh.material = _showroom_material(Color(0.075, 0.15, 0.26), 0.65)
    var disc := MeshInstance3D.new()
    disc.mesh = floor_mesh
    disc.position.y = -2.08
    showroom_floor.add_child(disc)
    for ring_index in range(3):
        var ring := MeshInstance3D.new()
        var tor := TorusMesh.new()
        tor.inner_radius = 2.4 + float(ring_index) * 0.73
        tor.outer_radius = tor.inner_radius + 0.085
        tor.material = _showroom_material(C_HI if ring_index == 0 else Color(0.06, 0.35, 0.64))
        ring.mesh = tor
        ring.position.y = -1.86 + float(ring_index) * 0.015
        showroom_floor.add_child(ring)
    for i in range(8):
        var angle := TAU * float(i) / 8.0
        var pillar := MeshInstance3D.new()
        var pole := CylinderMesh.new()
        pole.top_radius = 0.045
        pole.bottom_radius = 0.045
        pole.height = 3.8
        pole.radial_segments = 8
        pole.material = _showroom_material(Color(0.025, 0.37, 0.7))
        pillar.mesh = pole
        pillar.position = Vector3(cos(angle) * 5.6, -0.15, sin(angle) * 5.6)
        showroom_floor.add_child(pillar)

func _set_equipment_notice(message: String) -> void:
    equip_notice.text = message
    refresh()

func _redraw_presets() -> void:
    for node in equip_presets.get_children():
        equip_presets.remove_child(node)
        node.queue_free()
    for i in range(2):
        var active: bool = game.equipment_state.active_configuration == i
        var b := _button(equip_presets, ("◆ " if active else "◇ ") + "CONF %d" % (i + 1), 11)
        b.custom_minimum_size = Vector2(102, 30)
        b.pressed.connect(_change_configuration.bind(i))

func _change_configuration(index: int) -> void:
    var result: String = game.equipment_state.select_configuration(index)
    game._on_equipment_changed()
    _set_equipment_notice(result)
    _redraw_presets()
    _populate_category(active_category, false)

func _redraw_slots() -> void:
    for node in equip_slots.get_children():
        equip_slots.remove_child(node)
        node.queue_free()
    if modal_kind != "EQUIPAMENTOS" or not EquipCatalog.SLOTS.has(active_category):
        return
    var slots: Array[String] = game.equipment_state.equipped(active_category)
    for i in range(slots.size()):
        var item_name := slots[i]
        var caption := "%d: %s" % [i + 1, item_name if item_name != "" else "+"]
        var btn := _button(equip_slots, caption, 10)
        btn.custom_minimum_size = Vector2(80, 29)
        btn.tooltip_text = "Toque um slot ocupado para remover"
        btn.pressed.connect(_remove_slot.bind(active_category, i))

func _remove_slot(kind: String, slot_index: int) -> void:
    _set_equipment_notice(game.equipment_state.remove_at(kind, slot_index))
    game._on_equipment_changed()
    _redraw_slots()
    _populate_category(active_category, false)

func _remove_preview() -> void:
    if modal_kind != "EQUIPAMENTOS":
        return
    var item_name := str(selected_item.get("name", ""))
    _set_equipment_notice(game.equipment_state.remove_matching(item_name))
    game._on_equipment_changed()
    _redraw_slots()
    _populate_category(active_category, false)

func _copy_equipment_config() -> void:
    var result: String = game.equipment_state.copy_to_other()
    _set_equipment_notice(result)

func _process(delta: float) -> void:
    if modal_overlay.visible and preview_mesh != null and is_instance_valid(preview_mesh):
        preview_mesh.rotation.y += delta * 0.53
    if notification_seconds > 0.0:
        notification_seconds = maxf(0.0, notification_seconds - delta)
        notification_label.visible = notification_seconds > 0.0

func show_notification(message: String) -> void:
    if notification_label == null:
        return
    notification_label.text = message
    notification_seconds = 2.8
    notification_label.visible = true


func modal_open() -> bool:
    return modal_overlay != null and modal_overlay.visible

func _on_top_button(item: String) -> void:
    if item == "MAPAS":
        close_modal()
        game._toggle_galaxy()
    else:
        _open_modal(item)

func _apply_sector_skin(kind: String) -> void:
    var accent: Color = SECTOR_COLORS.get(kind, C_HI)
    modal_box.add_theme_stylebox_override("panel", _style_box(Color(0.012, 0.032, 0.072, 0.985), accent, 12))
    modal_title.add_theme_color_override("font_color", accent)
    sector_strip.color = accent
    side_strip.color = accent.darkened(0.40)
    modal_info.add_theme_color_override("font_color", accent.lightened(0.30))
    close_btn.add_theme_stylebox_override("normal", _style_box(Color(0.055, 0.084, 0.14), accent, 7))
    # Mesmo vocabulário cromático em todos os setores e subtelas.
    for tab in top_buttons:
        var matches: bool = tab.text == kind or (tab.text == "EQUIP." and kind == "EQUIPAMENTOS")
        tab.add_theme_color_override("font_color", accent if matches else C_WHITE)
        tab.add_theme_stylebox_override("normal", _style_box(Color(0.07, 0.15, 0.22, 0.99) if matches else Color(0.025, 0.065, 0.115, 0.99), accent if matches else C_EDGE, 7))
    if kind in ["EQUIPAMENTOS", "HANGAR"]:
        modal_backdrop.modulate = Color(0.60, 0.79, 1.0, 0.86)
    elif kind in ["BATALHA", "RELES"]:
        modal_backdrop.modulate = Color(1.0, 0.63, 0.55, 0.63)
    elif kind in ["LOJA", "MERCADO", "LEILAO", "PREMIUM"]:
        modal_backdrop.modulate = Color(1.0, 0.82, 0.54, 0.68)
    else:
        modal_backdrop.modulate = Color(0.65, 0.77, 0.96, 0.68)

func _open_modal(kind: String) -> void:
    modal_kind = kind
    modal_overlay.visible = true
    _apply_sector_skin(kind)
    modal_title.text = {"HANGAR":"HANGAR GALACTICO", "EQUIPAMENTOS":"EQUIPAMENTOS ESTELARES", "LOJA":"VITRINE GALACTICA", "BATALHA":"CENTRAL DE BATALHA", "CONFIG":"CONFIGURACOES", "PILOTO":"PERFIL DO PILOTO", "CENTRAL":"CENTRAL ESTELAR", "ALIANCA":"ALIANCA DE FACCAO", "RELES":"RELES DO PVP 4-X", "MISSOES":"MISSOES ESTELARES", "PASSE":"PASSE GALACTICO", "MERCADO":"LOJA NORMAL", "LEILAO":"LEILAO ESTELAR", "PREMIUM":"LOJA PREMIUM", "ADM":"CENTRO DE CONTROLE", "ASTRAL":"PORTAIS ASTRAIS - AURORA / NEXUS / ECLIPSE", "REFINARIA":"REFINARIA ASTRAL", "TITULOS":"TITULOS DO PILOTO"}.get(kind, kind)
    modal_info.text = "G0.12  |  HUD PREMIUM / SUPORTE POR EQUIPAMENTO  |  OFFLINE"
    var equipment_mode: bool = kind == "EQUIPAMENTOS"
    equipment_command.visible = equipment_mode
    if equipment_mode:
        equipment_command.open_command()
    var show_gallery: bool = kind in ["HANGAR", "LOJA"]
    var show_economy_3d: bool = kind in ["ASTRAL", "MERCADO", "LEILAO", "PREMIUM"]
    var show_preview: bool = show_gallery or show_economy_3d
    if not show_preview and preview_mesh != null and is_instance_valid(preview_mesh):
        preview_mesh.queue_free()
        preview_mesh = null
    var hub_pages: Array[String] = ["CENTRAL", "ALIANCA", "RELES", "MISSOES", "PASSE", "MERCADO", "LEILAO", "PREMIUM", "ADM", "ASTRAL", "REFINARIA", "TITULOS"]
    category_row.visible = show_gallery or kind in hub_pages
    list_scroll.visible = not equipment_mode
    preview_wrap.visible = show_preview
    preview_title.visible = show_preview
    preview_note.visible = show_preview
    choose_btn.visible = kind == "HANGAR"
    choose_btn.text = "EQUIPAR NAVE" if kind == "HANGAR" else "EQUIPAR ITEM"
    equip_presets.visible = false
    equip_slots.visible = false
    equip_remove.visible = false
    equip_copy.visible = false
    equip_notice.visible = false

    _clear_dynamic_rows()
    if kind in hub_pages:
        _build_hub_navigation()
    if show_gallery:
        _build_categories()
        if kind == "EQUIPAMENTOS":
            _redraw_presets()
            _select_category("ARMAS")
            _set_equipment_notice("Toque no item para visualizar, EQUIPAR para instalar; toque no slot para remover.")
        else:
            _select_category("NAVES")
    elif kind == "BATALHA":
        _build_battle_menu()
    elif kind == "CONFIG":
        _build_settings_menu()
    elif kind == "PILOTO":
        _build_pilot_menu()
    elif kind in hub_pages:
        _build_hub_page(kind)
    relayout(layout_size)

func _clear_dynamic_rows() -> void:
    for child in category_row.get_children():
        category_row.remove_child(child)
        child.queue_free()
    for child in item_stack.get_children():
        item_stack.remove_child(child)
        child.queue_free()

func _build_categories() -> void:
    var categories: Array = EquipCatalog.CATEGORY_NAMES if modal_kind == "EQUIPAMENTOS" else (["NAVES", "EQUIPAMENTOS", "DRONES", "AUX-9", "REFINARIA", "TITULOS"] if modal_kind == "HANGAR" else ["NAVES", "DRONES", "AUX-9", "ARMAS", "ESCUDOS", "MOTORES", "EXTRAS"])
    for category in categories:
        var btn := _button(category_row, category, 11)
        btn.custom_minimum_size = Vector2(89, 31)
        btn.pressed.connect(_select_category.bind(category))

func _ship_catalog() -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    for ship_id in SHIP_IDS:
        result.append({"name": ship_id.capitalize(), "path": "res://assets/ships/SL_%s_FINAL.glb" % ship_id, "id": ship_id, "source": "GLB ORIGINAL"})
    return result

func _select_category(category: String) -> void:
    if modal_kind == "HANGAR" and category in ["EQUIPAMENTOS", "REFINARIA", "TITULOS"]:
        _open_modal(category)
        return
    active_category = category
    _populate_category(category)
    if modal_kind == "EQUIPAMENTOS":
        _redraw_slots()

func _populate_category(category: String, reset_scroll: bool = true) -> void:
    var previous_scroll: int = list_scroll.scroll_vertical
    selected_item = {}
    # remove_child antes de queue_free evita botoes fantasmas durante troca rapida de abas.
    for child in item_stack.get_children():
        item_stack.remove_child(child)
        child.queue_free()
    catalogue.clear()
    match category:
        "NAVES":
            catalogue = _ship_catalog()
        "DRONES":
            for d in DRONE_ITEMS:
                catalogue.append({"name":str(d[0]), "path":str(d[1]), "id":"", "source":"GLB LOCAL"})
        "AUX-9":
            catalogue.append({"name":"AUX-9", "path":"res://assets/aux/aux9.glb", "id":"", "source":"GLB LOCAL"})
        "ARMAS", "ESCUDOS", "MOTORES", "EXTRAS":
            for item in EquipCatalog.items_in_category(category):
                catalogue.append({"name":str(item["name"]), "path":EquipCatalog.model_path(str(item["name"])),
                    "id":"", "source":"GLB G0.6", "desc":str(item["desc"]), "category":category})
    for i in range(catalogue.size()):
        var row := _button(item_stack, str(catalogue[i]["name"]), 13)
        row.custom_minimum_size = Vector2(165, 54)
        row.mouse_filter = Control.MOUSE_FILTER_PASS
        var thumb: String = EquipCatalog.thumbnail_path(str(catalogue[i]["name"]))
        if not thumb.is_empty():
            row.icon = load(thumb) as Texture2D
            row.expand_icon = true
            row.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
            row.custom_minimum_size = Vector2(165, 65)
        row.pressed.connect(_select_item.bind(i))
    if reset_scroll:
        list_scroll.scroll_vertical = 0
    else:
        list_scroll.set_deferred("scroll_vertical", previous_scroll)
    if catalogue.size() > 0:
        _select_item(0)

func _select_item(index: int) -> void:
    if index < 0 or index >= catalogue.size():
        return
    selected_item = catalogue[index]
    preview_title.text = str(selected_item["name"]).to_upper()
    preview_note.text = str(selected_item["source"]) + "  |  " + str(selected_item.get("desc", "Vitrine 3D em rotacao"))
    if modal_kind == "EQUIPAMENTOS":
        var item_name := str(selected_item["name"])
        var free: int = game.equipment_state.free_amount(item_name)
        preview_note.text += "  |  livres: %d" % free
        choose_btn.disabled = free <= 0
    else:
        var support_type: bool = modal_kind == "HANGAR" and active_category in ["DRONES", "AUX-9"]
        choose_btn.disabled = not support_type and (modal_kind != "HANGAR" or str(selected_item.get("id", "")) == "")
        if support_type:
            var support_name: String = str(selected_item.get("name", ""))
            var owned: int = game.equipment_state.owned_support(support_name)
            var is_fitted: bool = game.equipment_state.equipped_support(support_name)
            choose_btn.text = ("REMOVER " if is_fitted else ("INSTALAR " if owned > 0 else "ADQUIRIR (TESTE) ")) + support_name
            preview_note.text += "  |  Inventario: %d  |  %s" % [owned, "EQUIPADO" if is_fitted else "NAO EQUIPADO"]
        else:
            choose_btn.text = "EQUIPAR NAVE"
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
    var equipment_scale: float = 1.45 if str(selected_item.get("category", "")) != "" else 1.0
    preview_mesh.scale = Vector3.ONE * equipment_scale
    preview_mesh.position = Vector3.ZERO
    preview_mesh.rotation = Vector3(0.12, 0, 0.0)

func _equip_preview() -> void:
    var ship_id := str(selected_item.get("id", ""))
    if modal_kind == "HANGAR" and ship_id != "":
        game.change_ship_for_hangar(ship_id)
        close_modal()
    elif modal_kind == "HANGAR" and active_category in ["DRONES", "AUX-9"]:
        var support_name: String = str(selected_item.get("name", ""))
        var result_note: String = ""
        if game.equipment_state.owned_support(support_name) == 0:
            result_note = game.equipment_state.buy_support(support_name)
        else:
            result_note = game.equipment_state.toggle_support(support_name)
        game._on_equipment_changed()
        show_notification(result_note)
        _select_item(catalogue.find(selected_item))
    elif modal_kind == "EQUIPAMENTOS":
        var result: String = game.equipment_state.equip(str(selected_item.get("name", "")))
        game._on_equipment_changed()
        _set_equipment_notice(result)
        _redraw_slots()
        var chosen := str(selected_item.get("name", ""))
        _populate_category(active_category, false)
        for i in range(catalogue.size()):
            if str(catalogue[i]["name"]) == chosen:
                _select_item(i)
                break

func _add_menu_row(caption: String, action: Callable) -> void:
    var b := _button(item_stack, caption, 15)
    b.custom_minimum_size = Vector2(200, 43)
    b.pressed.connect(action)

func _add_pilot_row(text_value: String, highlighted: bool = false) -> void:
    var label: Label = _label(item_stack, text_value, 13, C_GOLD if highlighted else C_WHITE)
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.custom_minimum_size = Vector2(175.0, 38.0)

func _build_pilot_menu() -> void:
    var stats: Dictionary = game.pilot_progress.snapshot()
    _add_pilot_row("IDENTIDADE STELLAR LEGACY  |  PERFIL LOCAL", true)
    var name_edit := LineEdit.new()
    name_edit.text = game.hub_store.callsign
    name_edit.placeholder_text = "Apelido do piloto (3-24 caracteres)"
    name_edit.max_length = 24
    name_edit.custom_minimum_size = Vector2(190, 39)
    item_stack.add_child(name_edit)
    _add_menu_row("SALVAR APELIDO LOCAL", func() -> void:
        _toast_and_refresh(game.hub_store.set_callsign(name_edit.text), "PILOTO")
    )
    _add_pilot_row("TITULO: %s  |  FACCAO: %s" % [game.hub_store.title, game.faction])
    _add_pilot_row("ALIANCA: %s" % (game.hub_store.alliance if not game.hub_store.alliance.is_empty() else "Nenhuma (simulacao)"))
    _add_pilot_row("PERFIL LOCAL / SIMULACAO (nao representa sua conta)", true)
    _add_pilot_row("NIVEL %d   |   XP %d / %d" % [int(stats["level"]), int(stats["xp_current"]), int(stats["xp_needed"])])
    var progress_bar: ProgressBar = _bar(item_stack, C_HI)
    progress_bar.custom_minimum_size = Vector2(180.0, 15.0)
    progress_bar.value = 100.0 if int(stats["xp_needed"]) <= 0 else 100.0 * float(stats["xp_current"]) / float(stats["xp_needed"])
    _add_pilot_row("CREDITOS DE TESTE  %d    |    XP TOTAL  %d" % [int(stats["credits"]), int(stats["xp_total"])])
    _add_pilot_row("ELIMINACOES  %d   |   CAIXAS  %d   |   MAPAS  %d" % [int(stats["kills"]), int(stats["boxes"]), int(stats["maps"])])
    _add_pilot_row("MISSOES DA FUNDACAO", true)
    var missions: Array = stats["missions"]
    for mission in missions:
        var status: String = "CONCLUIDA"
        if not bool(mission["claimed"]):
            status = "%d / %d" % [mini(int(mission["done"]), int(mission["goal"])), int(mission["goal"])]
        _add_pilot_row("%s     %s" % [str(mission["name"]), status])
    _add_pilot_row("ATIVIDADES RECENTES", true)
    var events: Array = stats["recent"]
    if events.is_empty():
        _add_pilot_row("Derrote um NPC, recolha caixas e explore mapas.")
    else:
        for entry in events:
            _add_pilot_row(str(entry))

func _build_battle_menu() -> void:
    _add_menu_row("SELECIONAR PROXIMO ALVO", func() -> void:
        game._select_next_target()
        close_modal()
    )
    _add_menu_row("ATIVAR / PAUSAR DISPARO", func() -> void:
        game._toggle_auto_fire()
        close_modal()
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
    _add_menu_row("PORTAIS ASTRAIS / ONDAS PVE", func() -> void:
        _open_modal("ASTRAL")
    )
    _add_menu_row("PVP 4-X / CONQUISTA DE RELES", func() -> void:
        _open_modal("RELES")
    )
    _add_menu_row("PLS-1 A PLS-4 / CMT-1: NO RODAPE", func() -> void:
        close_modal()
    )

func _toast_and_refresh(note: String, kind: String) -> void:
    show_notification(note)
    _open_modal(kind)

func _hub_text(text_value: String, emphasized: bool = false) -> void:
    var row: Label = _label(item_stack, text_value, 14, C_HI if emphasized else C_WHITE)
    row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    row.custom_minimum_size = Vector2(230, 34 if not emphasized else 39)
    row.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _build_hub_navigation() -> void:
    for category in ["CENTRAL", "ASTRAL", "ALIANCA", "RELES", "MISSOES", "PASSE", "MERCADO", "LEILAO", "PREMIUM", "ADM", "REFINARIA", "TITULOS"]:
        var b: Button = _button(category_row, category, 11)
        b.custom_minimum_size = Vector2(85, 31)
        b.add_theme_color_override("font_color", C_GOLD if category == modal_kind else C_HI)
        b.pressed.connect(_open_modal.bind(category))

func _claim_contract_menu(key: String) -> void:
    _toast_and_refresh(game.hub_store.claim_contract(key, game.pilot_progress), "MISSOES")

func _claim_pass_menu(stage: int) -> void:
    _toast_and_refresh(game.hub_store.claim_pass(stage, game.pilot_progress), "PASSE")

func _buy_market_menu(name: String) -> void:
    _toast_and_refresh(game.hub_store.buy_demo(name, game.pilot_progress.credits), "MERCADO")

func _bid_auction_menu(lot: int) -> void:
    _toast_and_refresh(game.hub_store.simulate_bid(lot), "LEILAO")

func _preview_hub_model(item_name: String, path: String, description: String) -> void:
    selected_item = {"name": item_name, "path": path, "source": "GLB FULL / LOCAL"}
    preview_title.text = item_name.to_upper()
    preview_note.text = description
    _load_preview(path)

## Card premium nativo, totalmente interativo; o painel 3D preserva o GLB carregado.
func _rich_card(title: String, subtitle: String, path: String, accent: Color, action_caption: String, action: Callable) -> void:
    var card := PanelContainer.new()
    card.custom_minimum_size = Vector2(220, 125)
    card.add_theme_stylebox_override("panel",_style_box(Color(0.015,0.034,0.069,0.99),accent,8))
    card.mouse_filter = Control.MOUSE_FILTER_PASS
    item_stack.add_child(card)
    var body := HBoxContainer.new()
    body.add_theme_constant_override("separation",8)
    card.add_child(body)
    var card_name: String = title
    var icon_path: String = EquipCatalog.thumbnail_path(card_name)
    if not icon_path.is_empty():
        var art := TextureRect.new()
        art.texture = load(icon_path) as Texture2D
        art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        art.custom_minimum_size = Vector2(88,88)
        art.mouse_filter = Control.MOUSE_FILTER_IGNORE
        body.add_child(art)
    var info := VBoxContainer.new()
    info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    info.add_theme_constant_override("separation",4)
    body.add_child(info)
    var name_label := _label(info,title,14,C_WHITE)
    name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    var sub_label := _label(info,subtitle,10,accent)
    sub_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    var inspect := _button(info,"INSPECIONAR GLB 3D",11)
    inspect.custom_minimum_size = Vector2(116,27)
    inspect.pressed.connect(_preview_hub_model.bind(title,path,subtitle))
    if not action_caption.is_empty():
        var command := _button(info,action_caption,11)
        command.custom_minimum_size = Vector2(116,29)
        command.pressed.connect(action)

func _purchase_equipment(name: String, cost: int) -> void:
    var note: String = game.hub_store.buy_equipment(name,cost,game.pilot_progress.credits,game.equipment_state)
    show_notification(note)
    _open_modal("MERCADO")

func _materialize_astral(kind: String) -> void:
    var result: String = game.astral_trials.materialize_key(kind)
    show_notification(result)
    _open_modal("ASTRAL")

func _show_astral_catalog() -> void:
    _preview_hub_model("PORTAL AURORA", "res://assets/astral/portal_astral_aurora.glb", "GLB integral. Entradas fisicas em 1-1, 2-1 e 3-1.")
    for name in AstralCatalog.ARENAS:
        var info: Dictionary = AstralCatalog.ARENAS[name]
        var gate_path: String = "res://assets/astral/portal_astral_%s.glb" % str(info["label"]).to_lower()
        var summary: String = "%s  |  %s" % [str(info["description"]), game.astral_trials.status(name)]
        var col: Color = Color(0.32,0.90,0.93) if name == "A-AURORA" else (Color(0.71,0.48,0.99) if name == "A-NEXUS" else Color(1.0,0.46,0.36))
        _rich_card("PORTAL " + str(info["label"]),summary,gate_path,col,"CONSULTAR ROTAS",func() -> void:
            close_modal()
            game._toggle_galaxy()
        )
    _hub_text("MATERIALIZADOR ASTRAL  |  %d FRAGMENTOS LOCAIS" % game.astral_trials.fragments, true)
    for arena_id in AstralCatalog.ARENAS:
        var label: String = str(AstralCatalog.ARENAS[arena_id]["label"])
        var state: String = game.astral_trials.entry_status(arena_id)
        _rich_card("CHAVE " + label, state,
            "res://assets/astral/portal_astral_%s.glb" % label.to_lower(),
            C_GOLD, "MATERIALIZAR", _materialize_astral.bind(arena_id))
    _hub_text("VOE ATE X-1 DA SUA FACCAO, FABRIQUE UMA CHAVE E ENTRE PELO PORTAL FISICO.")
    _hub_text("3 ONDAS PvE; NPC +1 FRAGMENTO / CAIXA +2. Somente no dispositivo.")
    if game.current_map.begins_with("A-"):
        _hub_text("AGORA: %s  |  ONDA %d/3  |  %s" % [game.current_map,game.astral_trials.wave,"FINALIZADO" if game.astral_trials.finished else "EM COMBATE"],true)

func _show_market_catalog() -> void:
    _preview_hub_model("ARSENAL ESTELAR","res://assets/equipment/arc-q.glb","Referencias visuais Stellar Legacy: pecas em GLB e miniaturas conceituais. Compras offline.")
    _hub_text("LOJA ESTELAR | SALDO LOCAL: %d CR | SEM PAGAMENTOS REAIS" % game.hub_store.credit_balance(game.pilot_progress.credits),true)
    for cat in ["ARMAS","ESCUDOS","MOTORES","EXTRAS"]:
        _add_menu_row(("[ATIVO]  " if cat == market_filter else "[VER]  ") + cat,_market_filter_selected.bind(cat))
    var shown: int = 0
    for listing in HubCatalog.SHOP_EQUIPMENT:
        var name: String = str(listing["name"])
        var model: String = EquipCatalog.model_path(name)
        var definition: Dictionary = EquipCatalog.get_item(name)
        if str(definition.get("category", "")) != market_filter:
            continue
        shown += 1
        var cost: int = int(listing["cost"])
        _rich_card(name,"%d CR | %s" % [cost,str(listing["description"])],model,C_HI,"COMPRAR / TESTE",_purchase_equipment.bind(name,cost))
    _hub_text("EXIBINDO %d ITENS DE %s | todos os modelos sao carregados localmente" % [shown,market_filter])

func _show_auction_catalog() -> void:
    _preview_hub_model("LEILAO ORBITAL","res://assets/equipment/thr-3.glb","Lotes Elite e equipamentos 3D. Sem leiloes ou outros participantes online.")
    for i in range(HubCatalog.AUCTION.size()):
        var listing: Dictionary = HubCatalog.AUCTION[i]
        var current: int = int(game.hub_store.auction_bids.get(str(i),int(listing["opening"])))
        _rich_card(str(listing["name"]),"LOTE %02d | LANCE LOCAL %d CR" % [i+1,current],str(listing.get("model","res://assets/equipment/arc-4.glb")),C_GOLD,"SIMULAR +50 CR",_bid_auction_menu.bind(i))
    _hub_text("O leilao nao tem temporizador online, compra, concorrentes ou saldo real.")

func _set_title_menu(next_title: String) -> void:
    _toast_and_refresh(game.hub_store.change_title(next_title,game.pilot_progress,game.astral_trials),"TITULOS")

func _refine_astral_menu() -> void:
    _toast_and_refresh(game.hub_store.refine_astral(game.astral_trials,game.pilot_progress.credits),"REFINARIA")

func _market_filter_selected(category: String) -> void:
    market_filter = category
    _open_modal("MERCADO")

func _build_hub_page(kind: String) -> void:
    var hub = game.hub_store
    var pilot = game.pilot_progress
    match kind:
        "CENTRAL":
            _hub_text("STELLAR LEGACY | CENTRAL DE OPERACOES", true)
            _hub_text("Faccoes, PvP 4-X, relés, economia e temporada — laboratorios offline.")
            _hub_text("PILOTO: %s | FACCAO %s | LV %d" % [hub.callsign, game.faction, int(pilot.level_info()["level"])])
            _hub_text("CREDITOS DE SIMULACAO: %d" % hub.credit_balance(pilot.credits))
            _hub_text("NAVE: %s | ALIANCA: %s" % [game.current_ship, hub.alliance if not hub.alliance.is_empty() else "Sem alianca"])
            _add_menu_row("PORTAIS ASTRAIS: AURORA, NEXUS E ECLIPSE", func() -> void: _open_modal("ASTRAL"))
            _add_menu_row("RELES — EVENTO DE CONQUISTA 4-X", func() -> void: _open_modal("RELES"))
            _add_menu_row("ALIANCAS E FACCOES", func() -> void: _open_modal("ALIANCA"))
            _add_menu_row("MISSOES E PASSE", func() -> void: _open_modal("MISSOES"))
            _add_menu_row("LOJA NORMAL / LEILAO / PREMIUM", func() -> void: _open_modal("MERCADO"))
        "ALIANCA":
            _hub_text("FACCAO ATUAL: %s" % game.faction, true)
            _hub_text("Aliancas serao vinculadas a contas e faccoes no novo servidor.")
            _hub_text("ALIANCAS OFFLINE: %s" % (hub.alliance if not hub.alliance.is_empty() else "Nenhuma"))
            if hub.alliance.is_empty():
                var name_input := LineEdit.new()
                name_input.text = "Esquadrao Estelar"
                name_input.max_length = 28
                name_input.custom_minimum_size = Vector2(200, 40)
                item_stack.add_child(name_input)
                _add_menu_row("CRIAR ALIANCA LOCAL", func() -> void:
                    _toast_and_refresh(hub.create_alliance(name_input.text, game.faction), "ALIANCA")
                )
            else:
                _hub_text("TAG: [%s]  |  MEMBROS: 1 PILOTO LOCAL" % hub.alliance_tag)
                _add_menu_row("SAIR DA ALIANCA DE TESTE", func() -> void:
                    _toast_and_refresh(hub.leave_alliance(), "ALIANCA")
                )
            _hub_text("Convites, administracao e guerra de aliancas exigem autenticação.")
        "RELES":
            _hub_text("EVENTO: DOMINIO DE RELES ESTELARES", true)
            _hub_text("PvP 4-X: posicione a nave no centro do mapa por 12s.")
            _hub_text("SIMULACAO LOCAL. Nao ha jogadores ou disputa online.")
            for map_id in HubCatalog.RELAY_MAPS:
                var progress_text: String = ""
                if game.current_map == map_id:
                    progress_text = " | CAPTURA %d%%" % roundi(hub.capture_ratio(map_id) * 100.0)
                _hub_text("%s — %s%s" % [map_id, hub.relay_text(map_id), progress_text])
            _hub_text("LOCALIZACAO: %s | DOMINIOS TOTAIS: %d" % [game.current_map, hub.relay_captures])
            _hub_text("Viaje pelos PORTAIS. Nao existe teleporte por menu.")
            _add_menu_row("VOLTAR AO MAPA / PILOTAR", func() -> void: close_modal())
        "MISSOES":
            _hub_text("CONTRATOS DE PATRULHA / RECOMPENSAS LOCAIS", true)
            _hub_text("Missões iniciais da G0.7 continuam preservadas.")
            for contract in HubCatalog.CONTRACTS:
                var key: String = str(contract["key"])
                var amount: int = hub.progress_contract(key, pilot)
                var required: int = int(contract["goal"])
                _hub_text("%s | %d/%d | +%d CRED" % [str(contract["label"]), mini(amount, required), required, int(contract["credits"])])
                if bool(hub.contract_claims.get(key, false)):
                    _hub_text("RECOMPENSA RECEBIDA", true)
                else:
                    _add_menu_row("RESGATAR: %s" % str(contract["label"]), _claim_contract_menu.bind(key))
            _add_menu_row("ABRIR PASSE GALACTICO", func() -> void: _open_modal("PASSE"))
        "PASSE":
            _hub_text("PASSE GALACTICO — TRILHA GRATUITA (LOCAL)", true)
            _hub_text("Progresso por combates, caixas e exploracao.")
            _hub_text("PONTOS: %d  |  COMPRAS PREMIUM DESATIVADAS" % hub.pass_score(pilot))
            for stage in range(HubCatalog.PASS_GOALS.size()):
                _hub_text("ETAPA %d | %d/%d PONTOS | %d CRED" % [stage+1, mini(hub.pass_score(pilot),HubCatalog.PASS_GOALS[stage]),HubCatalog.PASS_GOALS[stage],HubCatalog.PASS_REWARDS[stage]])
                if bool(hub.pass_claims.get(str(stage),false)):
                    _hub_text("ETAPA RESGATADA", true)
                else:
                    _add_menu_row("RESGATAR ETAPA %d" % (stage + 1), _claim_pass_menu.bind(stage))
        "ASTRAL":
            _show_astral_catalog()
        "MERCADO":
            _show_market_catalog()
        "LEILAO":
            _show_auction_catalog()
        "PREMIUM":
            _hub_text("VITRINE PREMIUM  |  SEM CHECKOUT / SEM VALORES REAIS",true)
            _preview_hub_model("AURORA ELITE","res://assets/ships/SL_AURORA_FINAL.glb","Nave GLB integral. Sem compra premium, somente demonstracao.")
            _rich_card("COLECAO AURORA","COSMETICOS ESTELARES EM ESTUDO", "res://assets/ships/SL_AURORA_FINAL.glb",C_GOLD,"",func() -> void: pass)
            _rich_card("DRONES ELITE","VISUAL COMPLETO / SEM VENDA", "res://assets/drones/drone_elite.glb",C_HI,"",func() -> void: pass)
            _hub_text("Sem pagamento, moedas vendidas ou direitos de conta neste prototipo.")
        "REFINARIA":
            _hub_text("REFINARIA DE FRAGMENTOS ASTRAIS | PRODUCAO OFFLINE",true)
            _hub_text("ESTOQUE ATUAL: %d FRAGMENTOS | SALDO LOCAL: %d CR" % [game.astral_trials.fragments,hub.credit_balance(pilot.credits)])
            _add_menu_row("CONVERTER 350 CR EM 4 FRAGMENTOS ASTRAIS",_refine_astral_menu)
            _add_menu_row("ABRIR MATERIALIZADOR DOS PORTAIS",func() -> void: _open_modal("ASTRAL"))
            _hub_text("Os fragmentos nao existem no servidor e nao podem ser vendidos.")
        "TITULOS":
            _hub_text("TITULO ATUAL: " + hub.title,true)
            _hub_text("EXPLORADOR: LIVRE | SENTINELA: 5 KOs | CACADOR ESTELAR: 20 KOs")
            _hub_text("CONQUISTADOR: 1 RELE | NAVEGANTE ASTRAL: 1 PORTAL CONCLUIDO")
            for item in ["Explorador","Sentinela","Cacador Estelar","Conquistador","Navegante Astral"]:
                _add_menu_row("SELECIONAR TITULO: "+item,_set_title_menu.bind(item))
        "ADM":
            _hub_text("PLANO DE ADMINISTRACAO (SOMENTE LEITURA)", true)
            _hub_text("ADM REAL NAO ESTA HABILITADO NO CLIENTE OFFLINE.")
            _hub_text("CONTROLE FUTURO: moderacao, contas, relés e auditoria.")
            _hub_text("Servidor autenticara papeis. Interface nao concede acesso ADM.")
            _hub_text("BANCO: NOVO SUPABASE ISOLADO (AINDA NAO CRIADO).")
            _hub_text("NENHUMA ALTERACAO NO RENDER OU SUPABASE ATUAIS.")

func _build_settings_menu() -> void:
    _hub_text("QUALIDADE GRAFICA  |  %s" % game.graphics_quality, true)
    _hub_text("Naves, NPCs, drones e AUX-9 permanecem com seus GLBs FULL em todos os perfis.")
    for preset in ["BAIXO","MEDIO","ALTO"]:
        var note: String = {"BAIXO":"Cenario leve / sombras OFF / estrelas OFF", "MEDIO":"Cenario equilibrado / sombras OFF", "ALTO":"Iluminacao intensa / sombras ON / estrelas ON"}[preset]
        _add_menu_row("%s  -  %s" % [preset,note], _apply_quality_setting.bind(preset))
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

func _apply_quality_setting(preset: String) -> void:
    game.set_graphics_quality(preset)
    _open_modal("CONFIG")

func _pick_ammo(index: int) -> void:
    game.select_ammunition(index)
    refresh()

func close_modal() -> void:
    modal_overlay.visible = false
    for tab in top_buttons:
        tab.add_theme_color_override("font_color", C_WHITE)
        tab.add_theme_stylebox_override("normal", _style_box(Color(0.042, 0.085, 0.145, 0.98), Color(0.16, 0.39, 0.53), 7))
    if preview_mesh != null and is_instance_valid(preview_mesh):
        preview_mesh.queue_free()
        preview_mesh = null

func refresh() -> void:
    if game == null or not is_instance_valid(game) or game.ship_anchor == null:
        return
    var lvl: Dictionary = game.pilot_progress.level_info()
    top_subtitle.text = "LV %d  |  %s  |  %s  |  %s  %s" % [int(lvl["level"]), game.current_map, str(game.current_ship), game.graphics_quality, ("%d FPS" % Engine.get_frames_per_second()) if game.show_fps else ""]
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
    if game.current_map.begins_with("A-"):
        minimap_caption.text = "PORTAL %s | ONDA %d/3" % [game.current_map.trim_prefix("A-"), game.astral_trials.wave]
    elif game.current_map.begins_with("4-"):
        if game.hub_store.capture_ratio(game.current_map) > 0.0:
            minimap_caption.text = "CAPTURA %s | %d%%" % [game.current_map, roundi(game.hub_store.capture_ratio(game.current_map) * 100.0)]
        else:
            minimap_caption.text = "RELE %s | %s" % [game.current_map, game.hub_store.relay_text(game.current_map)]
    else:
        minimap_caption.text = "MAPA  %s  |  TOQUE PARA IR" % game.current_map
    var pidx: int = game._nearest_index()
    warp_btn.disabled = pidx < 0 or game.warp_cooldown > 0.0
    base_btn.visible = game.current_map.ends_with("-1") and not game.current_map.begins_with("A-") and not game.current_map.begins_with("4-") and not game.current_map.begins_with("U-")
    base_btn.disabled = not game.near_faction_base()
    base_btn.text = "BASE" if not base_btn.disabled else "BASE..."
    fire_btn.text = "PARAR TIRO" if game.auto_fire_enabled else "ATACAR"
    for i in range(weapon_buttons.size()):
        var b := weapon_buttons[i]
        b.text = WEAPON_NAMES[i] + ("  ●" if i == game.selected_ammo else "")
        b.add_theme_color_override("font_color", C_GOLD if i == game.selected_ammo else C_WHITE)
    if game.auto_fire_enabled and game.destination_active:
        info_line.text = "ARRASTE E ATAQUE  |  alvo travado  |  alcance %dm" % roundi(game.combat_world.LASER_RANGE)
    elif game.destination_active:
        info_line.text = "SEGURE E ARRASTE PARA GUIAR  |  toque em NPC para travar mira"
    else:
        info_line.text = "TOQUE OU ARRASTE PARA VOAR  |  2 toques no NPC: atacar"

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
    var menu_start := 239.0 if not compact else 156.0
    var btn_w := (w - menu_start - 12.0) / float(top_buttons.size()) - 4.0
    for i in range(top_buttons.size()):
        top_buttons[i].position = Vector2(menu_start + i * (btn_w + 4.0), 6)
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
    top_target_btn.position = Vector2(target_panel.size.x - 94.0, 30)
    top_target_btn.size = Vector2(85, 26)
    target_detail.size.x = target_panel.size.x - 105.0
    var bottom_y: float = h - 72.0
    var bar_h: float = 63.0
    var chat_w: float = clampf(w * 0.33, 210.0, 345.0)
    chat_panel.position = Vector2(9, h - (172.0 if chat_expanded else 72.0))
    chat_panel.size = Vector2(chat_w, 163.0 if chat_expanded else 63.0)
    chat_title.position = Vector2(9, 4)
    chat_title.size = Vector2(chat_w - 86, 17)
    chat_expand.position = Vector2(chat_w - 78, 3)
    chat_expand.size = Vector2(70, 23)
    chat_preview.position = Vector2(9, 26 if chat_expanded else 21)
    chat_preview.size = Vector2(chat_w - 18, 88 if chat_expanded else 16)
    chat_input.position = Vector2(8, 119 if chat_expanded else 39)
    chat_input.size = Vector2(chat_w - 89, 29 if chat_expanded else 20)
    chat_send.position = Vector2(chat_w - 76, 119 if chat_expanded else 36)
    chat_send.size = Vector2(68, 29 if chat_expanded else 23)
    var actions_w: float = clampf(w * 0.16, 120.0, 155.0)
    action_panel.position = Vector2(15 + chat_w, bottom_y)
    action_panel.size = Vector2(actions_w, bar_h)
    warp_btn.position = Vector2(4, 5)
    warp_btn.size = Vector2((actions_w - 14) * 0.5, 53)
    base_btn.position = Vector2(10 + (actions_w - 14) * 0.5, 5)
    base_btn.size = Vector2((actions_w - 14) * 0.5, 53)
    target_btn.visible = false
    weapon_panel.position = Vector2(action_panel.position.x + actions_w + 6, bottom_y)
    weapon_panel.size = Vector2(maxf(220.0, w - weapon_panel.position.x - 9), bar_h)
    var weapon_button_w: float = (weapon_panel.size.x - 14.0) / 6.0
    for i in range(5):
        weapon_buttons[i].position = Vector2(5 + i * weapon_button_w, 6)
        weapon_buttons[i].size = Vector2(weapon_button_w - 3, 51)
        weapon_buttons[i].add_theme_font_size_override("font_size", 10 if compact else 12)
    fire_btn.position = Vector2(5 + 5 * weapon_button_w, 6)
    fire_btn.size = Vector2(weapon_button_w - 3, 51)
    fire_btn.add_theme_font_size_override("font_size", 11 if compact else 13)
    notification_label.position = Vector2(w * 0.29, 56)
    notification_label.size = Vector2(w * 0.43, 26)
    info_line.position = Vector2(12, h - (189.0 if chat_expanded else 96.0))
    info_line.size = Vector2(w - 25, 18)
    info_line.add_theme_font_size_override("font_size", 11 if compact else 12)

    modal_overlay.position = Vector2.ZERO
    modal_overlay.size = view_size
    var modal_w := minf(w - 26.0, 890.0)
    var modal_h := minf(h - 35.0, 480.0)
    modal_box.position = (view_size - Vector2(modal_w, modal_h)) * 0.5
    modal_box.size = Vector2(modal_w, modal_h)
    modal_backdrop.position = Vector2(3, 3)
    modal_backdrop.size = Vector2(modal_w - 6, modal_h - 6)
    sector_strip.position = Vector2(14, 3)
    sector_strip.size = Vector2(modal_w - 28, 3)
    side_strip.position = Vector2(3, 6)
    side_strip.size = Vector2(3, modal_h - 12)
    modal_title.position = Vector2(16, 8)
    modal_title.size = Vector2(modal_w - 160, 28)
    modal_info.position = Vector2(16, 37)
    modal_info.size = Vector2(modal_w - 26, 22)
    close_btn.position = Vector2(modal_w - 122, 10)
    close_btn.size = Vector2(108, 37)
    modal_body.position = Vector2(12, 64)
    modal_body.size = Vector2(modal_w - 24, modal_h - 75)
    equipment_command.position = Vector2.ZERO
    equipment_command.relayout(modal_body.size)
    var body_w := modal_body.size.x
    var body_h := modal_body.size.y
    var hub_modal: bool = modal_kind in ["CENTRAL", "ASTRAL", "ALIANCA", "RELES", "MISSOES", "PASSE", "MERCADO", "LEILAO", "PREMIUM", "ADM", "REFINARIA", "TITULOS"]
    var cat_h: float = ((78.0 if modal_w < 845.0 else 42.0) if hub_modal else (70.0 if modal_kind == "LOJA" else 37.0)) if category_row.visible else 0.0
    category_row.position = Vector2(5, 0)
    category_row.size = Vector2(body_w - 10, cat_h)
    var left_w := maxf(160.0, body_w * 0.35)
    var equip_offset: float = 89.0 if modal_kind == "EQUIPAMENTOS" else 0.0
    equip_presets.position = Vector2(4, cat_h + 2)
    equip_presets.size = Vector2(left_w - 6, 30)
    equip_slots.position = Vector2(3, cat_h + 35)
    equip_slots.size = Vector2(left_w - 4, 51)
    list_scroll.position = Vector2(0, cat_h + equip_offset + 4)
    list_scroll.size = Vector2(left_w, maxf(45.0, body_h - cat_h - equip_offset - 8))
    if preview_wrap.visible:
        preview_wrap.position = Vector2(left_w + 8, cat_h + 4)
        preview_wrap.size = Vector2(body_w - left_w - 8, maxf(100, body_h - cat_h - 85))
        preview_title.position = Vector2(left_w + 18, body_h - 64)
        preview_title.size = Vector2(body_w - left_w - 22, 27)
        preview_note.position = Vector2(left_w + 18, body_h - 36)
        preview_note.size = Vector2(body_w - left_w - 20, 20)
        choose_btn.position = Vector2(left_w + 10, body_h - 109)
        choose_btn.size = Vector2(minf(165, body_w - left_w - 24), 33)
        equip_remove.position = Vector2(left_w + 183, body_h - 109)
        equip_remove.size = Vector2(112, 33)
        equip_copy.position = Vector2(left_w + 304, body_h - 109)
        equip_copy.size = Vector2(maxf(65, body_w - left_w - 312), 33)
        equip_notice.position = Vector2(7, body_h - 27)
        equip_notice.size = Vector2(body_w - 15, 24)
    else:
        list_scroll.position = Vector2(12, cat_h + 8)
        list_scroll.size = Vector2(body_w - 24, maxf(48.0, body_h - cat_h - 20))
