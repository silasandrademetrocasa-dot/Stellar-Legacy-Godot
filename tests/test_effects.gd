extends SceneTree
const PortalAnimation = preload("res://scripts/world/portal_animation.gd")
const Combat = preload("res://scripts/world/combat_world.gd")
var checks := 0
var failures := 0
func _initialize() -> void:
    call_deferred("run")
func check(ok: bool, message: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error(message)
func run() -> void:
    for path in ["portals/portal_normal", "portals/portal_pvp", "portals/portal_universe", "astral/portal_astral_aurora", "astral/portal_astral_nexus", "astral/portal_astral_eclipse"]:
        var model := load("res://assets/%s.glb" % path).instantiate() as Node3D
        root.add_child(model)
        var original_transform := model.transform
        var animation := PortalAnimation.new()
        animation.process_mode = Node.PROCESS_MODE_DISABLED
        model.add_child(animation)
        animation.setup(model, "MEDIO", Color.CYAN)
        check(not animation.rings.is_empty(), path + " rotating rings available")
        check(not animation.core_materials.is_empty(), path + " energetic core available")
        var before: Transform3D = animation.rings[0].transform
        animation._process(0.5)
        check(animation.rings[0].transform != before, path + " ring rotates")
        check(model.transform == original_transform, path + " frame pivot remains stable")
        var emission := animation.core_materials[0].emission_energy_multiplier
        animation._process(0.5)
        check(not is_equal_approx(emission, animation.core_materials[0].emission_energy_multiplier), path + " core pulses")
        animation.set_quality("BAIXO")
        check(animation.halo == null or not animation.halo.visible, path + " low quality FX budget")
        model.free()
    var combat := Combat.new()
    combat.process_mode = Node.PROCESS_MODE_DISABLED
    root.add_child(combat)
    var player := Node3D.new()
    root.add_child(player)
    combat.player_node = player
    combat.configure("1-1", [])
    var enemy = combat.enemies[0]
    enemy.position = Vector3(10, 0, 0)
    enemy.aggressive = true
    enemy.attack_clock = 0.0
    combat._process(0.01)
    check(enemy.muzzle_flash.visible, "NPC attack flash")
    check(not combat.effects.is_empty(), "NPC laser still renders")
    enemy.tick(0.3, player.position)
    check(not enemy.muzzle_flash.visible, "NPC attack flash expires")
    check(enemy.rotation.y != 0.0, "NPC aims toward player")
    for index in range(20):
        combat._spawn_explosion(Vector3(index, 0, 0))
    check(combat.bursts.size() == combat.MAX_BURSTS, "Explosion pool is bounded")
    var allocated: int = combat.effects_root.get_child_count()
    combat._process(0.6)
    check(combat.bursts.is_empty() and combat.burst_pool.size() == combat.MAX_BURSTS, "Explosions recycle")
    combat._spawn_explosion(Vector3.ZERO)
    check(combat.effects_root.get_child_count() == allocated, "Recycled explosion does not allocate mesh")
    combat.configure("4-1", [])
    check(combat.bursts.is_empty(), "Map changes clear active explosions")
    combat.set_quality("BAIXO")
    for index in range(20):
        combat._spawn_explosion(Vector3.ZERO)
    check(combat.bursts.size() == 2, "Low profile caps concurrent explosions")
    combat.free()
    player.free()
    print("EFFECTS: %d checks, %d failures" % [checks, failures])
    quit(1 if failures else 0)
