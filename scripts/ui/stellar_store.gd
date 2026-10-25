extends Control
## G0.13: loja premium nativa, catalogo unificado, compras locais; um GLB por vez.
const Store = preload("res://scripts/data/store_catalog.gd")
const Equip = preload("res://scripts/data/equipment_catalog.gd")
const Ships = preload("res://scripts/data/ship_balance.gd")
const NAVY := Color(0.012, 0.034, 0.076, 0.97)
const CYAN := Color(0.24, 0.83, 1.0)
const WHITE := Color(0.91, 0.96, 1.0)
const GOLD := Color(1.0, 0.74, 0.26)
const MUTED := Color(0.53, 0.72, 0.86)
var game
var backdrop: TextureRect
var left: Panel
var main: Panel
var detail: Panel
var ship_view: SubViewportContainer
var ship_pivot: Node3D
var ship_mesh: Node3D
var item_view: SubViewportContainer
var item_pivot: Node3D
var item_mesh: Node3D
var ship_name: Label
var pilot_info: Label
var balance_label: Label
var category_bar: HFlowContainer
var shelf_scroll: ScrollContainer
var shelf_grid: GridContainer
var item_label: Label
var description: Label
var cost_label: Label
var owned_label: Label
var buy_button: Button
var feedback: Label
var selected: Dictionary = {}
var active_category: String = "NAVES"
var last_ship: String = ""
var rarity_mode: String = "TODOS"
var rarity_row: HBoxContainer

func setup(owner_game) -> void:
    game = owner_game
    mouse_filter = Control.MOUSE_FILTER_STOP
    backdrop = TextureRect.new()
    backdrop.texture = load("res://assets/ui/g013_starport.png") as Texture2D
    backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    backdrop.stretch_mode = TextureRect.STRETCH_SCALE
    backdrop.modulate = Color(0.48, 0.71, 1.0, 0.65)
    backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(backdrop)
    left = _panel(self, CYAN)
    main = _panel(self, CYAN)
    detail = _panel(self, GOLD)
    ship_name = _label(left, "NAVE ATIVA", 17, WHITE)
    pilot_info = _label(left, "ARSENAL ORBITAL", 11, CYAN)
    ship_view = _viewport(left, true)
    ship_pivot = ship_view.get_child(0).get_node("Pivot") as Node3D
    var open_hangar: Button = _button(left, "IR PARA O HANGAR", CYAN)
    open_hangar.name = "GoHangar"
    open_hangar.pressed.connect(func() -> void: game.ui_shell._open_modal("HANGAR"))
    balance_label = _label(main, "SALDO LOCAL", 15, GOLD)
    category_bar = HFlowContainer.new()
    category_bar.add_theme_constant_override("h_separation", 5)
    category_bar.add_theme_constant_override("v_separation", 4)
    main.add_child(category_bar)
    for cat in Store.CATEGORIES:
        var caption: String = {"MODULOS AUX":"MOD AUX", "MUNICOES LASER":"MUNICOES"}.get(cat, cat)
        var tab: Button = _button(category_bar, caption, CYAN)
        tab.set_meta("category", cat)
        tab.add_theme_font_size_override("font_size", 10)
        tab.custom_minimum_size = Vector2(73, 29)
        tab.pressed.connect(_show_category.bind(cat))
    rarity_row = HBoxContainer.new()
    rarity_row.add_theme_constant_override("separation", 5)
    main.add_child(rarity_row)
    for filter_name in ["TODOS", "COMUM", "ELITE"]:
        var filter_button: Button = _button(rarity_row, filter_name, GOLD if filter_name == "ELITE" else CYAN)
        filter_button.custom_minimum_size = Vector2(96, 28)
        filter_button.pressed.connect(_set_rarity_filter.bind(filter_name))
    shelf_scroll = ScrollContainer.new()
    shelf_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    shelf_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
    shelf_scroll.scroll_deadzone = 12
    shelf_scroll.follow_focus = false
    main.add_child(shelf_scroll)
    shelf_grid = GridContainer.new()
    shelf_grid.columns = 3
    shelf_grid.add_theme_constant_override("h_separation", 7)
    shelf_grid.add_theme_constant_override("v_separation", 7)
    shelf_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    shelf_scroll.add_child(shelf_grid)
    _label(detail, "INSPECAO 3D", 14, GOLD)
    item_view = _viewport(detail, false)
    item_pivot = item_view.get_child(0).get_node("Pivot") as Node3D
    item_label = _label(detail, "SELECIONE UM ITEM", 14, WHITE)
    description = _label(detail, "GLB original / qualidade integral", 10, MUTED)
    description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    cost_label = _label(detail, "", 13, GOLD)
    owned_label = _label(detail, "", 10, CYAN)
    buy_button = _button(detail, "COMPRAR", GOLD)
    buy_button.pressed.connect(_buy_selected)
    feedback = _label(self, "LOJA DE TESTE: compras locais, sem pagamento real.", 11, GOLD)
    _show_category("NAVES")
    relayout(size)

func _skin(edge: Color, bg: Color = NAVY) -> StyleBoxFlat:
    var skin: StyleBoxFlat = StyleBoxFlat.new()
    skin.bg_color = bg
    skin.border_color = edge
    skin.set_border_width_all(2)
    skin.set_corner_radius_all(8)
    skin.shadow_color = Color(edge.r, edge.g, edge.b, 0.20)
    skin.shadow_size = 5
    return skin

func _panel(parent: Node, edge: Color) -> Panel:
    var panel: Panel = Panel.new()
    panel.add_theme_stylebox_override("panel", _skin(edge))
    parent.add_child(panel)
    return panel

func _label(parent: Node, caption: String, font: int, tint: Color) -> Label:
    var label: Label = Label.new()
    label.text = caption
    label.clip_text = true
    label.add_theme_color_override("font_color", tint)
    label.add_theme_font_size_override("font_size", font)
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(label)
    return label

func _button(parent: Node, caption: String, tint: Color) -> Button:
    var button: Button = Button.new()
    button.text = caption
    button.focus_mode = Control.FOCUS_NONE
    button.mouse_filter = Control.MOUSE_FILTER_STOP
    button.add_theme_font_size_override("font_size", 11)
    button.add_theme_color_override("font_color", WHITE)
    button.add_theme_stylebox_override("normal", _skin(tint.darkened(0.4), Color(0.021, 0.07, 0.12, 0.98)))
    button.add_theme_stylebox_override("hover", _skin(tint, Color(0.035, 0.12, 0.18, 0.98)))
    button.add_theme_stylebox_override("pressed", _skin(tint, Color(0.045, 0.17, 0.21, 0.98)))
    parent.add_child(button)
    return button

func _viewport(parent: Node, ship: bool) -> SubViewportContainer:
    var wrap: SubViewportContainer = SubViewportContainer.new()
    wrap.stretch = true
    wrap.mouse_filter = Control.MOUSE_FILTER_STOP
    parent.add_child(wrap)
    var vp: SubViewport = SubViewport.new()
    vp.size = Vector2i(480, 420) if ship else Vector2i(300, 270)
    vp.own_world_3d = true
    vp.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
    vp.name = "Showcase"
    wrap.add_child(vp)
    var world: WorldEnvironment = WorldEnvironment.new()
    var env: Environment = Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.003, 0.017, 0.045)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.39, 0.66, 1.0)
    env.ambient_light_energy = 1.05
    world.environment = env
    vp.add_child(world)
    var pivot: Node3D = Node3D.new()
    pivot.name = "Pivot"
    vp.add_child(pivot)
    var camera: Camera3D = Camera3D.new()
    camera.fov = 44
    camera.position = Vector3(0, 5, 13) if ship else Vector3(0, 4.5, 10)
    camera.current = true
    vp.add_child(camera)
    camera.look_at(Vector3.ZERO, Vector3.UP)
    for i in range(3):
        var lamp: DirectionalLight3D = DirectionalLight3D.new()
        lamp.rotation_degrees = Vector3(-45, -50.0 + i * 100.0, 0)
        lamp.light_energy = 1.8 if i == 0 else 0.9
        lamp.light_color = [Color(0.56, 0.83, 1.0), Color(0.21, 0.63, 1.0), Color(1.0, 0.65, 0.31)][i]
        vp.add_child(lamp)
    var pedestal: MeshInstance3D = MeshInstance3D.new()
    var mesh: CylinderMesh = CylinderMesh.new()
    mesh.top_radius = 3.2 if ship else 1.9
    mesh.bottom_radius = mesh.top_radius + 0.4
    mesh.height = 0.2
    mesh.radial_segments = 48
    var metal: StandardMaterial3D = StandardMaterial3D.new()
    metal.albedo_color = Color(0.06, 0.14, 0.2)
    metal.metallic = 0.7
    mesh.material = metal
    pedestal.mesh = mesh
    pedestal.position.y = -1.8
    vp.add_child(pedestal)
    for j in range(2):
        var ring: MeshInstance3D = MeshInstance3D.new()
        var torus: TorusMesh = TorusMesh.new()
        torus.inner_radius = (2.4 if ship else 1.5) + j * 0.35
        torus.outer_radius = torus.inner_radius + 0.05
        var glow: StandardMaterial3D = StandardMaterial3D.new()
        glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        glow.albedo_color = CYAN if j == 0 else GOLD
        glow.emission_enabled = true
        glow.emission = glow.albedo_color
        torus.material = glow
        ring.mesh = torus
        ring.position.y = -1.65
        vp.add_child(ring)
    return wrap

func _set_model(pivot: Node3D, path: String, scale: float) -> Node3D:
    for old in pivot.get_children():
        pivot.remove_child(old)
        old.queue_free()
    if path.is_empty():
        return null
    var scene: PackedScene = load(path) as PackedScene
    if scene == null:
        return null
    var model: Node3D = scene.instantiate() as Node3D
    if model == null:
        return null
    pivot.add_child(model)
    model.scale = Vector3.ONE * scale
    model.rotation = Vector3(0.15, -0.15, 0)
    return model

func open_store() -> void:
    visible = true
    _refresh_ship()
    _show_category(active_category)

func _refresh_ship() -> void:
    if game == null:
        return
    var name: String = str(game.current_ship)
    var stats: Dictionary = Ships.get_ship(name)
    ship_name.text = name + "  /  NAVE ATIVA"
    pilot_info.text = "%s HP  •  VEL %d  •  PORAO %d\nLASER %d  /  GER %d  /  EXT %d" % [str(stats.get("hp", 0)), int(stats.get("speed", 0)), int(stats.get("cargo", 0)), int(stats.get("lasers", 1)), int(stats.get("generators", 1)), int(stats.get("extras", 1))]
    # Dados do balanceamento oficial; carteira e compras sao apenas demonstrativas.
    if name != last_ship:
        last_ship = name
        ship_mesh = _set_model(ship_pivot, "res://assets/ships/SL_%s_FINAL.glb" % name, 0.9)
    balance_label.text = "LOJA ESTELAR  |  %s CR   •   %s STL   |   VALORES OFICIAIS / SALDO LOCAL" % [_fmt(game.wallet.credits), _fmt(game.wallet.stellarium)]

func _tint(rarity: String) -> Color:
    match rarity:
        "LENDARIO": return Color(1.0, 0.65, 0.17)
        "EPICO": return Color(0.79, 0.40, 1.0)
        "RARO": return Color(0.19, 0.66, 1.0)
        "COMUM": return Color(0.28, 0.88, 0.66)
        "ELITE": return Color(0.78, 0.37, 1.0)
    return CYAN

func _clear(parent: Node) -> void:
    for child in parent.get_children():
        parent.remove_child(child)
        child.queue_free()

func _show_category(category: String) -> void:
    active_category = category
    _refresh_ship()
    _clear(shelf_grid)
    selected = {}
    item_label.text = "SELECIONE UM ITEM"
    description.text = "O modelo GLB surgira ao selecionar."
    cost_label.text = ""
    owned_label.text = ""
    buy_button.disabled = true
    item_mesh = _set_model(item_pivot, "", 1.0)
    for b in category_bar.get_children():
        if b is Button:
            (b as Button).add_theme_color_override("font_color", GOLD if str((b as Button).get_meta("category", "")) == category else WHITE)
    var items: Array[Dictionary] = Store.all_in(category)
    for product in items:
        if rarity_mode != "TODOS" and str(product.get("rarity", "")) != rarity_mode:
            continue
        _create_product_card(product)
    shelf_scroll.scroll_vertical = 0

func _set_rarity_filter(filter_name: String) -> void:
    rarity_mode = filter_name
    _show_category(active_category)

func _create_product_card(product: Dictionary) -> void:
    var name: String = str(product["name"])
    var rarity: String = str(product["rarity"])
    var accent: Color = _tint(rarity)
    var card: PanelContainer = PanelContainer.new()
    card.custom_minimum_size = Vector2(166, 218)
    card.mouse_filter = Control.MOUSE_FILTER_PASS
    card.add_theme_stylebox_override("panel", _skin(accent, Color(0.013, 0.040, 0.08, 0.99)))
    shelf_grid.add_child(card)
    var inner: VBoxContainer = VBoxContainer.new()
    inner.add_theme_constant_override("separation", 1)
    card.add_child(inner)
    var rarity_label: Label = _label(inner, rarity + "   // " + str(product["category"]), 9, accent)
    rarity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    var art: TextureRect = TextureRect.new()
    art.custom_minimum_size = Vector2(152, 119)
    art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    art.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var thumb: String = Equip.thumbnail_path(name)
    var glb_thumb: String = "res://assets/ui/g014_models/%s.png" % str(product["path"]).get_file().get_basename()
    if ResourceLoader.exists(glb_thumb):
        thumb = glb_thumb
    if thumb == "":
        var model_path: String = str(product["path"])
        thumb = "res://assets/ui/g013_models/%s.png" % model_path.get_file().get_basename()
        if not ResourceLoader.exists(thumb):
            thumb = "res://assets/ui/g013_item_insignia.png"
    art.texture = load(thumb) as Texture2D
    inner.add_child(art)
    var label: Label = _label(inner, name, 11, WHITE)
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    var currency: String = str(product.get("currency", "credits"))
    var for_sale: bool = bool(product.get("shop_visible", false)) and int(product.get("cost", 0)) > 0
    var price_text: String = "%s %s" % [_fmt(int(product.get("cost", 0))), game.wallet.display_currency(currency)] if for_sale else "EXCLUSIVO / EVENTO"
    var price: Label = _label(inner, price_text, 12, GOLD if currency == "credits" else Color(0.75, 0.4, 1.0))
    price.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    var inspect: Button = _button(inner, "VER MODELO 3D", accent)
    inspect.custom_minimum_size.y = 27
    inspect.add_theme_font_size_override("font_size", 10)
    inspect.pressed.connect(_select_product.bind(product))

func _select_product(product: Dictionary) -> void:
    selected = product
    var name: String = str(product["name"])
    item_label.text = name
    description.text = str(product.get("desc", ""))
    if str(product.get("category", "")) == "NAVES":
        description.text = "%s  |  %s HP  |  VEL %d  |  PORAO %d  |  LASER %d / GER %d / EXTRA %d" % [name, str(product.get("hp", 0)), int(product.get("speed", 0)), int(product.get("cargo", 0)), int(product.get("lasers", 0)), int(product.get("generators", 0)), int(product.get("extras", 0))]
    var currency: String = str(product.get("currency", "credits"))
    var marketable: bool = bool(product.get("shop_visible", false)) and int(product.get("cost", 0)) > 0
    cost_label.text = "%s %s" % [_fmt(int(product.get("cost", 0))), game.wallet.display_currency(currency)] if marketable else "EXCLUSIVO / EVENTO"
    var owned: int = 0
    match str(product["category"]):
        "NAVES": owned = 1 if game.equipment_state.owns_ship(name) else 0
        "DRONES", "AUX-9", "MODULOS AUX": owned = game.equipment_state.owned_support(name)
        "MUNICOES LASER", "MISSEIS": owned = int(game.equipment_state.consumables.get(name, 0))
        _: owned = int(game.equipment_state.stock.get(name, 0))
    owned_label.text = "NO HANGAR: %d" % owned
    buy_button.disabled = not marketable or game.wallet.balance(currency) < int(product["cost"])
    if str(product["category"]) == "NAVES" and owned > 0:
        buy_button.disabled = true
    buy_button.text = "ADQUIRIDO" if str(product["category"]) == "NAVES" and owned > 0 else ("COMPRAR | %s %s" % [_fmt(int(product.get("cost", 0))), game.wallet.display_currency(currency)] if marketable else "NAO DISPONIVEL")
    item_mesh = _set_model(item_pivot, str(product["path"]), 1.25 if str(product["category"]) != "NAVES" else 0.85)

func _buy_selected() -> void:
    if selected.is_empty():
        return
    var name: String = str(selected["name"])
    var result: String = game.wallet.buy(selected, game.equipment_state)
    feedback.text = result
    game._on_equipment_changed()
    _refresh_ship()
    _select_product(selected)

func _fmt(number: int) -> String:
    var text_value: String = str(number)
    var out: String = ""
    var i: int = 0
    for pos in range(text_value.length() - 1, -1, -1):
        if i > 0 and i % 3 == 0:
            out = "." + out
        out = text_value[pos] + out
        i += 1
    return out

func _process(delta: float) -> void:
    if not visible:
        return
    if ship_mesh != null and is_instance_valid(ship_mesh):
        ship_mesh.rotation.y += delta * 0.12
    if item_mesh != null and is_instance_valid(item_mesh):
        item_mesh.rotation.y += delta * 0.5

func relayout(view: Vector2) -> void:
    size = view
    backdrop.position = Vector2.ZERO
    backdrop.size = view
    var w: float = view.x
    var h: float = view.y
    var gap: float = 7.0
    var left_w: float = w * 0.275
    var right_w: float = maxf(154.0, w * 0.22)
    var center_w: float = w - left_w - right_w - 2.0 * gap
    left.position = Vector2.ZERO
    left.size = Vector2(left_w, h - 24)
    main.position = Vector2(left_w + gap, 0)
    main.size = Vector2(center_w, h - 24)
    detail.position = Vector2(left_w + center_w + 2.0 * gap, 0)
    detail.size = Vector2(right_w, h - 24)
    ship_name.position = Vector2(10, 10)
    ship_name.size = Vector2(left_w - 20, 24)
    pilot_info.position = Vector2(10, 35)
    pilot_info.size = Vector2(left_w - 20, 44)
    ship_view.position = Vector2(7, 87)
    ship_view.size = Vector2(left_w - 14, h - 169)
    var go: Button = left.get_node("GoHangar") as Button
    go.position = Vector2(9, h - 71)
    go.size = Vector2(left_w - 18, 36)
    balance_label.position = Vector2(9, 6)
    balance_label.size = Vector2(center_w - 18, 25)
    category_bar.position = Vector2(6, 36)
    category_bar.size = Vector2(center_w - 12, 66)
    rarity_row.position = Vector2(8, 103)
    rarity_row.size = Vector2(center_w - 16, 34)
    shelf_grid.columns = 3 if center_w >= 530.0 else 2
    shelf_scroll.position = Vector2(6, 139)
    shelf_scroll.size = Vector2(center_w - 12, h - 174)
    var card_width: float = maxf(160.0, (center_w - 40.0) / float(shelf_grid.columns))
    for card in shelf_grid.get_children():
        if card is PanelContainer:
            (card as PanelContainer).custom_minimum_size.x = card_width
    var titles: Array[Node] = detail.get_children()
    if titles.size() > 0 and titles[0] is Label:
        (titles[0] as Label).position = Vector2(8, 7)
        (titles[0] as Label).size = Vector2(right_w - 16, 24)
    item_view.position = Vector2(7, 34)
    item_view.size = Vector2(right_w - 14, h * 0.50)
    item_label.position = Vector2(9, 43 + h * 0.50)
    item_label.size = Vector2(right_w - 18, 22)
    description.position = Vector2(9, 68 + h * 0.50)
    description.size = Vector2(right_w - 18, 51)
    cost_label.position = Vector2(9, 99 + h * 0.50)
    cost_label.size = Vector2(right_w - 18, 19)
    owned_label.position = Vector2(9, 122 + h * 0.50)
    owned_label.size = Vector2(right_w - 18, 18)
    buy_button.position = Vector2(8, h - 79)
    buy_button.size = Vector2(right_w - 16, 37)
    feedback.position = Vector2(8, h - 20)
    feedback.size = Vector2(w - 16, 19)
