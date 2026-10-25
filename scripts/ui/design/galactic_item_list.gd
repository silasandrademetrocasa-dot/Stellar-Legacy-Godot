extends VBoxContainer
## Filterable UI records; selection is local to the component.
signal selection_changed(id: String)
const Design = preload("res://scripts/ui/design/galactic_theme.gd")
var selected_id := ""
var search: LineEdit
var scroll: ScrollContainer
var rows: VBoxContainer
var empty_label: Label
var count_label: Label
var row_buttons: Dictionary = {}
var _items: Array[Dictionary] = []
var _visible_ids: Array[String] = []

func _ready() -> void:
    size_flags_horizontal = Control.SIZE_EXPAND_FILL
    add_theme_constant_override("separation", 10)
    search = LineEdit.new()
    search.placeholder_text = "Filtrar por nome ou descrição"
    search.custom_minimum_size.y = Design.TOUCH_HEIGHT
    search.max_length = 128
    search.text_changed.connect(_on_filter_changed)
    add_child(search)
    count_label = Label.new()
    count_label.theme_type_variation = "GalacticCaption"
    add_child(count_label)
    scroll = ScrollContainer.new()
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    scroll.custom_minimum_size.y = 232
    scroll.scroll_deadzone = 8
    scroll.follow_focus = true
    add_child(scroll)
    rows = VBoxContainer.new()
    rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    rows.add_theme_constant_override("separation", 8)
    scroll.add_child(rows)
    empty_label = Label.new()
    empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    empty_label.add_theme_color_override("font_color", Design.MUTED)
    add_child(empty_label)
    _render()

func set_items(records: Array) -> bool:
    var ids: Array[String] = []
    for item in records:
        if not (item is Dictionary):
            return false
        var id := str(item.get("id", ""))
        if id.is_empty() or ids.has(id):
            return false
        ids.append(id)
    var old := selected_id
    _items.assign(records.duplicate(true))
    if not ids.has(selected_id):
        selected_id = ""
    _render()
    if old != selected_id or not selected_id.is_empty():
        selection_changed.emit(selected_id)
    return true

func set_filter(text: String) -> void:
    search.text = text.substr(0, 128)
    _render()

func _on_filter_changed(_text: String) -> void:
    _render()

func get_visible_ids() -> Array[String]:
    return _visible_ids.duplicate()

func get_selected_item() -> Dictionary:
    for item in _items:
        if str(item["id"]) == selected_id:
            return item.duplicate(true)
    return {}

func select_item(id: String) -> bool:
    if not row_buttons.has(id) or (row_buttons[id] as Button).disabled:
        return false
    if selected_id == id:
        (row_buttons[id] as Button).set_pressed_no_signal(true)
        return true
    selected_id = id
    _apply_selection()
    selection_changed.emit(id)
    return true

func _select_pressed(id: String) -> void:
    select_item(id)

func _apply_selection() -> void:
    for id in row_buttons:
        var button := row_buttons[id] as Button
        button.set_pressed_no_signal(id == selected_id)
        button.theme_type_variation = "GalacticSelectedListButton" if id == selected_id else "GalacticListButton"

func _render() -> void:
    if rows == null:
        return
    for node in rows.get_children():
        rows.remove_child(node)
        node.queue_free()
    row_buttons.clear()
    _visible_ids.clear()
    var query := search.text.strip_edges().to_lower()
    for item in _items:
        var title := str(item.get("title", item["id"]))
        var detail := str(item.get("detail", ""))
        if not query.is_empty() and not (title + " " + detail).to_lower().contains(query):
            continue
        var id := str(item["id"])
        _visible_ids.append(id)
        var button := Button.new()
        button.text = title + ("\n" + detail if not detail.is_empty() else "")
        button.tooltip_text = title + "\n" + detail
        button.alignment = HORIZONTAL_ALIGNMENT_LEFT
        button.clip_text = true
        button.custom_minimum_size.y = 72
        button.toggle_mode = true
        button.disabled = not bool(item.get("enabled", true))
        button.pressed.connect(_select_pressed.bind(id))
        rows.add_child(button)
        row_buttons[id] = button
    count_label.text = "%d / %d REGISTROS" % [_visible_ids.size(), _items.size()]
    empty_label.visible = _visible_ids.is_empty()
    empty_label.text = "Nenhum resultado. Limpe a busca para ver os itens." if not query.is_empty() else "Nenhum item disponível."
    scroll.visible = not _visible_ids.is_empty()
    _apply_selection()
