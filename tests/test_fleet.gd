extends SceneTree
const Presentation = preload("res://scripts/world/model_presentation.gd")
const Ships = preload("res://scripts/world/ship_presentation.gd")
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
    var star_mesh: Mesh = game.starfield.multimesh.mesh
    var star_triangles: int = star_mesh.get_faces().size() / 3
    check(star_triangles <= 100, "Subpixel star geometry budget")
    check(game.starfield.multimesh.instance_count == 720, "Star distribution preserved")
    print("STARFIELD: ", star_triangles, " triangles per star x 720 instances")
    check(game.support_fleet.aux_model == null and game.support_fleet.drone_models.is_empty(), "Fresh inventory must not load unequipped HQ support")
    check(game.ui_shell.hangar_premium.hero_model == null and game.ui_shell.store_command.item_mesh == null, "Hidden setup must not load HQ previews")
    for ship_id in game.SHIP_IDS:
        game._set_ship(ship_id)
        var visual: Node3D = game.ship_visual
        var box := Presentation.bounds(visual)
        check(absf(maxf(box.size.x, box.size.z) - Ships.span(ship_id)) < 0.001, ship_id + " scene span")
        check(box.get_center().length() < 0.001, ship_id + " pivot centered")
        check(box.size.y < 0.65, ship_id + " uniform proportional height")
        check(box.position.x < 0 and box.end.x > 0, ship_id + " both wing sides preserved")
        var canopy := visual.find_child("*CANOPY_3D", true, false) as MeshInstance3D
        check(canopy != null, ship_id + " cockpit preserved")
        if canopy != null:
            var center: Vector3 = Presentation.relative_transform(canopy, visual) * canopy.get_aabb().get_center()
            check(center.z > 0.0 and center.y > 0.0, ship_id + " cockpit front and dorsal")
        check(game.engine_mounts.size() == 2, ship_id + " two engine mounts")
        for mount in game.engine_mounts:
            check(mount.z < 0.0, ship_id + " aft thruster")
        # Imported nodes retain identity, geometry and original PBR references.
        var imported: Node3D = visual.get_node("ModelMount").get_child(0)
        var original: Node3D = load("res://assets/ships/SL_%s_FINAL.glb" % ship_id).instantiate()
        var before := original.find_children("*", "MeshInstance3D", true, false)
        var after := imported.find_children("*", "MeshInstance3D", true, false)
        check(before.size() == after.size(), ship_id + " original mesh count")
        for index in range(before.size()):
            check(before[index].mesh == after[index].mesh, ship_id + " original mesh resource")
            check(before[index].transform == after[index].transform, ship_id + " original mesh transform")
            for surface in range(before[index].mesh.get_surface_count()):
                check(before[index].mesh.surface_get_material(surface) == after[index].mesh.surface_get_material(surface), ship_id + " original PBR material")
        original.free()
        # Real controller reaches destinations after a turn, stays planar and stops.
        for goal in [Vector3(35, 0, 0), Vector3(-35, 0, 0), Vector3(0, 0, -35)]:
            game.ship_anchor.position = Vector3.ZERO
            game.heading = 0.0
            game.travel_heading = 0.0
            game.speed = 0.0
            game._set_destination(goal)
            for step in range(600):
                var prior: Vector3 = game.ship_anchor.position
                game._process(1.0 / 60.0)
                var move: Vector3 = game.ship_anchor.position - prior
                if move.length_squared() > 0.000001:
                    check(game.ship_anchor.basis.z.dot(move.normalized()) > 0.999, ship_id + " nose follows displacement")
                if not game.destination_active:
                    break
            check(not game.destination_active and game.speed == 0.0, ship_id + " stops at destination")
            check(game.ship_anchor.position.distance_to(goal) <= game.ARRIVAL_DISTANCE + 0.01, ship_id + " arrival distance")
            check(absf(game.ship_anchor.position.y) < 0.001, ship_id + " flight plane")
        await process_frame
    # Previews reuse the same complete assets and release them when changing menus.
    for page in ["HANGAR", "EQUIPAMENTOS", "LOJA", "PREMIUM", "RELES", "CONFIG"]:
        game.ui_shell._open_modal(page)
        await process_frame
        if page == "HANGAR":
            for ship_id in game.SHIP_IDS:
                game.ui_shell.hangar_premium._set_preview_ship(ship_id)
                check(Presentation.bounds(game.ui_shell.hangar_premium.hero_model).get_center().length() < 0.001, ship_id + " centered hangar")
                await process_frame
        game.ui_shell.close_modal()
        await process_frame
        check(game.ui_shell.hangar_premium.hero_model == null and game.ui_shell.store_command.item_mesh == null and game.ui_shell.equipment_command.ship_mesh == null, page + " releases hidden GLBs")
    game.free()
    print("FLEET: %d checks, %d failures" % [checks, failures])
    quit(1 if failures else 0)
