extends RefCounted
## Lightweight Pixel Art UI sprites, no imported mesh dependency.
const BASE = "res://assets/pixel/catalog/"

static func texture_path(source: String) -> String:
    if source.begins_with(BASE) and ResourceLoader.exists(source):
        return source
    if source.begins_with("res://assets/pixel/map_units/") and ResourceLoader.exists(source):
        return source
    if source.begins_with("res://assets/pixel/world/") and ResourceLoader.exists(source):
        return source
    var key: String = source.get_file().get_basename().to_lower().replace("_", "-")
    var group: String = source.to_lower()
    if group.contains("/ships/") or key.begins_with("sl-"):
        var ship_id: String = key.trim_prefix("sl-").trim_suffix("-final")
        return BASE + "ships/" + ship_id + ".png"
    if group.contains("/portals/") or group.contains("/astral/"):
        return "res://assets/pixel/world/" + key + ".png"
    if group.contains("/drones/"):
        return "res://assets/pixel/map_units/drones/" + key.replace("-", "_") + ".png"
    if group.contains("/aux/"):
        return "res://assets/pixel/map_units/aux/aux9.png"
    if group.contains("/relays/"):
        return "res://assets/pixel/world/relay_1.png"
    var mapping: Dictionary = {
        "arc-1":"laser_pulse", "arc-2":"laser_beam", "arc-3":"arc_weapon", "arc-4":"plasma_cannon",
        "arc-q":"gauss_cannon", "arc-p1":"particle_cannon", "vortex-x":"ion_cannon", "cataclismo":"disintegrator",
        "sg-1":"sg_1", "sg-2":"sg_2", "sg-3":"sg_3", "fs-01":"sg_1", "fs-02":"sg_2",
        "fs-03":"sg_3", "fs-04":"prism_shield", "vsh-0":"ion_barrier", "vsh-1":"reactive_shield",
        "vsh-2":"prism_shield", "vsh-3":"bastion_shield", "vsh-4":"supreme_deflector",
        "thr-1":"ion_1", "thr-2":"ion_2", "thr-3":"ion_3", "thr-4":"plasma_motor",
        "thr-5":"vector_motor", "thr-6":"impulse_motor", "reload-booster":"reload_booster",
        "auto-aim":"auto_aim", "nanobot-rep-2":"nanobot_rep_2"
    }
    if mapping.has(key):
        return BASE + "equipment/" + str(mapping[key]) + ".png"
    if key.contains("missile") or key.contains("cmt-") or key.contains("missil"):
        return BASE + "generic/missile.png"
    if key.contains("ammo") or key.contains("pls-") or key.contains("munic"):
        return BASE + "generic/ammo.png"
    if key.contains("esc") or key.contains("aeg") or key.contains("vsh") or key.contains("sg-"):
        return BASE + "generic/shield.png"
    if key.contains("motor") or key.contains("thr") or key.contains("eng"):
        return BASE + "generic/engine.png"
    if key.contains("laser") or key.contains("arc") or key.contains("weapons"):
        return BASE + "generic/weapon.png"
    return BASE + "generic/extra.png"

static func texture_for(source: String) -> Texture2D:
    var path: String = texture_path(source)
    if ResourceLoader.exists(path):
        return load(path) as Texture2D
    return load(BASE + "generic/extra.png") as Texture2D

static func create(pivot: Node3D, source: String, span: float = 5.0) -> Node3D:
    var art := Node3D.new()
    art.name = "PixelVitrine"
    var sprite := Sprite3D.new()
    sprite.name = "Art"
    sprite.texture = texture_for(source)
    sprite.pixel_size = span / 96.0
    sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    sprite.shaded = false
    sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
    sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
    sprite.no_depth_test = true
    art.add_child(sprite)
    pivot.add_child(art)
    return art
