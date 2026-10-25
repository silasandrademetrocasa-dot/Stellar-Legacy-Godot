extends HFlowContainer
## ID-based tabs; no gameplay navigation or persistence.
signal tab_changed(id: String)
const Design = preload("res://scripts/ui/design/galactic_theme.gd")
var selected_id := ""
var buttons: Dictionary = {}
var _ids: Array[String] = []

func _ready() -> void:
    size_flags_horizontal = Control.SIZE_EXPAND_FILL
    add_theme_constant_override("h_separation", 8)
    add_theme_constant_override("v_separation", 8)

func set_tabs(records: Array, preferred: String = "") -> bool:
    var ids: Array[String] = []
    for record in records:
        if not (record is Dictionary):
            return false
        var id := str(record.get("id", ""))
        if id.is_empty() or ids.has(id):
            return false
        ids.append(id)
    var old := selected_id
    for child in get_children():
        remove_child(child)
        child.queue_free()
    buttons.clear()
    _ids = ids
    selected_id = ""
    for record in records:
        var id := str(record["id"])
        var button := Button.new()
        button.text = str(record.get("label", id))
        button.custom_minimum_size.y = Design.TOUCH_HEIGHT
        button.theme_type_variation = "GalacticTabButton"
        button.disabled = not bool(record.get("enabled", true))
        button.toggle_mode = true
        button.pressed.connect(_on_pressed.bind(id))
        button.gui_input.connect(_on_navigation.bind(id))
        add_child(button)
        buttons[id] = button
    var candidate := preferred if not preferred.is_empty() else old
    if not candidate.is_empty() and _enabled(candidate):
        select_tab(candidate)
    else:
        for id in _ids:
            if _enabled(id):
                select_tab(id)
                break
    if selected_id.is_empty() and not old.is_empty():
        tab_changed.emit("")
    return true

func _enabled(id: String) -> bool:
    return buttons.has(id) and not (buttons[id] as Button).disabled

func select_tab(id: String) -> bool:
    if not _enabled(id):
        return false
    if id == selected_id:
        (buttons[id] as Button).set_pressed_no_signal(true)
        return true
    selected_id = id
    for key in buttons:
        var button := buttons[key] as Button
        button.set_pressed_no_signal(key == id)
        button.theme_type_variation = "GalacticActiveTabButton" if key == id else "GalacticTabButton"
    tab_changed.emit(id)
    return true

func _on_pressed(id: String) -> void:
    select_tab(id)

func _on_navigation(event: InputEvent, from_id: String) -> void:
    if not (event is InputEventKey) or not event.pressed or event.echo:
        return
    var enabled: Array[String] = []
    for id in _ids:
        if _enabled(id):
            enabled.append(id)
    if enabled.is_empty():
        return
    var index := enabled.find(from_id)
    match event.keycode:
        KEY_LEFT: index = posmod(index - 1, enabled.size())
        KEY_RIGHT: index = posmod(index + 1, enabled.size())
        KEY_HOME: index = 0
        KEY_END: index = enabled.size() - 1
        _: return
    select_tab(enabled[index])
    (buttons[enabled[index]] as Button).grab_focus()
    accept_event()
