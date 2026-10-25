extends SceneTree
const Relay = preload("res://scripts/relays/relay_controller.gd")
var failures := 0
var checks := 0
func _initialize() -> void:
    call_deferred("run")
func check(ok: bool, message: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error(message)
func run() -> void:
    var game = load("res://scenes/main.tscn").instantiate()
    game.process_mode = Node.PROCESS_MODE_DISABLED
    root.add_child(game)
    game.current_map = "4-1"
    game._rebuild_portals()
    await process_frame
    var relay := game.relay_visual as Relay
    check(relay != null, "PvP must instantiate approved relay controller")
    if relay == null:
        game.free()
        quit(1)
        return
    check(game.hub_store.relay_level("4-1") == relay.relay_level, "Saved level must match display")
    for profile in ["BAIXO", "MEDIO", "ALTO"]:
        game.set_graphics_quality(profile, false)
        await process_frame
        check(relay.use_mobile_lod == (profile != "ALTO"), profile + " LOD selection")
        var source: String = relay.model_root.get_child(0).scene_file_path
        check(source.ends_with("_lod.glb") == (profile != "ALTO"), profile + " actual GLB selection")
        check(relay.energy_light.visible == (profile != "BAIXO"), profile + " light budget")
        check(relay.energy_particles.emitting == (profile != "BAIXO"), profile + " particles budget")
    for state in [Relay.RelayState.IDLE, Relay.RelayState.COMBAT, Relay.RelayState.SHIELD_BROKEN, Relay.RelayState.EVOLVING]:
        relay.set_state(state)
        relay._process(0.1)
        check(relay.current_state == state, "Relay state accepted")
        check(relay.beam_mesh.visible == (state == Relay.RelayState.EVOLVING), "Evolution beam state")
        check(relay.shield_mesh.visible == (state != Relay.RelayState.IDLE), "Shield state")
    relay.set_state(Relay.RelayState.IDLE)
    game.hub_store.relay_owners["4-1"] = ""
    game.ship_anchor.position = Vector3.ZERO
    game.hub_store.relay_tick("4-1", game.faction, 0.0, 0.5)
    game._update_relay_color()
    check(relay.current_state == Relay.RelayState.COMBAT, "Capture starts combat animation")
    game.hub_store.relay_tick("4-1", game.faction, 0.0, 12.0)
    game._update_relay_color()
    check(relay.current_state == Relay.RelayState.IDLE, "Capture finishes in idle")
    game.ship_anchor.position = Vector3(30, 0, 0)
    game.upgrade_relay_local()
    check(game.hub_store.relay_level("4-1") == 1, "Upgrade requires proximity")
    game.ship_anchor.position = Vector3.ZERO
    for level in [2, 3]:
        game.upgrade_relay_local()
        check(relay.current_state == Relay.RelayState.EVOLVING, "Upgrade animates")
        var message: String = game.upgrade_relay_local()
        check(message == "Aguarde a evolucao do rele", "Repeated upgrade must not race saved level")
        relay.anim_player.advance(3.0)
        await process_frame
        check(relay.relay_level == level and game.hub_store.relay_level("4-1") == level, "Animation and saved level agree")
        check(relay.current_state == Relay.RelayState.IDLE, "Upgrade completes")
    check(game.simulate_relay_shield_hit().contains("simulado"), "HUD shield action exists")
    check(relay.current_state == Relay.RelayState.SHIELD_BROKEN, "HUD shield action animates")
    relay.recover_shield()
    relay.anim_player.advance(0.5)
    relay._process(0.0)
    check(float(relay.field_material.get_shader_parameter("strength")) > 0.1, "Recovery must visibly restore shield")
    relay.anim_player.advance(0.7)
    check(relay.current_state == Relay.RelayState.IDLE and not relay.shield_mesh.visible, "Shield recovery completes")
    # Timed recovery must safely ignore the old controller after changing maps.
    game.simulate_relay_shield_hit()
    game.current_map = "1-1"
    game._rebuild_portals()
    await process_frame
    await create_timer(1.6).timeout
    check(game.relay_visual == null, "Map change clears relay without stale callback")
    game.free()
    print("RELAYS: %d checks, %d failures" % [checks, failures])
    quit(1 if failures else 0)
