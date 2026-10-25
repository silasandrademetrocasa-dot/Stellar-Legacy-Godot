extends Node3D
## G0.17: minérios e caixas bônus 3D locais, inspirados nas regras do Stellar Legacy Web.
## Reaparecimento persistido por mapa; no modo offline o cliente e dono da simulacao.

signal ore_collected(resource_name: String, amount: int)
signal bonus_collected(reward: Dictionary)

const SAVE_PATH: String = "user://stellar_g017_resources_demo.json"
const BONUS_NORMAL: int = 20
const BONUS_PVP: int = 30
const BONUS_MIN_WAIT: float = 40.0
const BONUS_MAX_WAIT: float = 70.0
const ORE_MIN_WAIT: float = 5.0
const ORE_MAX_WAIT: float = 12.0
const COLLECT_RADIUS: float = 6.5
const MODELS: Dictionary = {
    "Ferron":"res://assets/resources/minerio_plasma.glb",
    "Cryon":"res://assets/resources/minerio_ciano.glb",
    "Virel":"res://assets/resources/minerio_violeta.glb",
    "Ferrite":"res://assets/resources/minerio_plasma.glb",
    "Duracite":"res://assets/resources/minerio_esmeralda.glb",
    "Solarium":"res://assets/resources/minerio_ouro.glb"
}
const BONUS_REWARDS: Array[Dictionary] = [
    {"kind":"ammo", "name":"PLS-1", "min":15, "max":100},
    {"kind":"ammo", "name":"PLS-2", "min":15, "max":75},
    {"kind":"ammo", "name":"PLS-3", "min":15, "max":50},
    {"kind":"ammo", "name":"SIP-2", "min":15, "max":75},
    {"kind":"credits", "name":"Créditos", "min":100, "max":10000},
    {"kind":"stellarium", "name":"Stellarium", "min":1, "max":200},
    {"kind":"dust", "name":"Poeira Stellar", "min":1, "max":2}
]

var map_states: Dictionary = {}
var current_map: String = ""
var current_state: Dictionary = {}
var root: Node3D
var node_by_id: Dictionary = {}
var scene_cache: Dictionary = {}
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var tick_clock: float = 0.0
var player_node: Node3D
var graphics_quality: String = "MEDIO"
var bonus_goal: int = 0
var ore_goal: int = 0
var portal_avoid: Array[Vector3] = []

func _ready() -> void:
    rng.randomize()
    root = Node3D.new()
    root.name = "Minerios_E_BoxBonus_3D"
    add_child(root)
    _load_state()

func _load_state() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var f: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if f == null:
        return
    var payload: Variant = JSON.parse_string(f.get_as_text())
    if payload is Dictionary:
        var maps: Variant = payload.get("maps", {})
        if maps is Dictionary:
            map_states = maps

func _save_state() -> void:
    if current_map != "":
        map_states[current_map] = current_state
    var f: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if f != null:
        f.store_string(JSON.stringify({"version":1, "maps":map_states}))

func _bonus_target(map_id: String) -> int:
    if map_id.begins_with("A-"):
        return 0
    if map_id.begins_with("4-"):
        return BONUS_PVP
    if map_id.begins_with("U-"):
        return 0
    return BONUS_NORMAL

func _ore_target(map_id: String) -> int:
    if map_id.begins_with("A-") or map_id.begins_with("4-") or map_id.begins_with("U-"):
        return 0
    # Jogo web usa mais nodes porque seus setores sao muito maiores.
    # Aqui mantemos o mesmo ciclo de coleta, limitado a 10-14 GLBs HQ no Android.
    var tier: int = _tier(map_id)
    return mini(14, 9 + tier)

func _tier(map_id: String) -> int:
    var parts: PackedStringArray = map_id.split("-")
    return clampi(int(parts[1]), 1, 8) if parts.size() >= 2 else 1

func _types_for_map(map_id: String) -> Array:
    if _tier(map_id) == 1:
        return ["Ferron", "Cryon"]
    if _tier(map_id) >= 7:
        return ["Ferron", "Ferron", "Cryon", "Cryon", "Virel", "Duracite", "Solarium"]
    if _tier(map_id) >= 5:
        return ["Ferron", "Ferron", "Cryon", "Cryon", "Virel", "Duracite"]
    if _tier(map_id) >= 2:
        return ["Ferron", "Cryon", "Virel"]
    return ["Ferron"]

func configure(map_id: String, portals: Array[Vector3]) -> void:
    _save_state()
    for old in root.get_children():
        old.free()
    node_by_id.clear()
    current_map = map_id
    portal_avoid = portals.duplicate()
    bonus_goal = _bonus_target(map_id)
    ore_goal = _ore_target(map_id)
    var restored: Variant = map_states.get(map_id, {})
    if restored is Dictionary and restored.has("bonus") and restored.has("ores"):
        current_state = restored
    else:
        current_state = {"bonus":[], "ores":[], "bonus_pending":[], "ore_pending":[], "counter":0}
    _replenish()
    _refresh_visible()
    _save_state()

func _next_id(prefix: String) -> String:
    current_state["counter"] = int(current_state.get("counter", 0)) + 1
    return "%s_%s_%d" % [prefix, current_map, int(current_state["counter"])]

func _where() -> Array:
    for attempt in range(60):
        var x: float = rng.randf_range(-109.0, 109.0)
        var z: float = rng.randf_range(-79.0, 79.0)
        var point: Vector3 = Vector3(x, 0.0, z)
        if point.length() < 19.0:
            continue
        if current_map.ends_with("-1") and point.distance_to(Vector3(0.0, 0.0, 44.0)) < 20.0:
            continue
        var safe: bool = true
        for portal in portal_avoid:
            if point.distance_to(portal) < 17.0:
                safe = false
                break
        if safe:
            return [x, z]
    return [rng.randf_range(-100.0, -80.0), rng.randf_range(-70.0, 70.0)]

func _spawn_bonus() -> void:
    var row: Dictionary = {"id":_next_id("bonus"), "pos":_where()}
    var array: Array = current_state["bonus"]
    array.append(row)

func _spawn_ore(type_name: String = "") -> void:
    var types: Array = _types_for_map(current_map)
    var name: String = type_name if types.has(type_name) else types[rng.randi_range(0, types.size() - 1)]
    var yield_count: int = clampi(_tier(current_map), 1, 5)
    var row: Dictionary = {"id":_next_id("ore"), "type":name,
        "amount":yield_count, "pos":_where()}
    var array: Array = current_state["ores"]
    array.append(row)

func _replenish() -> void:
    var prior: String = JSON.stringify(current_state)
    var now: float = Time.get_unix_time_from_system()
    var bonuses: Array = current_state["bonus"]
    var bonus_pending: Array = current_state["bonus_pending"]
    while bonuses.size() > bonus_goal:
        bonuses.pop_back()
    for i in range(bonus_pending.size() - 1, -1, -1):
        if float(bonus_pending[i]) <= now:
            if bonuses.size() < bonus_goal:
                _spawn_bonus()
            bonus_pending.remove_at(i)
    while bonuses.size() + bonus_pending.size() < bonus_goal:
        _spawn_bonus()
    var ores: Array = current_state["ores"]
    var ore_pending: Array = current_state["ore_pending"]
    while ores.size() > ore_goal:
        ores.pop_back()
    for i in range(ore_pending.size() - 1, -1, -1):
        var row: Variant = ore_pending[i]
        if row is Dictionary and float(row.get("at", 0.0)) <= now:
            if ores.size() < ore_goal:
                _spawn_ore(str(row.get("type", "")))
            ore_pending.remove_at(i)
    while ores.size() + ore_pending.size() < ore_goal:
        _spawn_ore()
    if JSON.stringify(current_state) != prior:
        _save_state()

func _scene(path: String) -> PackedScene:
    if scene_cache.has(path):
        return scene_cache[path] as PackedScene
    var asset: PackedScene = load(path) as PackedScene
    if asset != null:
        scene_cache[path] = asset
    return asset

func _node_from_row(row: Dictionary, kind: String) -> void:
    var path: String = "res://assets/loot/box_bonus.glb" if kind == "bonus" else str(MODELS.get(str(row.get("type", "")), ""))
    if path == "":
        return
    var asset: PackedScene = _scene(path)
    if asset == null:
        return
    var body: Node3D = asset.instantiate() as Node3D
    if body == null:
        return
    var coords: Array = row.get("pos", [0.0,0.0])
    body.position = Vector3(float(coords[0]), 0.4 if kind == "bonus" else -0.55, float(coords[1]))
    body.scale = Vector3.ONE * (0.80 if kind == "bonus" else 0.90)
    body.rotation.y = rng.randf_range(0.0, TAU)
    body.set_meta("resource_kind", kind)
    body.set_meta("resource_id", str(row["id"]))
    root.add_child(body)
    var plate: Label3D = Label3D.new()
    plate.text = "BOX BONUS" if kind == "bonus" else str(row.get("type", "MINERIO")).to_upper()
    plate.font_size = 30
    plate.pixel_size = 0.009
    plate.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    plate.no_depth_test = false
    plate.position = Vector3(0.0, 2.5 if kind == "ore" else 1.6, 0.0)
    plate.modulate = Color(1.0, 0.83, 0.38) if kind == "bonus" else Color(0.54, 0.92, 1.0)
    body.add_child(plate)
    node_by_id[str(row["id"])] = body

func set_quality(profile: String) -> void:
    if profile in ["BAIXO", "MEDIO", "ALTO"]:
        graphics_quality = profile
        _refresh_visible()

func _refresh_visible() -> void:
    if current_map == "" or root == null:
        return
    var radius: float = 46.0 if graphics_quality == "BAIXO" else (66.0 if graphics_quality == "MEDIO" else 93.0)
    var center: Vector3 = player_node.global_position if player_node != null else Vector3.ZERO
    var desired: Dictionary = {}
    for category in ["bonus", "ores"]:
        var kind: String = "bonus" if category == "bonus" else "ore"
        for row in current_state.get(category, []):
            if not (row is Dictionary):
                continue
            var id: String = str(row["id"])
            if _world_pos(row).distance_to(center) <= radius:
                desired[id] = true
                if not node_by_id.has(id):
                    _node_from_row(row, kind)
    for id in node_by_id.keys():
        if desired.has(id):
            continue
        var body: Node3D = node_by_id[id]
        if body != null and is_instance_valid(body):
            body.queue_free()
        node_by_id.erase(id)

func _process(delta: float) -> void:
    if current_map == "":
        return
    tick_clock -= delta
    for id in node_by_id.keys():
        var body: Node3D = node_by_id[id]
        if is_instance_valid(body):
            body.rotation.y += delta * (0.45 if str(body.get_meta("resource_kind")) == "bonus" else 0.14)
    if tick_clock <= 0.0:
        tick_clock = 0.8
        _replenish()
        _refresh_visible()

func _world_pos(row: Dictionary) -> Vector3:
    var coords: Array = row.get("pos", [0.0, 0.0])
    return Vector3(float(coords[0]), 0.0, float(coords[1]))

func ore_positions() -> Array[Vector3]:
    var result: Array[Vector3] = []
    for row in current_state.get("ores", []):
        if row is Dictionary:
            result.append(_world_pos(row))
    return result

func bonus_positions() -> Array[Vector3]:
    var result: Array[Vector3] = []
    for row in current_state.get("bonus", []):
        if row is Dictionary:
            result.append(_world_pos(row))
    return result

func at_screen(pixel: Vector2, camera: Camera3D) -> Dictionary:
    var closest: Dictionary = {}
    var best: float = 43.0
    for key in ["ores", "bonus"]:
        for row in current_state.get(key, []):
            if not (row is Dictionary):
                continue
            var pos: Vector3 = _world_pos(row)
            if camera.is_position_behind(pos + Vector3.UP):
                continue
            var pixels: float = camera.unproject_position(pos + Vector3.UP).distance_to(pixel)
            if pixels < best:
                best = pixels
                closest = {"position":pos, "kind":key, "id":str(row["id"])}
    return closest

func collect_nearby(player_pos: Vector3, cargo, ship_name: String, equipment) -> void:
    if current_map == "":
        return
    var fitted_modules: Array = equipment.equipped_modules() if equipment != null else []
    var has_aux: bool = equipment != null and equipment.fitted_aux == "AUX-9"
    var ore_radius: float = 15.0 if has_aux and fitted_modules.has("Coletor de Minérios") else COLLECT_RADIUS
    var bonus_radius: float = 15.0 if has_aux and fitted_modules.has("Coletor de Cargas") else COLLECT_RADIUS
    var ores: Array = current_state["ores"]
    for i in range(ores.size() - 1, -1, -1):
        var row: Dictionary = ores[i]
        if _world_pos(row).distance_to(player_pos) > ore_radius:
            continue
        var type_name: String = str(row["type"])
        var collected: int = cargo.add_resource(type_name, int(row["amount"]), ship_name, equipment)
        if collected <= 0:
            continue
        row["amount"] = int(row["amount"]) - collected
        ore_collected.emit(type_name, collected)
        if int(row["amount"]) <= 0:
            var node: Node3D = node_by_id.get(str(row["id"])) as Node3D
            if node != null and is_instance_valid(node):
                node.queue_free()
            node_by_id.erase(str(row["id"]))
            ores.remove_at(i)
            var queue: Array = current_state["ore_pending"]
            queue.append({"type":type_name,"at":Time.get_unix_time_from_system() + rng.randf_range(ORE_MIN_WAIT, ORE_MAX_WAIT)})
            cargo.mined_nodes += 1
            cargo._save()
        _save_state()
    var boxes: Array = current_state["bonus"]
    for i in range(boxes.size() - 1, -1, -1):
        var box: Dictionary = boxes[i]
        if _world_pos(box).distance_to(player_pos) > bonus_radius:
            continue
        var body: Node3D = node_by_id.get(str(box["id"])) as Node3D
        if body != null and is_instance_valid(body):
            body.queue_free()
        node_by_id.erase(str(box["id"]))
        boxes.remove_at(i)
        var pending: Array = current_state["bonus_pending"]
        pending.append(Time.get_unix_time_from_system() + rng.randf_range(BONUS_MIN_WAIT, BONUS_MAX_WAIT))
        var kind: Dictionary = BONUS_REWARDS[rng.randi_range(0, BONUS_REWARDS.size() - 1)]
        var reward: Dictionary = {"kind":str(kind["kind"]), "name":str(kind["name"]),
            "amount":rng.randi_range(int(kind["min"]), int(kind["max"]))}
        cargo.bonus_collected += 1
        cargo._save()
        _save_state()
        bonus_collected.emit(reward)
