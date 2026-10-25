extends SceneTree
## Run with an isolated XDG_DATA_HOME; exercises the real main controller.
const Presentation = preload("res://scripts/world/model_presentation.gd")
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
    for portal in game.portals:
        check(game.ship_anchor.position.distance_to(portal["pos"]) > game.WARP_DISTANCE, "Spawn must not overlap portal")
    game._set_ship("AURORA")
    var box := Presentation.bounds(game.ship_visual)
    check(is_equal_approx(maxf(box.size.x, box.size.z), 3.05), "Aurora must fit 3.05 units")
    check(box.get_center().length() < 0.001, "Aurora must be centered on flight plane")
    check(box.size.y < 0.5, "Aurora height must use uniform authored proportions")
    check(game.engine_mounts.size() == 2, "Aurora must retain both engines")
    for mount in game.engine_mounts:
        check(mount.z < 0.0, "Engine mount must be behind +Z nose")
    var canopy: MeshInstance3D = game.ship_visual.find_child("*CANOPY_3D", true, false)
    check(canopy != null, "Cockpit mesh must be preserved")
    if canopy != null:
        var center: Vector3 = Presentation.relative_transform(canopy, game.ship_anchor) * canopy.get_aabb().get_center()
        check(center.z > 0.0, "Cockpit must face controller +Z")

    for goal in [Vector3(80, 0, 0), Vector3(-80, 0, 0), Vector3(0, 0, 80), Vector3(0, 0, -80)]:
        game.ship_anchor.position = Vector3.ZERO
        game.heading = 0.0
        game.travel_heading = 0.0
        game.speed = 0.0
        game.auto_fire_enabled = false
        game._set_destination(goal)
        for step in range(40):
            var before: Vector3 = game.ship_anchor.position
            game._process(1.0 / 60.0)
            var move: Vector3 = game.ship_anchor.position - before
            if move.length_squared() > 0.000001:
                check(game.ship_anchor.basis.z.dot(move.normalized()) > 0.999, "Navigation must follow nose while turning")
            check(absf(game.ship_anchor.position.y) < 0.001, "Flight stays on Y=0")

    # A target to the east must not cancel a northbound route or laser.
    var enemy = game.combat_world.enemies[0]
    enemy.position = Vector3(40, 0, 0)
    enemy.hp = 100000.0
    enemy.shield = 100000.0
    game.combat_world.select_enemy(enemy)
    game.ship_anchor.position = Vector3.ZERO
    game.heading = 0.0
    game.travel_heading = 0.0
    game.speed = 0.0
    game.auto_fire_enabled = true
    game._set_destination(Vector3(0, 0, 80))
    for step in range(30):
        game._process(1.0 / 60.0)
    check(absf(game.ship_anchor.position.x) < 0.001 and game.ship_anchor.position.z > 0.0, "Combat keeps independent travel")
    check(game.ship_anchor.basis.z.x > 0.9, "Hull aims at selected target")
    check(game.auto_fire_enabled and game.combat_world.get_selected_enemy() == enemy, "Route preserves fire and target")
    check(enemy.shield < 100000.0, "Combat still deals damage")
    check(game.afterburner.rotation.is_zero_approx(), "Thruster pivots must not orbit")
    game.free()
    print("AURORA: %d checks, %d failures" % [checks, failures])
    quit(1 if failures else 0)
