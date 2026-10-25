extends Control
## Isolated review gallery; no gameplay, wallet or save state changes.
signal closed
const Design = preload("res://scripts/ui/design/galactic_theme.gd")
const GalacticPanel = preload("res://scripts/ui/design/galactic_panel.gd")
const Emblem = preload("res://scripts/ui/design/galactic_emblem.gd")
const HOLOGRAM = preload("res://shaders/galactic_hologram.gdshader")
var low_effects := false
var reduced_motion := false
var backdrop: ColorRect
var background_material: ShaderMaterial
var shell: MarginContainer
var scroll: ScrollContainer
var content: VBoxContainer
var cards: GridContainer
var hero_row: BoxContainer
var feedback: Label
var primary_button: Button
var secondary_button: Button
var disabled_button: Button
var return_button: Button
var motion_toggle: CheckButton
var entry_tween: Tween

func _ready() -> void:
    name = "DesignSystemPreview"
    theme = Design.build()
    mouse_filter = Control.MOUSE_FILTER_STOP
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    backdrop = ColorRect.new()
    backdrop.color = Design.VOID
    backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(backdrop)
    background_material = ShaderMaterial.new()
    background_material.shader = HOLOGRAM
    shell = MarginContainer.new()
    shell.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    for edge in ["left", "right", "top", "bottom"]:
        shell.add_theme_constant_override("margin_" + edge, 20)
    add_child(shell)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 16)
    shell.add_child(column)
    var header := HBoxContainer.new()
    header.add_theme_constant_override("separation", 12)
    column.add_child(header)
    var identity := VBoxContainer.new()
    identity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(identity)
    _label(identity, "STELLAR LEGACY", "GalacticTitle")
    _label(identity, "NÚCLEO DE IDENTIDADE  /  ETAPA 01", "GalacticCaption")
    return_button = _button(header, "VOLTAR", "GalacticSecondaryButton")
    return_button.pressed.connect(request_close)
    scroll = ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    scroll.scroll_deadzone = 8
    scroll.follow_focus = true
    column.add_child(scroll)
    content = VBoxContainer.new()
    content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation", 16)
    scroll.add_child(content)
    _build_hero()
    cards = GridContainer.new()
    cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    cards.add_theme_constant_override("h_separation", 12)
    cards.add_theme_constant_override("v_separation", 12)
    content.add_child(cards)
    _swatch("ION", "Navegação e ação principal", Design.ION)
    _swatch("AMBER", "Atenção e foco de navegação", Design.AMBER)
    _swatch("ASTRAL", "Descoberta e energia profunda", Design.VIOLET)
    _build_controls()
    _label(content, "PROPOSTA VISUAL  •  A identidade será consolidada após sua revisão.", "GalacticCaption")
    resized.connect(_layout)
    _layout()
    set_low_effects(low_effects)
    if not reduced_motion and not low_effects:
        shell.modulate.a = 0.0
        entry_tween = create_tween()
        entry_tween.tween_property(shell, "modulate:a", 1.0, Design.ENTER_SECONDS)
    else:
        shell.modulate = Color.WHITE

func _label(parent: Node, text: String, variant: String = "") -> Label:
    var label := Label.new()
    label.text = text
    label.theme_type_variation = variant
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    parent.add_child(label)
    return label

func _button(parent: Node, text: String, variant: String) -> Button:
    var button := Button.new()
    button.text = text
    button.theme_type_variation = variant
    button.custom_minimum_size.y = Design.TOUCH_HEIGHT
    button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    button.focus_mode = Control.FOCUS_ALL
    parent.add_child(button)
    return button

func _panel(parent: Node, accent: Color) -> VBoxContainer:
    var panel := GalacticPanel.new()
    panel.accent = accent
    panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    parent.add_child(panel)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 10)
    panel.add_child(column)
    return column

func _build_hero() -> void:
    var hero := _panel(content, Design.ION)
    _label(hero, "SINAL 01  /  FUNDAÇÃO GALÁCTICA", "GalacticCaption")
    hero_row = BoxContainer.new()
    hero_row.add_theme_constant_override("separation", 20)
    hero.add_child(hero_row)
    var words := VBoxContainer.new()
    words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    words.add_theme_constant_override("separation", 12)
    hero_row.add_child(words)
    var title := _label(words, "O LEGADO COMEÇA\nENTRE ESTRELAS.", "GalacticTitle")
    title.add_theme_font_size_override("font_size", 34)
    _label(words, "Linhas orbitais interrompidas, luz de navegação e metal profundo. Uma linguagem própria para explorar a galáxia.")
    var badge := _label(words, "PRÉVIA PARA REVISÃO", "GalacticCaption")
    badge.add_theme_color_override("font_color", Design.AMBER)
    var emblem := Emblem.new()
    emblem.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    hero_row.add_child(emblem)

func _swatch(title: String, description: String, color: Color) -> void:
    var box := _panel(cards, color)
    var label := _label(box, title, "GalacticCaption")
    label.add_theme_color_override("font_color", color)
    var strip := ColorRect.new()
    strip.custom_minimum_size.y = 4
    strip.color = color
    strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
    box.add_child(strip)
    _label(box, description)
    _label(box, "#" + color.to_html(false).to_upper(), "GalacticCaption")

func _build_controls() -> void:
    var box := _panel(content, Design.VIOLET)
    _label(box, "COMANDOS E ESTADOS", "GalacticCaption")
    var buttons := HFlowContainer.new()
    buttons.add_theme_constant_override("h_separation", 12)
    buttons.add_theme_constant_override("v_separation", 12)
    box.add_child(buttons)
    primary_button = _button(buttons, "PRIMÁRIO", "GalacticPrimaryButton")
    secondary_button = _button(buttons, "SECUNDÁRIO", "GalacticSecondaryButton")
    disabled_button = _button(buttons, "INDISPONÍVEL", "GalacticSecondaryButton")
    disabled_button.disabled = true
    var alert := _button(buttons, "ALERTA", "GalacticAlertButton")
    primary_button.pressed.connect(_show_feedback.bind("Primário selecionado.", Design.ION))
    secondary_button.pressed.connect(_show_feedback.bind("Secundário selecionado.", Design.TEXT))
    alert.pressed.connect(_show_feedback.bind("Estado de alerta — amostra visual.", Design.DANGER))
    feedback = _label(box, "Toque nos comandos ou navegue com Tab para comparar os estados.")
    feedback.custom_minimum_size.y = 28
    var progress := ProgressBar.new()
    progress.value = 72
    progress.show_percentage = false
    progress.custom_minimum_size.y = 12
    progress.mouse_filter = Control.MOUSE_FILTER_IGNORE
    box.add_child(progress)
    _label(box, "ESCUDO  /  AMOSTRA DE INDICADOR", "GalacticCaption")
    motion_toggle = CheckButton.new()
    motion_toggle.text = "REDUZIR MOVIMENTO"
    motion_toggle.custom_minimum_size.y = Design.TOUCH_HEIGHT
    motion_toggle.button_pressed = reduced_motion
    motion_toggle.toggled.connect(set_reduced_motion)
    box.add_child(motion_toggle)

func _show_feedback(text: String, color: Color) -> void:
    feedback.text = text
    feedback.add_theme_color_override("font_color", color)

func set_reduced_motion(value: bool) -> void:
    reduced_motion = value
    if background_material != null:
        background_material.set_shader_parameter("motion_strength", 0.0 if value else 1.0)
    if value and is_instance_valid(entry_tween):
        entry_tween.kill()
        shell.modulate = Color.WHITE

func set_low_effects(value: bool) -> void:
    low_effects = value
    if backdrop != null:
        backdrop.material = null if value else background_material
    set_reduced_motion(reduced_motion)
    if value and is_instance_valid(entry_tween):
        entry_tween.kill()
        shell.modulate = Color.WHITE

func _layout() -> void:
    if cards == null:
        return
    var narrow := size.x < 760.0
    cards.columns = 1 if narrow else 3
    hero_row.vertical = narrow
    background_material.set_shader_parameter("aspect_ratio", size.x / maxf(size.y, 1.0))

func request_close() -> void:
    var tree := get_tree()
    var standalone := tree != null and tree.current_scene == self
    closed.emit()
    if standalone:
        tree.change_scene_to_file("res://scenes/main.tscn")

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
        var viewport := get_viewport()
        request_close()
        viewport.set_input_as_handled()
