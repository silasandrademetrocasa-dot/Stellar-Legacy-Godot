extends SceneTree
const Store = preload("res://scripts/data/store_catalog.gd")
const Equipment = preload("res://scripts/data/equipment_catalog.gd")
const WeaponArt = preload("res://scripts/data/weapon_art.gd")
var failures := 0
var checks := 0
var model_count := 0
func _initialize() -> void:
    call_deferred("run")
func check(ok: bool, message: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error(message)
func inspect_directory(path: String) -> void:
    for file in DirAccess.get_files_at(path):
        if not file.ends_with(".glb"):
            continue
        model_count += 1
        var packed := load(path.path_join(file)) as PackedScene
        check(packed != null, "Import failed: " + file)
        if packed == null:
            continue
        var model := packed.instantiate() as Node3D
        check(model != null, "Node3D missing: " + file)
        if model == null:
            continue
        var meshes := model.find_children("*", "MeshInstance3D", true, false)
        check(not meshes.is_empty(), "Meshes missing: " + file)
        for child in meshes:
            var mesh := child as MeshInstance3D
            for surface in range(mesh.mesh.get_surface_count()):
                check(mesh.mesh.surface_get_material(surface) != null, "Material missing: " + file + "/" + mesh.name)
        model.free()
    for directory in DirAccess.get_directories_at(path):
        inspect_directory(path.path_join(directory))
func run() -> void:
    inspect_directory("res://assets")
    check(model_count == 147, "Expected 139 originals plus 8 recovered HQ weapons")
    for category in Store.CATEGORIES:
        for product in Store.all_in(category):
            check(ResourceLoader.exists(str(product["path"])), "Store path: " + str(product["name"]))
    for item in Equipment.ITEMS:
        check(ResourceLoader.exists(Equipment.model_path(str(item["name"]))), "Equipment path: " + str(item["name"]))
    for weapon in WeaponArt.MODELS:
        check(Store.find(weapon)["path"] == WeaponArt.model_for(weapon), weapon + " HQ store mapping")
        check(ResourceLoader.exists(Equipment.thumbnail_path(weapon)), weapon + " recovered thumbnail")
        # Recovering artwork must not rewrite prices or unlock concept weapons.
        for original in Store.PRODUCTS:
            if original["name"] == weapon:
                var visible := Store.find(weapon).duplicate()
                visible["path"] = original["path"]
                check(visible == original, weapon + " original gameplay metadata preserved")
    print("ASSETS: %d models, %d checks, %d failures" % [model_count, checks, failures])
    quit(1 if failures else 0)
