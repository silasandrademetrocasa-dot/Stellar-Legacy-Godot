extends RefCounted
## Stellar Legacy G0.7: progressao SOMENTE LOCAL para validar UX sem servidor.
## Nao representa carteira, perfil, inventario, creditos nem ranking reais.
const SAVE_PATH := "user://stellar_g07_pilot_offline.json"
const FORMAT_VERSION := 1
const MAX_LEVEL := 30
const MISSIONS := [
    {"code": "combat", "label": "Primeira patrulha", "goal": 5, "xp": 1600, "credits": 600},
    {"code": "loot", "label": "Colecionador estelar", "goal": 3, "xp": 1100, "credits": 450},
    {"code": "travel", "label": "Explorador galactico", "goal": 4, "xp": 900, "credits": 350},
    {"code": "ore", "label": "Minerador estelar", "goal": 12, "xp": 1400, "credits": 500},
]

var total_xp: int = 0
var credits: int = 0
var kills: int = 0
var boxes: int = 0
var ore_units: int = 0
var visited: Array[String] = []
var mission_claims: Dictionary = {}
var recent: Array[String] = []

func _init() -> void:
    _load()

func _load() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if not (parsed is Dictionary):
        return
    if int(parsed.get("version", 0)) != FORMAT_VERSION:
        return
    total_xp = clampi(int(parsed.get("xp", 0)), 0, 1000000000)
    credits = clampi(int(parsed.get("credits", 0)), 0, 1000000000)
    kills = clampi(int(parsed.get("kills", 0)), 0, 10000000)
    boxes = clampi(int(parsed.get("boxes", 0)), 0, 10000000)
    ore_units = clampi(int(parsed.get("ore_units", 0)), 0, 10000000)
    var loaded_visits: Variant = parsed.get("visited", [])
    if loaded_visits is Array:
        for item in loaded_visits:
            var map_id: String = str(item)
            if map_id.length() > 0 and map_id.length() <= 16 and not visited.has(map_id) and visited.size() < 80:
                visited.append(map_id)
    var claims: Variant = parsed.get("missions", {})
    if claims is Dictionary:
        for mission in MISSIONS:
            var code: String = str(mission["code"])
            if bool(claims.get(code, false)):
                mission_claims[code] = true
    var stored_events: Variant = parsed.get("recent", [])
    if stored_events is Array:
        for entry in stored_events:
            if recent.size() >= 7:
                break
            recent.append(str(entry).substr(0, 100))

func _save() -> void:
    var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return
    var payload: Dictionary = {
        "version": FORMAT_VERSION, "xp": total_xp, "credits": credits,
        "kills": kills, "boxes": boxes, "ore_units":ore_units, "visited": visited,
        "missions": mission_claims, "recent": recent
    }
    file.store_string(JSON.stringify(payload))

func _event(note: String) -> void:
    recent.push_front(note.substr(0, 100))
    while recent.size() > 7:
        recent.pop_back()

func level_info() -> Dictionary:
    var level: int = 1
    var remaining: int = total_xp
    var cost: int = 10000
    while level < MAX_LEVEL and remaining >= cost:
        remaining -= cost
        level += 1
        cost *= 2
    return {"level": level, "current": remaining, "required": cost if level < MAX_LEVEL else 0}

func mission_progress(code: String) -> int:
    match code:
        "combat": return kills
        "loot": return boxes
        "travel": return visited.size()
        "ore": return ore_units
    return 0

func _reward_missions() -> Array[String]:
    var newly_completed: Array[String] = []
    for mission in MISSIONS:
        var code: String = str(mission["code"])
        if not bool(mission_claims.get(code, false)) and mission_progress(code) >= int(mission["goal"]):
            mission_claims[code] = true
            total_xp += int(mission["xp"])
            credits += int(mission["credits"])
            newly_completed.append(str(mission["label"]))
            _event("Missao concluida: %s" % str(mission["label"]))
    return newly_completed

func visit_map(map_id: String) -> void:
    if map_id.is_empty() or visited.has(map_id):
        return
    visited.append(map_id)
    _event("Explorou mapa %s" % map_id)
    _reward_missions()
    _save()

func defeated_enemy(display_name: String, map_id: String) -> Dictionary:
    var xp_gain: int = 1200 if map_id.begins_with("U-") else 480
    var credit_gain: int = 700 if map_id.begins_with("U-") else 240
    kills += 1
    total_xp += xp_gain
    credits += credit_gain
    _event("%s derrotado: +%d XP / +%d cred." % [display_name, xp_gain, credit_gain])
    var completed: Array[String] = _reward_missions()
    _save()
    return {"xp": xp_gain, "credits": credit_gain, "completed": completed}

func mined_resource(name: String, amount: int) -> void:
    if amount <= 0:
        return
    ore_units += amount
    _event("Mineracao +%d %s" % [amount, name])
    _reward_missions()
    _save()

func record_box_only(kind: String) -> void:
    boxes += 1
    _event("%s coletada | registro local" % kind)
    _reward_missions()
    _save()

func collected_box() -> Dictionary:
    var xp_gain: int = 130
    var credit_gain: int = 95
    boxes += 1
    total_xp += xp_gain
    credits += credit_gain
    _event("Caixa recuperada: +%d XP / +%d cred." % [xp_gain, credit_gain])
    var completed: Array[String] = _reward_missions()
    _save()
    return {"xp": xp_gain, "credits": credit_gain, "completed": completed}

func snapshot() -> Dictionary:
    var level: Dictionary = level_info()
    var goals: Array[Dictionary] = []
    for mission in MISSIONS:
        var code: String = str(mission["code"])
        goals.append({"name": str(mission["label"]), "done": mission_progress(code),
            "goal": int(mission["goal"]), "claimed": bool(mission_claims.get(code, false))})
    return {"level": level["level"], "xp_current": level["current"], "xp_needed": level["required"],
        "xp_total": total_xp, "credits": credits, "kills": kills, "boxes": boxes, "ore_units": ore_units,
        "maps": visited.size(), "missions": goals, "recent": recent.duplicate()}
