extends SceneTree
## Optional desktop Compatibility smoke test; requires an X11 display.
## Pass a directory after `--` to save review screenshots. Not an Android benchmark.
const Relay = preload("res://scripts/relays/relay_controller.gd")
var output_dir := ""
func _initialize() -> void:
    call_deferred("run")
func capture(label: String) -> void:
    await process_frame
    await RenderingServer.frame_post_draw
    print("RENDER ", label, " draw_calls=", root.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_DRAW_CALLS_IN_FRAME), " primitives=", root.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_PRIMITIVES_IN_FRAME))
    if not output_dir.is_empty():
        var screenshot := root.get_texture().get_image()
        var error := screenshot.save_png(output_dir.path_join(label + ".png"))
        if error != OK:
            push_error("Screenshot failed: " + label)
            quit(1)
func run() -> void:
    if DisplayServer.get_name() == "headless":
        push_error("test_rendering requires a real Compatibility display, not headless")
        quit(1)
        return
    if not OS.get_cmdline_user_args().is_empty():
        output_dir = OS.get_cmdline_user_args()[0]
        DirAccess.make_dir_recursive_absolute(output_dir)
    var game = load("res://scenes/main.tscn").instantiate()
    game.process_mode = Node.PROCESS_MODE_DISABLED
    root.add_child(game)
    game._set_ship("AURORA")
    game.speed = 14.0
    game._animate_engine(0.1)
    await capture("aurora-gameplay")
    game.ui_shell._open_modal("HANGAR")
    await capture("aurora-hangar")
    game.ui_shell._open_modal("LOJA")
    game.ui_shell.store_command._select_product(load("res://scripts/data/store_catalog.gd").find("ARC-1"))
    await capture("weapon-hq")
    game.ui_shell.close_modal()
    game.current_map = "4-1"
    game._rebuild_portals()
    game.relay_visual.set_state(Relay.RelayState.COMBAT)
    game.relay_visual._process(0.3)
    await capture("relay-combat")
    game.relay_visual.set_state(Relay.RelayState.SHIELD_BROKEN)
    game.relay_visual._process(0.3)
    await capture("relay-broken")
    game.relay_visual.set_state(Relay.RelayState.EVOLVING)
    game.relay_visual._process(0.3)
    game.combat_world._spawn_explosion(Vector3(5, 0, 0))
    await capture("relay-evolution")
    game.current_map = "A-AURORA"
    game._rebuild_portals()
    game.game_camera.position = Vector3(0, 15, 78)
    game.game_camera.look_at(Vector3(0, 0, 59))
    await capture("astral-portal")
    game.free()
    print("RENDERING: 7 Compatibility scenarios completed")
    quit()
