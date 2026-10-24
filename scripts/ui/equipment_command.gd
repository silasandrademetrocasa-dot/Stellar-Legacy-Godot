extends Control
## G0.11: Estacao de equipamentos nativa Godot; nenhuma miniatura 2D de referencia.
## Nave | slots | inventario. Tudo local e persistido pelo EquipmentState existente.
const Catalog = preload("res://scripts/data/equipment_catalog.gd")
const CYAN := Color(0.22, 0.78, 1.0)
const WHITE := Color(0.88, 0.96, 1.0)
const MUTED := Color(0.52, 0.68, 0.8)
const GOLD := Color(1.0, 0.74, 0.35)
const PANEL := Color(0.015, 0.034, 0.068, 0.98)
var game
var left_panel: Panel
var center_panel: Panel
var right_panel: Panel
var ship_caption: Label
var ship_view: SubViewportContainer
var ship_root: Node3D
var ship_mesh: Node3D
var preset_one: Button
var preset_two: Button
var slot_scroll: ScrollContainer
var slot_stack: VBoxContainer
var filter_row: HBoxContainer
var inventory_scroll: ScrollContainer
var inventory_grid: GridContainer
var item_view: SubViewportContainer
var item_root: Node3D
var item_mesh: Node3D
var item_caption: Label
var detail_caption: Label
var equip_button: Button
var remove_button: Button
var copy_button: Button
var status: Label
var category: String = "ARMAS"
var selected_name: String = ""
var ship_loaded: String = ""

func setup(owner_game) -> void:
    game = owner_game
    mouse_filter = Control.MOUSE_FILTER_STOP
    left_panel = _panel(self)
    center_panel = _panel(self)
    right_panel = _panel(self)
    _premium_border(left_panel, CYAN)
    _premium_border(center_panel, Color(0.33, 0.80, 1.0))
    _premium_border(right_panel, GOLD)
    ship_caption = _label(left_panel, "NAVE ATIVA", 15, CYAN)
    ship_view = _showcase(left_panel, true)
    ship_root = ship_view.get_child(0).get_node("ModelPivot") as Node3D
    var see_ship := _button(left_panel, "VER / TROCAR NAVE")
    see_ship.name = "VerNave"
    see_ship.pressed.connect(func() -> void: game.ui_shell._open_modal("HANGAR"))
    _label(center_panel, "CONFIGURACAO GLOBAL", 15, CYAN)
    preset_one = _button(center_panel, "CONFIG 1")
    preset_two = _button(center_panel, "CONFIG 2")
    preset_one.pressed.connect(_switch_config.bind(0))
    preset_two.pressed.connect(_switch_config.bind(1))
    copy_button = _button(center_panel, "COPIAR CONFIG")
    copy_button.pressed.connect(_copy_config)
    slot_scroll = ScrollContainer.new()
    slot_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    slot_scroll.scroll_deadzone = 10
    slot_scroll.follow_focus = false
    center_panel.add_child(slot_scroll)
    slot_stack = VBoxContainer.new()
    slot_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    slot_stack.add_theme_constant_override("separation", 6)
    slot_scroll.add_child(slot_stack)
    _label(right_panel, "INVENTARIO", 15, CYAN)
    filter_row = HBoxContainer.new()
    filter_row.add_theme_constant_override("separation", 3)
    right_panel.add_child(filter_row)
    for kind in Catalog.CATEGORY_NAMES:
        var b := _button(filter_row, str({"ARMAS":"ARC", "ESCUDOS":"ESC", "MOTORES":"MOT", "EXTRAS":"EXT"}.get(kind, kind)))
        b.add_theme_font_size_override("font_size", 10)
        b.pressed.connect(_filter.bind(kind))
    inventory_scroll = ScrollContainer.new()
    inventory_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    inventory_scroll.scroll_deadzone = 12
    inventory_scroll.follow_focus = false
    right_panel.add_child(inventory_scroll)
    inventory_grid = GridContainer.new()
    inventory_grid.columns = 3
    inventory_grid.add_theme_constant_override("h_separation", 4)
    inventory_grid.add_theme_constant_override("v_separation", 4)
    inventory_scroll.add_child(inventory_grid)
    item_view = _showcase(right_panel, false)
    item_view.visible = false
    item_root = item_view.get_child(0).get_node("ModelPivot") as Node3D
    item_caption = _label(right_panel, "SELECIONE UM ITEM", 12, WHITE)
    detail_caption = _label(right_panel, "Modelo 3D aparece apos selecionar.", 10, MUTED)
    equip_button = _button(right_panel, "EQUIPAR")
    equip_button.pressed.connect(_equip_selected)
    remove_button = _button(right_panel, "REMOVER")
    remove_button.pressed.connect(_remove_selected)
    status = _label(self, "Slots vazios podem receber o item selecionado. Toque um slot ocupado para remover.", 11, GOLD)
    _filter("ARMAS")
    relayout(size)

func _premium_border(target: Panel, accent: Color) -> void:
    var skin := StyleBoxFlat.new()
    skin.bg_color = PANEL
    skin.border_color = accent
    skin.border_width_left = 2
    skin.border_width_right = 2
    skin.border_width_top = 2
    skin.border_width_bottom = 2
    skin.corner_radius_top_left = 9
    skin.corner_radius_top_right = 9
    skin.corner_radius_bottom_left = 9
    skin.corner_radius_bottom_right = 9
    skin.shadow_color = Color(accent.r, accent.g, accent.b, 0.14)
    skin.shadow_size = 3
    target.add_theme_stylebox_override("panel", skin)

func _panel(parent: Node) -> Panel:
    var p := Panel.new()
    var box := StyleBoxFlat.new()
    box.bg_color = PANEL
    box.border_color = Color(0.08, 0.42, 0.7, 0.92)
    box.set_border_width_all(1)
    box.set_corner_radius_all(7)
    p.add_theme_stylebox_override("panel", box)
    parent.add_child(p)
    return p

func _label(parent: Node, caption: String, font: int, tint: Color) -> Label:
    var l := Label.new()
    l.text = caption
    l.add_theme_color_override("font_color", tint)
    l.add_theme_font_size_override("font_size", font)
    l.clip_text = true
    l.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(l)
    return l

func _button(parent: Node, caption: String) -> Button:
    var b := Button.new()
    b.text = caption
    b.add_theme_font_size_override("font_size", 11)
    b.add_theme_color_override("font_color", WHITE)
    b.mouse_filter = Control.MOUSE_FILTER_STOP
    b.focus_mode = Control.FOCUS_NONE
    var skin := StyleBoxFlat.new()
    skin.bg_color = Color(0.027, 0.085, 0.15)
    skin.border_color = Color(0.16, 0.46, 0.67)
    skin.set_border_width_all(1)
    skin.set_corner_radius_all(6)
    b.add_theme_stylebox_override("normal", skin)
    var hot := skin.duplicate() as StyleBoxFlat
    hot.bg_color = Color(0.05, 0.2, 0.32)
    hot.border_color = CYAN
    b.add_theme_stylebox_override("hover", hot)
    b.add_theme_stylebox_override("pressed", hot)
    parent.add_child(b)
    return b

func _showcase(parent: Node, ship: bool) -> SubViewportContainer:
    var wrap := SubViewportContainer.new()
    wrap.stretch = true
    wrap.mouse_filter = Control.MOUSE_FILTER_STOP
    parent.add_child(wrap)
    var vp := SubViewport.new()
    vp.name = "PreviewViewport"
    vp.size = Vector2i(480, 360) if ship else Vector2i(320, 200)
    vp.own_world_3d = true
    vp.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
    wrap.add_child(vp)
    var env := WorldEnvironment.new()
    var atmosphere := Environment.new()
    atmosphere.background_mode = Environment.BG_COLOR
    atmosphere.background_color = Color(0.005, 0.021, 0.051)
    atmosphere.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    atmosphere.ambient_light_color = Color(0.43, 0.67, 1.0)
    atmosphere.ambient_light_energy = 0.85
    env.environment = atmosphere
    vp.add_child(env)
    var pivot := Node3D.new()
    pivot.name = "ModelPivot"
    vp.add_child(pivot)
    var camera := Camera3D.new()
    camera.fov = 45
    camera.position = Vector3(0, 5.5, 15.0) if ship else Vector3(0, 3.8, 10.0)
    camera.current = true
    vp.add_child(camera)
    camera.look_at(Vector3.ZERO, Vector3.UP)
    for side in range(2):
        var lamp := DirectionalLight3D.new()
        lamp.rotation_degrees = Vector3(-45, -35 if side == 0 else 135, 0)
        lamp.light_energy = 1.7 if side == 0 else 0.8
        lamp.light_color = Color(0.72, 0.89, 1.0) if side == 0 else Color(0.13, 0.65, 1.0)
        vp.add_child(lamp)
    var platform := MeshInstance3D.new()
    var disc := CylinderMesh.new()
    disc.top_radius = 3.5 if ship else 2.5
    disc.bottom_radius = disc.top_radius + 0.2
    disc.height = 0.24
    disc.radial_segments = 48
    var metal := StandardMaterial3D.new()
    metal.albedo_color = Color(0.065, 0.16, 0.24)
    metal.metallic = 0.75
    metal.roughness = 0.2
    disc.material = metal
    platform.mesh = disc
    platform.position.y = -1.6
    vp.add_child(platform)
    for i in range(2):
        var halo := MeshInstance3D.new()
        var tor := TorusMesh.new()
        tor.inner_radius = (2.1 if ship else 1.45) + float(i) * 0.55
        tor.outer_radius = tor.inner_radius + 0.065
        var lightmat := StandardMaterial3D.new()
        lightmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        lightmat.albedo_color = CYAN if i == 0 else Color(0.10, 0.40, 0.78)
        lightmat.emission_enabled = true
        lightmat.emission = lightmat.albedo_color
        tor.material = lightmat
        halo.mesh = tor
        halo.position.y = -1.42 + float(i) * 0.005
        vp.add_child(halo)
    return wrap

func _set_model(root: Node3D, path: String, scale_factor: float) -> Node3D:
    for child in root.get_children():
        root.remove_child(child)
        child.queue_free()
    var scene := load(path) as PackedScene
    if scene == null:
        return null
    var obj := scene.instantiate() as Node3D
    if obj == null:
        return null
    root.add_child(obj)
    obj.scale = Vector3.ONE * scale_factor
    obj.rotation = Vector3(0.13, -0.25, 0)
    return obj

func _load_ship() -> void:
    if game == null:
        return
    var ship_id: String = str(game.current_ship)
    if ship_id == ship_loaded:
        return
    ship_loaded = ship_id
    ship_caption.text = "%s  |  NAVE ATIVA" % ship_id
    ship_mesh = _set_model(ship_root, "res://assets/ships/SL_%s_FINAL.glb" % ship_id, 0.85)

func open_command() -> void:
    visible = true
    _load_ship()
    _redraw_all()

func _switch_config(index: int) -> void:
    _notice(game.equipment_state.select_configuration(index))
    _redraw_all()
    game._on_equipment_changed()

func _copy_config() -> void:
    _notice(game.equipment_state.copy_to_other())
    _redraw_all()

func _filter(kind: String) -> void:
    category = kind
    selected_name = ""
    item_view.visible = false
    item_caption.text = "SELECIONE UM ITEM"
    detail_caption.text = "Toque um quadrado para inspecionar em 3D."
    for child in item_root.get_children():
        item_root.remove_child(child)
        child.queue_free()
    _redraw_grid()
    _update_actions()

func _redraw_all() -> void:
    _load_ship()
    _redraw_slots()
    _redraw_grid()
    _update_actions()
    preset_one.text = ("◆ " if game.equipment_state.active_configuration == 0 else "") + "CONFIG 1"
    preset_two.text = ("◆ " if game.equipment_state.active_configuration == 1 else "") + "CONFIG 2"

func _clear(parent: Node) -> void:
    for child in parent.get_children():
        parent.remove_child(child)
        child.queue_free()

func _redraw_slots() -> void:
    if slot_stack == null or game == null:
        return
    var old_pos: int = slot_scroll.scroll_vertical
    _clear(slot_stack)
    for kind in Catalog.CATEGORY_NAMES:
        var values: Array[String] = game.equipment_state.equipped(kind)
        var used: int = 0
        for value in values:
            if value != "":
                used += 1
        var title := _label(slot_stack, "%s   %d / %d" % [kind, used, values.size()], 12, CYAN)
        title.custom_minimum_size.y = 17
        var row := HFlowContainer.new()
        row.add_theme_constant_override("h_separation", 4)
        row.add_theme_constant_override("v_separation", 4)
        slot_stack.add_child(row)
        for i in range(values.size()):
            var name: String = values[i]
            var caption: String = name if name != "" else "+"
            var b := _button(row, caption)
            b.custom_minimum_size = Vector2(68, 41)
            b.add_theme_font_size_override("font_size", 10)
            b.tooltip_text = "Toque para remover" if name != "" else "Toque para equipar o item selecionado"
            b.pressed.connect(_slot_pressed.bind(kind, i, name))
    slot_scroll.set_deferred("scroll_vertical", old_pos)

func _slot_pressed(kind: String, index: int, content: String) -> void:
    var result: String = ""
    if content != "":
        result = game.equipment_state.remove_at(kind, index)
    elif selected_name != "" and str(Catalog.get_item(selected_name).get("category", "")) == kind:
        result = game.equipment_state.equip_at(selected_name, index)
    else:
        result = "Selecione um item de %s no inventario primeiro" % kind
    _notice(result)
    game._on_equipment_changed()
    _redraw_all()

func _redraw_grid() -> void:
    if inventory_grid == null or game == null:
        return
    var old_pos: int = inventory_scroll.scroll_vertical
    _clear(inventory_grid)
    for entry in Catalog.items_in_category(category):
        var name: String = str(entry["name"])
        var count: int = int(game.equipment_state.stock.get(name, 0))
        if count <= 0:
            continue
        var card := _button(inventory_grid, "%s\n×%d" % [name, count])
        card.custom_minimum_size = Vector2(65, 59)
        card.clip_text = true
        card.add_theme_font_size_override("font_size", 10)
        if selected_name == name:
            card.add_theme_color_override("font_color", GOLD)
        card.pressed.connect(_choose_item.bind(name))
    if inventory_grid.get_child_count() == 0:
        var empty := _label(inventory_grid, "SEM ITENS", 11, MUTED)
        empty.custom_minimum_size = Vector2(160, 30)
    inventory_scroll.set_deferred("scroll_vertical", old_pos)

func _choose_item(name: String) -> void:
    selected_name = name
    var entry: Dictionary = Catalog.get_item(name)
    item_caption.text = name
    detail_caption.text = "%s  |  +%s  |  livres %d" % [str(entry.get("desc", "")), str(entry.get("bonus", 0)), game.equipment_state.free_amount(name)]
    item_mesh = _set_model(item_root, Catalog.model_path(name), 1.35)
    item_view.visible = true
    _redraw_grid()
    _update_actions()

func _update_actions() -> void:
    var selected: bool = selected_name != ""
    equip_button.disabled = not selected or game.equipment_state.free_amount(selected_name) <= 0
    remove_button.disabled = not selected

func _equip_selected() -> void:
    if selected_name == "":
        return
    var result: String = game.equipment_state.equip(selected_name)
    _notice(result)
    game._on_equipment_changed()
    _redraw_all()

func _remove_selected() -> void:
    if selected_name == "":
        return
    var result: String = game.equipment_state.remove_matching(selected_name)
    _notice(result)
    game._on_equipment_changed()
    _redraw_all()

func _notice(message: String) -> void:
    status.text = message

func _process(delta: float) -> void:
    if not visible:
        return
    if ship_mesh != null and is_instance_valid(ship_mesh):
        ship_mesh.rotation.y += delta * 0.16
    if item_mesh != null and is_instance_valid(item_mesh):
        item_mesh.rotation.y += delta * 0.62

func relayout(view: Vector2) -> void:
    size = view
    var w: float = view.x
    var h: float = view.y
    var gap: float = 6.0
    var left_w: float = floorf((w - 2.0 * gap) * 0.275)
    var center_w: float = floorf((w - 2.0 * gap) * 0.375)
    var right_w: float = w - 2.0 * gap - left_w - center_w
    left_panel.position = Vector2.ZERO
    left_panel.size = Vector2(left_w, h - 24)
    center_panel.position = Vector2(left_w + gap, 0)
    center_panel.size = Vector2(center_w, h - 24)
    right_panel.position = Vector2(left_w + center_w + 2.0 * gap, 0)
    right_panel.size = Vector2(right_w, h - 24)
    ship_caption.position = Vector2(9, 8)
    ship_caption.size = Vector2(left_w - 18, 22)
    ship_view.position = Vector2(6, 34)
    ship_view.size = Vector2(left_w - 12, h - 109)
    var ship_button := left_panel.get_node("VerNave") as Button
    ship_button.position = Vector2(9, h - 66)
    ship_button.size = Vector2(left_w - 18, 31)
    preset_one.position = Vector2(8, 33)
    preset_one.size = Vector2(center_w * 0.32, 30)
    preset_two.position = Vector2(12 + center_w * 0.32, 33)
    preset_two.size = Vector2(center_w * 0.32, 30)
    copy_button.position = Vector2(center_w * 0.67, 33)
    copy_button.size = Vector2(center_w * 0.31, 30)
    slot_scroll.position = Vector2(8, 71)
    slot_scroll.size = Vector2(center_w - 16, h - 103)
    filter_row.position = Vector2(7, 33)
    filter_row.size = Vector2(right_w - 14, 30)
    for b in filter_row.get_children():
        if b is Button:
            (b as Button).custom_minimum_size.x = (right_w - 18) / 4.0 - 3.0
    inventory_scroll.position = Vector2(7, 69)
    inventory_scroll.size = Vector2(right_w - 14, maxf(76, h * 0.30))
    item_view.position = Vector2(7, 72 + inventory_scroll.size.y)
    item_view.size = Vector2(right_w - 14, maxf(76, h - 187 - inventory_scroll.size.y))
    item_caption.position = Vector2(10, h - 103)
    item_caption.size = Vector2(right_w - 20, 18)
    detail_caption.position = Vector2(10, h - 84)
    detail_caption.size = Vector2(right_w - 20, 16)
    equip_button.position = Vector2(9, h - 64)
    equip_button.size = Vector2((right_w - 26) * 0.53, 29)
    remove_button.position = Vector2(16 + equip_button.size.x, h - 64)
    remove_button.size = Vector2((right_w - 26) * 0.47, 29)
    status.position = Vector2(7, h - 21)
    status.size = Vector2(w - 14, 20)
