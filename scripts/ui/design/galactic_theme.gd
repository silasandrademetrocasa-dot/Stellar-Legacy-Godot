extends RefCounted
## Approved foundation tokens; new component variants remain reviewable.
const DISPLAY_FONT = preload("res://assets/ui/design/fonts/Oxanium.ttf")
const BODY_FONT = preload("res://assets/ui/design/fonts/Rajdhani-Medium.ttf")
const VOID := Color("040811")
const PANEL := Color("0b1729")
const PANEL_RAISED := Color("11223a")
const ION := Color("33dced")
const AMBER := Color("ffcb76")
const VIOLET := Color("b8a2ff")
const TEXT := Color("e8f1ff")
const MUTED := Color("a0b4d0")
const DISABLED := Color("72869f")
const DANGER := Color("ff8990")
const BORDER := Color("304965")
const TOUCH_HEIGHT := 48.0
const SPACE_UNIT := 4
const ENTER_SECONDS := 0.18

static func panel_style(accent: Color = BORDER, raised: bool = false) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = PANEL_RAISED if raised else PANEL
    style.border_color = accent
    style.set_border_width_all(1)
    style.border_width_top = 2
    style.set_corner_radius_all(6)
    style.set_content_margin_all(20)
    return style

static func _button_style(fill: Color, edge: Color) -> StyleBoxFlat:
    var style := panel_style(edge)
    style.bg_color = fill
    style.set_content_margin_all(12)
    style.content_margin_left = 20
    style.content_margin_right = 20
    return style

static func _button_variant(theme: Theme, variant: String, accent: Color, solid: bool) -> void:
    theme.set_type_variation(variant, "Button")
    var alert := variant == "GalacticAlertButton"
    theme.set_stylebox("normal", variant, _button_style(accent if solid else PANEL_RAISED, accent if solid else (accent.darkened(0.4) if alert else BORDER)))
    theme.set_stylebox("hover", variant, _button_style(accent.lightened(0.12) if solid else Color("192e48"), accent))
    theme.set_stylebox("pressed", variant, _button_style(accent.darkened(0.15) if solid else Color("203d55"), accent))
    theme.set_stylebox("disabled", variant, _button_style(PANEL, BORDER.darkened(0.25)))
    var focus := _button_style(Color.TRANSPARENT, AMBER)
    focus.draw_center = false
    focus.set_border_width_all(2)
    focus.set_expand_margin_all(3)
    theme.set_stylebox("focus", variant, focus)
    for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
        theme.set_color(state, variant, VOID if solid else (accent if alert else TEXT))
    theme.set_color("font_disabled_color", variant, DISABLED)
    theme.set_font_size("font_size", variant, 18)

static func build() -> Theme:
    var theme := Theme.new()
    theme.default_font = BODY_FONT
    theme.default_font_size = 18
    theme.set_color("font_color", "Label", TEXT)
    theme.set_color("font_color", "CheckButton", TEXT)
    theme.set_color("font_focus_color", "CheckButton", TEXT)
    theme.set_type_variation("GalacticTitle", "Label")
    var display := FontVariation.new()
    display.base_font = DISPLAY_FONT
    display.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): 600.0}
    theme.set_font("font", "GalacticTitle", display)
    theme.set_font_size("font_size", "GalacticTitle", 32)
    theme.set_type_variation("GalacticCaption", "Label")
    theme.set_font("font", "GalacticCaption", display)
    theme.set_font_size("font_size", "GalacticCaption", 13)
    theme.set_color("font_color", "GalacticCaption", MUTED)
    theme.set_type_variation("GalacticPanel", "PanelContainer")
    theme.set_stylebox("panel", "GalacticPanel", panel_style())
    _button_variant(theme, "GalacticPrimaryButton", ION, true)
    _button_variant(theme, "GalacticSecondaryButton", ION, false)
    _button_variant(theme, "GalacticAlertButton", DANGER, false)
    for variant in ["GalacticTabButton", "GalacticActiveTabButton", "GalacticListButton", "GalacticSelectedListButton"]:
        _button_variant(theme, variant, ION, false)
    for variant in ["GalacticActiveTabButton", "GalacticSelectedListButton"]:
        theme.set_stylebox("normal", variant, _button_style(PANEL_RAISED, ION))
        theme.set_color("font_color", variant, ION)
    theme.set_stylebox("normal", "LineEdit", _button_style(VOID, BORDER))
    var field_focus := _button_style(Color.TRANSPARENT, AMBER)
    field_focus.draw_center = false
    field_focus.set_border_width_all(2)
    theme.set_stylebox("focus", "LineEdit", field_focus)
    theme.set_stylebox("read_only", "LineEdit", _button_style(PANEL, BORDER))
    theme.set_color("font_color", "LineEdit", TEXT)
    theme.set_color("font_uneditable_color", "LineEdit", DISABLED)
    theme.set_color("font_placeholder_color", "LineEdit", MUTED)
    theme.set_color("caret_color", "LineEdit", ION)
    theme.set_color("selection_color", "LineEdit", Color(ION, 0.22))
    theme.set_color("font_selected_color", "LineEdit", TEXT)
    theme.set_stylebox("focus", "CheckButton", theme.get_stylebox("focus", "GalacticSecondaryButton"))
    theme.set_stylebox("background", "ProgressBar", _button_style(VOID, BORDER))
    var fill := StyleBoxFlat.new()
    fill.bg_color = ION
    fill.set_corner_radius_all(3)
    theme.set_stylebox("fill", "ProgressBar", fill)
    return theme
