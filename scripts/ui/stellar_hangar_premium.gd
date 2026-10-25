extends Control
## G0.16: hangar premium dinamico. Dados reais do save Godot, sem itens ficticios.
## A vitrine principal instancia o GLB integral. Miniaturas sao renders locais dos GLBs.
const Ships = preload("res://scripts/data/ship_balance.gd")
const Catalog = preload("res://scripts/data/equipment_catalog.gd")
const Store = preload("res://scripts/data/store_catalog.gd")
const SKY := Color(0.12, 0.72, 1.0)
const WHITE := Color(0.92, 0.97, 1.0)
const DIM := Color(0.48, 0.67, 0.80)
const GOLD := Color(1.0, 0.73, 0.30)
const NAVY := Color(0.006, 0.019, 0.049, 0.97)
const ORDER: Array[String] = ["AURORA", "PIONEER", "RAPTOR", "MERIDIAN", "BASTION", "LYNX", "PHANTOM", "PATHFINDER", "KENSEI", "VALKYRIE", "LEVIATHAN", "SERAPH", "BULWARK"]

var game
var upper: HBoxContainer
var left_cards: Array[PanelContainer] = []
var right_cards: Array[PanelContainer] = []
var center_panel: Panel
var hero_title: Label
var hero_specs: Label
var hero_hint: Label
var hero_view: SubViewportContainer
var hero_pivot: Node3D
var hero_model: Node3D
var hero_camera: Camera3D
var change_button: Button
var fleet_scroll: ScrollContainer
var fleet_row: HBoxContainer
var stat_strip: HBoxContainer
var stat_value_labels: Dictionary = {}
var selected_ship: String = "AURORA"
var card_widgets: Dictionary = {}
var button_tabs: HBoxContainer
var starport: TextureRect
var top_detail: Label

func setup(owner_game) -> void:
    game = owner_game
    mouse_filter = Control.MOUSE_FILTER_STOP
    var bg: TextureRect = TextureRect.new()
    bg.name = "Starfield"
    bg.texture = load("res://assets/ui/g013_starport.png") as Texture2D
    bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    bg.stretch_mode = TextureRect.STRETCH_SCALE
    bg.modulate = Color(0.62, 0.85, 1.0, 0.90)
    bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(bg)
    starport = bg

    button_tabs = HBoxContainer.new()
    button_tabs.add_theme_constant_override("separation", 5)
    add_child(button_tabs)
    for tab in ["NAVES", "EQUIPAMENTOS", "REFINARIA", "TITULOS", "LOJA"]:
        var b: Button = _button(tab, SKY if tab == "NAVES" else DIM)
        b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        b.pressed.connect(_open_tab.bind(tab))
        button_tabs.add_child(b)

    top_detail = _label(self, "HANGAR ESTELAR   •   VITRINE GLB INTEGRAL   •   EQUIPAMENTOS INSTALADOS", 10, DIM)
    for cat in ["ARMAS", "ESCUDOS", "MOTORES"]:
        left_cards.append(_equipment_panel(cat))
    for cat in ["EXTRAS", "DRONES", "AUX-9"]:
        right_cards.append(_equipment_panel(cat))

    center_panel = Panel.new()
    center_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.010, 0.032, 0.070, 0.85), SKY))
    add_child(center_panel)
    hero_title = _label(center_panel, "AURORA", 23, WHITE)
    hero_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hero_specs = _label(center_panel, "", 11, SKY)
    hero_specs.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hero_hint = _label(center_panel, "MODELO 3D ORIGINAL • ARRASTE PARA GIRAR", 10, DIM)
    hero_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hero_view = _hero_viewport(center_panel)
    hero_pivot = hero_view.get_child(0).get_node("Pivot") as Node3D
    hero_camera = hero_view.get_child(0).get_node("Camera") as Camera3D
    change_button = _button("ATIVAR NAVE", SKY)
    center_panel.add_child(change_button)
    change_button.pressed.connect(_equip_ship)

    stat_strip = HBoxContainer.new()
    stat_strip.add_theme_constant_override("separation", 5)
    add_child(stat_strip)
    for key in ["HP", "ESCUDO", "VELOCIDADE", "PORAO", "LASERS", "GERADORES", "EXTRAS"]:
        var p: PanelContainer = PanelContainer.new()
        p.add_theme_stylebox_override("panel", _panel_style(Color(0.016, 0.050, 0.100, 0.97), SKY.darkened(0.35)))
        p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        stat_strip.add_child(p)
        var v: VBoxContainer = VBoxContainer.new()
        v.add_theme_constant_override("separation", 1)
        p.add_child(v)
        var name_label: Label = _label(v, key, 9, DIM)
        name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        var value_label: Label = _label(v, "—", 15, WHITE)
        value_label.name = "Value"
        value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        p.set_meta("stat", key)
        stat_value_labels[key] = value_label

    fleet_scroll = ScrollContainer.new()
    fleet_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
    fleet_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    fleet_scroll.scroll_deadzone = 8
    fleet_scroll.follow_focus = false
    fleet_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(fleet_scroll)
    fleet_row = HBoxContainer.new()
    fleet_row.add_theme_constant_override("separation", 6)
    fleet_scroll.add_child(fleet_row)
    open_command()

func _open_tab(tab: String) -> void:
    if tab == "NAVES":
        open_command()
    elif game != null and game.ui_shell != null:
        game.ui_shell._open_modal(tab)

func _panel_style(fill: Color, edge: Color) -> StyleBoxFlat:
    var s: StyleBoxFlat = StyleBoxFlat.new()
    s.bg_color = fill
    s.border_color = edge
    s.set_border_width_all(2)
    s.set_corner_radius_all(7)
    s.content_margin_left = 5
    s.content_margin_right = 5
    s.content_margin_top = 4
    s.content_margin_bottom = 4
    s.shadow_color = Color(edge.r, edge.g, edge.b, 0.22)
    s.shadow_size = 3
    return s

func _label(parent: Node, caption: String, font_size: int, tint: Color) -> Label:
    var l: Label = Label.new()
    l.text = caption
    l.add_theme_color_override("font_color", tint)
    l.add_theme_font_size_override("font_size", font_size)
    l.mouse_filter = Control.MOUSE_FILTER_IGNORE
    l.clip_text = true
    parent.add_child(l)
    return l

func _button(caption: String, color: Color) -> Button:
    var b: Button = Button.new()
    b.text = caption
    b.focus_mode = Control.FOCUS_NONE
    b.add_theme_font_size_override("font_size", 11)
    b.add_theme_color_override("font_color", WHITE)
    b.add_theme_stylebox_override("normal", _panel_style(Color(0.020, 0.072, 0.125, 0.97), color.darkened(0.15)))
    b.add_theme_stylebox_override("hover", _panel_style(Color(0.038, 0.145, 0.22, 0.99), color))
    b.add_theme_stylebox_override("pressed", _panel_style(Color(0.06, 0.20, 0.28, 0.99), color))
    b.add_theme_stylebox_override("disabled", _panel_style(Color(0.022, 0.031, 0.053), Color(0.15, 0.24, 0.31)))
    return b

func _equipment_panel(category: String) -> PanelContainer:
    var p: PanelContainer = PanelContainer.new()
    p.add_theme_stylebox_override("panel", _panel_style(Color(0.010, 0.035, 0.076, 0.98), SKY))
    add_child(p)
    var contents: VBoxContainer = VBoxContainer.new()
    contents.add_theme_constant_override("separation", 2)
    p.add_child(contents)
    var headline: Label = _label(contents, category.replace("AUX-9", "AUX-9 / MODULOS"), 11, SKY)
    headline.name = "Headline"
    var row: HBoxContainer = HBoxContainer.new()
    row.add_theme_constant_override("separation", 6)
    contents.add_child(row)
    var thumb: TextureRect = TextureRect.new()
    thumb.name = "Thumb"
    thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    thumb.custom_minimum_size = Vector2(65, 35)
    thumb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
    row.add_child(thumb)
    var detail: VBoxContainer = VBoxContainer.new()
    detail.add_theme_constant_override("separation", 2)
    detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.add_child(detail)
    var item: Label = _label(detail, "NAO INSTALADO", 11, WHITE)
    item.name = "Item"
    var rarity: Label = _label(detail, "SEM EQUIPAMENTO", 9, DIM)
    rarity.name = "Rarity"
    var mark: Label = _label(contents, "ADQUIRA NA LOJA ESTELAR", 9, DIM)
    mark.name = "Mark"
    card_widgets[category] = {"panel":p, "item":item, "rarity":rarity, "thumb":thumb, "mark":mark}
    return p

func _hero_viewport(parent: Node) -> SubViewportContainer:
    var wrap: SubViewportContainer = SubViewportContainer.new()
    wrap.stretch = true
    wrap.mouse_filter = Control.MOUSE_FILTER_STOP
    wrap.gui_input.connect(_on_drag_hero)
    parent.add_child(wrap)
    var vp: SubViewport = SubViewport.new()
    vp.size = Vector2i(720, 410)
    vp.transparent_bg = true
    vp.own_world_3d = true
    vp.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
    wrap.add_child(vp)
    var env_node: WorldEnvironment = WorldEnvironment.new()
    var env: Environment = Environment.new()
    env.background_mode = Environment.BG_CLEAR_COLOR
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.45, 0.64, 1.0)
    env.ambient_light_energy = 1.25
    env_node.environment = env
    vp.add_child(env_node)
    var pivot: Node3D = Node3D.new()
    pivot.name = "Pivot"
    vp.add_child(pivot)
    var camera: Camera3D = Camera3D.new()
    camera.name = "Camera"
    camera.position = Vector3(6.0, 5.5, 10.5)
    camera.fov = 45.0
    camera.current = true
    vp.add_child(camera)
    camera.look_at(Vector3(0.0, 0.25, 0.0), Vector3.UP)
    var lamp_colors: Array[Color] = [Color(0.64, 0.82, 1.0), Color(0.2, 0.65, 1.0), Color(1.0, 0.63, 0.33)]
    for i in range(3):
        var key: DirectionalLight3D = DirectionalLight3D.new()
        key.rotation_degrees = Vector3(-50.0, -50.0 + float(i) * 115.0, -5.0)
        key.light_energy = 2.0 if i == 0 else 1.10
        key.light_color = lamp_colors[i]
        vp.add_child(key)
    var base: MeshInstance3D = MeshInstance3D.new()
    var disc: CylinderMesh = CylinderMesh.new()
    disc.top_radius = 4.2
    disc.bottom_radius = 4.6
    disc.height = 0.14
    disc.radial_segments = 64
    var mat: StandardMaterial3D = StandardMaterial3D.new()
    mat.albedo_color = Color(0.028, 0.070, 0.13)
    mat.metallic = 0.70
    mat.roughness = 0.32
    disc.material = mat
    base.mesh = disc
    base.position.y = -0.95
    vp.add_child(base)
    for i in range(3):
        var band: MeshInstance3D = MeshInstance3D.new()
        var torus: TorusMesh = TorusMesh.new()
        torus.inner_radius = 2.55 + float(i) * 0.42
        torus.outer_radius = torus.inner_radius + 0.050
        var neon: StandardMaterial3D = StandardMaterial3D.new()
        neon.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        neon.albedo_color = SKY if i != 2 else GOLD
        neon.emission_enabled = true
        neon.emission = neon.albedo_color
        torus.material = neon
        band.mesh = torus
        band.position.y = -0.82
        vp.add_child(band)
    return wrap

func _on_drag_hero(event: InputEvent) -> void:
    if hero_model == null or not is_instance_valid(hero_model):
        return
    if event is InputEventScreenDrag:
        hero_model.rotation.y += (event as InputEventScreenDrag).relative.x * 0.010
        hero_view.accept_event()
    elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        hero_model.rotation.y += (event as InputEventMouseMotion).relative.x * 0.010
        hero_view.accept_event()

func _process(delta: float) -> void:
    if visible and hero_model != null and is_instance_valid(hero_model):
        hero_model.rotation.y += delta * 0.105

func _best(category: String) -> String:
    var best: String = ""
    var highest: float = -1.0
    for name in game.equipment_state.equipped(category):
        if name == "":
            continue
        var bonus: float = float(Catalog.get_item(name).get("bonus", 0))
        if bonus > highest:
            highest = bonus
            best = str(name)
    return best

func _best_support(category: String) -> String:
    if category == "AUX-9":
        return str(game.equipment_state.fitted_aux)
    var best: String = ""
    var rank: int = -1
    for item in game.equipment_state.fitted_drones:
        var prod: Dictionary = Store.find(item)
        var rarity: String = str(prod.get("rarity", "COMUM"))
        var this_rank: int = Store.rarity_rank(rarity)
        if this_rank > rank:
            rank = this_rank
            best = str(item)
    return best

func _rank_color(rarity: String) -> Color:
    match rarity:
        "COMUM": return Color(0.15, 0.83, 0.70)
        "RARO": return Color(0.20, 0.65, 1.0)
        "EPICO": return Color(0.73, 0.40, 1.0)
        "ELITE": return Color(1.0, 0.69, 0.24)
        "LENDARIO": return Color(1.0, 0.38, 0.31)
    return SKY

func _icon_for_path(model_path: String) -> Texture2D:
    if model_path.is_empty():
        return null
    var stem: String = model_path.get_file().get_basename()
    var img_path: String = "res://assets/ui/g019_shields/%s.png" % stem
    if not ResourceLoader.exists(img_path):
        img_path = "res://assets/ui/g020_ship_previews/%s.png" % stem
    if not ResourceLoader.exists(img_path):
        img_path = "res://assets/ui/g018_mesh_previews/%s.png" % stem
    if not ResourceLoader.exists(img_path):
        img_path = "res://assets/ui/g016_mesh_previews/%s.png" % stem
    return load(img_path) as Texture2D if ResourceLoader.exists(img_path) else null

func _refresh_loadout() -> void:
    for kind in ["ARMAS", "ESCUDOS", "MOTORES", "EXTRAS", "DRONES", "AUX-9"]:
        var widget: Dictionary = card_widgets[kind]
        var name: String = _best_support(kind) if kind in ["DRONES", "AUX-9"] else _best(kind)
        var prod: Dictionary = Store.find(name) if name != "" else {}
        var rarity: String = str(prod.get("rarity", "COMUM")) if name != "" else ""
        var tint: Color = _rank_color(rarity) if name != "" else Color(0.17, 0.31, 0.43)
        (widget["panel"] as PanelContainer).add_theme_stylebox_override("panel", _panel_style(Color(0.012, 0.041, 0.075, 0.98), tint))
        (widget["item"] as Label).text = name if not name.is_empty() else "NAO INSTALADO"
        (widget["item"] as Label).add_theme_color_override("font_color", WHITE if not name.is_empty() else DIM)
        (widget["rarity"] as Label).text = "RARIDADE: " + rarity if not name.is_empty() else "SLOT DISPONIVEL"
        (widget["rarity"] as Label).add_theme_color_override("font_color", tint)
        (widget["mark"] as Label).text = "MELHOR EQUIPADO  •  CONF %d" % (game.equipment_state.active_configuration + 1) if name != "" else "LOJA > COMPRAR > EQUIPAR"
        (widget["mark"] as Label).add_theme_color_override("font_color", GOLD if name != "" else DIM)
        var model_path: String = ""
        if not prod.is_empty():
            model_path = str(prod.get("path", ""))
        elif Catalog.get_item(name).size() > 0:
            model_path = Catalog.model_path(name)
        (widget["thumb"] as TextureRect).texture = _icon_for_path(model_path)

func _fmt_int(n: int) -> String:
    var s: String = str(n)
    var result: String = ""
    for i in range(s.length()):
        if i > 0 and (s.length() - i) % 3 == 0:
            result += "."
        result += s[i]
    return result

func _refresh_stats(ship_id: String) -> void:
    var stats: Dictionary = Ships.get_ship(ship_id)
    var current: Dictionary = {
        "HP": _fmt_int(int(stats.get("hp",0))),
        "ESCUDO": _fmt_int(int(game.MAX_SHIELD)) if ship_id == str(game.current_ship) else "—",
        "VELOCIDADE": str(int(stats.get("speed",0))),
        "PORAO": _fmt_int(int(stats.get("cargo",0))),
        "LASERS": str(int(stats.get("lasers",0))),
        "GERADORES": str(int(stats.get("generators",0))),
        "EXTRAS": str(int(stats.get("extras",0))),
    }
    for key in stat_value_labels.keys():
        var v: Label = stat_value_labels[key] as Label
        v.text = str(current.get(key, "—"))
        v.add_theme_color_override("font_color", GOLD if key == "VELOCIDADE" else WHITE)

func _new_ship_thumbnail(ship_id: String, owned: bool, active: bool) -> Button:
    var card: Button = _button("", SKY if active else (Color(0.20, 0.37, 0.48) if not owned else GOLD))
    card.custom_minimum_size = Vector2(130, 79)
    card.add_theme_font_size_override("font_size", 10)
    var title: String = "ATIVA" if active else ("DESBLOQUEADA" if owned else "BLOQUEADA")
    card.tooltip_text = "%s — %s" % [ship_id, title]
    card.text = "%s\n%s" % [ship_id, title]
    card.icon = _icon_for_path("res://assets/ships/SL_%s_FINAL.glb" % ship_id)
    card.expand_icon = true
    card.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
    card.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
    card.alignment = HORIZONTAL_ALIGNMENT_RIGHT
    card.add_theme_color_override("font_color", WHITE if owned else Color(0.51, 0.60, 0.69))
    if not owned:
        card.modulate = Color(0.38, 0.44, 0.53, 0.91)
    card.pressed.connect(_select_ship.bind(ship_id))
    return card

func _refresh_fleet() -> void:
    for old in fleet_row.get_children():
        fleet_row.remove_child(old)
        old.queue_free()
    for ship_id in ORDER:
        var owned: bool = game.equipment_state.owns_ship(ship_id)
        fleet_row.add_child(_new_ship_thumbnail(ship_id, owned, str(game.current_ship) == ship_id))

func _set_preview_ship(ship_id: String) -> void:
    if hero_model != null and is_instance_valid(hero_model):
        hero_model.queue_free()
        hero_model = null
    var st: Dictionary = Ships.get_ship(ship_id)
    hero_title.text = ship_id
    hero_specs.text = "LASERS %d   •   GERADORES %d   •   EXTRAS %d   •   PORAO %d" % [int(st.get("lasers",0)), int(st.get("generators",0)), int(st.get("extras",0)), int(st.get("cargo",0))]
    var owned: bool = game.equipment_state.owns_ship(ship_id)
    hero_hint.text = "GLB INTEGRAL  •  ARRASTE PARA GIRAR" if owned else "NAVE BLOQUEADA  •  ADQUIRA NA LOJA"
    change_button.text = "NAVE ATIVA" if ship_id == str(game.current_ship) else ("ATIVAR NAVE" if owned else "COMPRAR NA LOJA")
    change_button.disabled = ship_id == str(game.current_ship)
    hero_view.modulate = WHITE if owned else Color(0.42, 0.49, 0.61, 0.93)
    var path: String = str(st.get("model", ""))
    var packed: PackedScene = load(path) as PackedScene
    if packed != null:
        hero_model = packed.instantiate() as Node3D
        hero_pivot.add_child(hero_model)
        hero_model.position = Vector3.ZERO
        hero_model.rotation_degrees = Vector3(0, 10, 0)
        hero_model.scale = Vector3.ONE * 1.65
        hero_model.visible = true
    hero_camera.position = Vector3(6.7, 5.1, 10.6) if ship_id in ["LEVIATHAN", "BULWARK"] else Vector3(5.5, 4.3, 9.0)
    hero_camera.look_at(Vector3(0.0, 0.1, 0.0), Vector3.UP)
    _refresh_stats(ship_id)

func _select_ship(ship_id: String) -> void:
    selected_ship = ship_id
    _set_preview_ship(ship_id)

func _equip_ship() -> void:
    if not game.equipment_state.owns_ship(selected_ship):
        game.ui_shell._open_modal("LOJA")
        return
    if selected_ship != str(game.current_ship):
        game.change_ship_for_hangar(selected_ship)
    open_command()

func open_command() -> void:
    visible = true
    if game == null:
        return
    selected_ship = str(game.current_ship)
    _refresh_loadout()
    _refresh_fleet()
    _set_preview_ship(selected_ship)

func relayout(view: Vector2) -> void:
    size = view
    starport.position = Vector2.ZERO
    starport.size = view
    var w: float = view.x
    var h: float = view.y
    var gap: float = 7.0
    var side_w: float = clampf(w * 0.248, 140.0, 232.0)
    var center_w: float = maxf(160.0, w - 2.0 * side_w - 2.0 * gap)
    var header_h: float = 32.0
    button_tabs.position = Vector2(5, 2)
    button_tabs.size = Vector2(minf(545.0, w - 10), header_h)
    top_detail.position = Vector2(6, header_h + 2)
    top_detail.size = Vector2(w - 12, 17)
    var cards_y: float = header_h + 23
    var bottom_row_h: float = clampf(h * 0.20, 66.0, 88.0)
    var stats_h: float = 48.0
    var fleet_y: float = h - bottom_row_h
    var stats_y: float = fleet_y - stats_h - 7.0
    var top_h: float = maxf(140.0, stats_y - cards_y - 7.0)
    var card_gap: float = 5.0
    var card_h: float = (top_h - 2.0 * card_gap) / 3.0
    var side_x: float = w - side_w
    for i in range(3):
        left_cards[i].position = Vector2(0, cards_y + float(i) * (card_h + card_gap))
        left_cards[i].size = Vector2(side_w, card_h)
        right_cards[i].position = Vector2(side_x, cards_y + float(i) * (card_h + card_gap))
        right_cards[i].size = Vector2(side_w, card_h)
        for side in [left_cards[i], right_cards[i]]:
            var display_cat: String = ["ARMAS", "ESCUDOS", "MOTORES"][i] if side == left_cards[i] else ["EXTRAS", "DRONES", "AUX-9"][i]
            var widgets: Dictionary = card_widgets[display_cat]
            var mark: Label = widgets["mark"] as Label
            mark.visible = card_h >= 70.0
            var thumb: TextureRect = widgets["thumb"] as TextureRect
            thumb.custom_minimum_size = Vector2(57, clampf(card_h * 0.44, 25.0, 36.0))
    center_panel.position = Vector2(side_w + gap, cards_y)
    center_panel.size = Vector2(center_w, top_h)
    hero_title.position = Vector2(3, 2)
    hero_title.size = Vector2(center_w - 6, 28)
    hero_specs.position = Vector2(4, 29)
    hero_specs.size = Vector2(center_w - 8, 16)
    hero_view.position = Vector2(4, 47)
    hero_view.size = Vector2(center_w - 8, maxf(55.0, top_h - 89.0))
    hero_hint.position = Vector2(4, top_h - 42)
    hero_hint.size = Vector2(center_w - 8, 14)
    change_button.position = Vector2(center_w * 0.22, top_h - 27)
    change_button.size = Vector2(center_w * 0.56, 23)
    stat_strip.position = Vector2(0, stats_y)
    stat_strip.size = Vector2(w, stats_h)
    fleet_scroll.position = Vector2(0, fleet_y)
    fleet_scroll.size = Vector2(w, bottom_row_h)
