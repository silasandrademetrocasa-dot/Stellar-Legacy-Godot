extends SceneTree
const Design = preload("res://scripts/ui/design/galactic_theme.gd")
const PREVIEW = preload("res://scenes/ui/design_system_preview.tscn")
var checks := 0
var failures := 0
func _initialize() -> void:
    call_deferred("run")
func check(ok: bool, message: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error(message)
func luminance(color: Color) -> float:
    var linear := color.srgb_to_linear()
    return linear.r * 0.2126 + linear.g * 0.7152 + linear.b * 0.0722
func contrast(a: Color, b: Color) -> float:
    return (maxf(luminance(a), luminance(b)) + 0.05) / (minf(luminance(a), luminance(b)) + 0.05)
func click(viewport: Viewport, button: Button) -> void:
    for pressed in [true, false]:
        var event := InputEventMouseButton.new()
        event.position = button.get_global_rect().get_center()
        event.button_index = MOUSE_BUTTON_LEFT
        event.pressed = pressed
        viewport.push_input(event, true)
    await process_frame
func run() -> void:
    for text in [Design.TEXT, Design.MUTED, Design.ION, Design.AMBER, Design.VIOLET, Design.DANGER]:
        check(contrast(text, Design.PANEL) >= 4.5, "Text on opaque panel contrast >= 4.5")
    check(contrast(Design.VOID, Design.ION) >= 4.5, "Primary label contrast >= 4.5")
    for dimensions in [Vector2i(960, 540), Vector2i(640, 360), Vector2i(360, 740), Vector2i(1280, 720)]:
        var viewport := SubViewport.new()
        viewport.size = dimensions
        root.add_child(viewport)
        var preview = PREVIEW.instantiate()
        preview.reduced_motion = true
        viewport.add_child(preview)
        for frame in range(5):
            await process_frame
        check(preview.size.is_equal_approx(Vector2(dimensions)), "Preview fills test viewport")
        check(preview.cards.columns == (1 if dimensions.x < 760 else 3), "Responsive palette columns")
        check(preview.shell.modulate.a == 1.0, "Reduced motion skips entry fade")
        for node in preview.find_children("*", "Control", true, false):
            var control := node as Control
            check(control.size.x <= float(dimensions.x) + 1, "Control fits viewport width: " + control.name)
            if node is Button:
                check(control.size.y >= 48.0, "Button meets logical touch height: " + control.name)
        var primary: Button = preview.primary_button
        check(primary.get_theme_font("font") == Design.BODY_FONT, "Body font local and reusable")
        var focus: StyleBoxFlat = primary.get_theme_stylebox("focus")
        check(focus.border_color == Design.AMBER and not focus.draw_center, "Focus has independent visible outline")
        preview.scroll.scroll_vertical = 100000
        await process_frame
        primary.grab_focus()
        await process_frame
        check(viewport.gui_get_focus_owner() == primary, "Keyboard focus reaches primary action")
        await click(viewport, primary)
        check(preview.feedback.text == "Primário selecionado.", "Pointer action changes preview feedback")
        var feedback: String = preview.feedback.text
        await click(viewport, preview.disabled_button)
        check(preview.feedback.text == feedback, "Disabled control does not act")
        preview.set_reduced_motion(false)
        check(float(preview.background_material.get_shader_parameter("motion_strength")) == 1.0, "Motion can be enabled")
        preview.motion_toggle.button_pressed = true
        preview.motion_toggle.toggled.emit(true)
        check(float(preview.background_material.get_shader_parameter("motion_strength")) == 0.0, "Reduced motion freezes shader")
        preview.set_low_effects(true)
        check(preview.backdrop.material == null, "Low graphics uses solid background")
        preview.set_low_effects(false)
        check(float(preview.background_material.get_shader_parameter("motion_strength")) == 0.0, "Quality switch preserves motion preference")
        viewport.free()
    var game = load("res://scenes/main.tscn").instantiate()
    game.process_mode = Node.PROCESS_MODE_DISABLED
    root.add_child(game)
    var profile := FileAccess.get_file_as_bytes(game.SAVE_PATH)
    var credits: int = game.wallet.credits
    var equipment: Array = game.equipment_state.configurations.duplicate(true)
    game.ui_shell._open_modal("CONFIG")
    check(game.ui_shell.design_preview == null, "Preview loads only on request")
    for pass_index in range(3):
        game.ui_shell._open_design_preview()
        check(game.ui_shell.modal_open(), "Game navigation remains blocked by modal")
        game.ui_shell.design_preview.set_reduced_motion(true)
        game.ui_shell.design_preview.return_button.pressed.emit()
        await process_frame
        check(game.ui_shell.design_preview == null and game.ui_shell.modal_kind == "CONFIG", "Back releases preview and restores settings")
    game.ui_shell._open_design_preview()
    game.ui_shell.close_modal()
    await process_frame
    check(game.ui_shell.design_preview == null and not game.ui_shell.modal_open(), "Closing modal releases preview")
    check(FileAccess.get_file_as_bytes(game.SAVE_PATH) == profile, "Preview leaves saved profile untouched")
    check(game.wallet.credits == credits and game.equipment_state.configurations == equipment, "Preview leaves economy and loadout untouched")
    game.free()
    print("DESIGN SYSTEM: %d checks, %d failures" % [checks, failures])
    quit(1 if failures else 0)
