extends VBoxContainer
## Reusable UI validation. Submits a value through a signal; never saves it.
signal value_submitted(value: String)
const Design = preload("res://scripts/ui/design/galactic_theme.gd")
var label_text := "IDENTIFICADOR"
var min_chars := 3
var max_chars := 24
var hint := "Use de 3 a 24 caracteres."
var input: LineEdit
var submit_button: Button
var message: Label
var input_row: BoxContainer
var state := "neutral"
var _attempted := false

func _ready() -> void:
    size_flags_horizontal = Control.SIZE_EXPAND_FILL
    add_theme_constant_override("separation", 10)
    var caption := Label.new()
    caption.text = label_text
    caption.theme_type_variation = "GalacticCaption"
    add_child(caption)
    input_row = BoxContainer.new()
    input_row.add_theme_constant_override("separation", 10)
    add_child(input_row)
    input = LineEdit.new()
    input.placeholder_text = "Ex.: Esquadrão Órion"
    input.custom_minimum_size.y = Design.TOUCH_HEIGHT
    input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    input.max_length = 256
    input.text_changed.connect(_on_changed)
    input.text_submitted.connect(_on_submitted)
    input_row.add_child(input)
    submit_button = Button.new()
    submit_button.text = "CONFIRMAR"
    submit_button.theme_type_variation = "GalacticPrimaryButton"
    submit_button.custom_minimum_size.y = Design.TOUCH_HEIGHT
    submit_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    submit_button.pressed.connect(submit)
    input_row.add_child(submit_button)
    message = Label.new()
    message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    add_child(message)
    resized.connect(_layout)
    _layout()
    _set_state("neutral", hint)

func validate_value(text: String) -> Dictionary:
    var value := text.strip_edges()
    if value.length() < min_chars:
        return {"valid": false, "value": value, "message": "ERRO · Informe pelo menos %d caracteres." % min_chars}
    if value.length() > max_chars:
        return {"valid": false, "value": value, "message": "ERRO · Use no máximo %d caracteres." % max_chars}
    return {"valid": true, "value": value, "message": "Pronto para confirmar."}

func submit() -> bool:
    if not input.editable:
        return false
    _attempted = true
    var result := validate_value(input.text)
    if not bool(result["valid"]):
        _set_state("error", str(result["message"]))
        return false
    input.text = str(result["value"])
    _set_state("confirmed", "CONFIRMADO · Valor válido nesta prévia.")
    value_submitted.emit(input.text)
    return true

func _on_submitted(_text: String) -> void:
    submit()

func _on_changed(text: String) -> void:
    if not _attempted or not input.editable:
        return
    var result := validate_value(text)
    _set_state("ready" if bool(result["valid"]) else "error", str(result["message"]))

func set_value(text: String) -> void:
    input.text = text.substr(0, 256)
    _attempted = false
    _set_state("neutral" if input.editable else "disabled", hint if input.editable else "Campo indisponível.")

func set_editable(value: bool) -> void:
    input.editable = value
    submit_button.disabled = not value
    _attempted = false
    _set_state("neutral" if value else "disabled", hint if value else "Campo indisponível.")

func _set_state(next_state: String, text: String) -> void:
    state = next_state
    message.text = text
    var color := Design.DANGER if state == "error" else (Design.ION if state in ["ready", "confirmed"] else Design.MUTED)
    message.add_theme_color_override("font_color", color)
    var style := input.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
    style.border_color = Design.DANGER if state == "error" else (Design.ION if state in ["ready", "confirmed"] else Design.BORDER)
    input.add_theme_stylebox_override("normal", style)

func _layout() -> void:
    if input_row != null:
        input_row.vertical = size.x < 480
