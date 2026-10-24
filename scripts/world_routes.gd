extends RefCounted
## Rotas CANONICAS espelhadas de portal-layout-v461.js (cliente web V64).
## Preview offline: NAO concede acesso no servidor; o servidor prevalecera.

const FACTIONS := ["1", "2", "3"]
const FACTION_NAMES := {"1": "TERRA", "2": "MARTE", "3": "JUPITER"}
const BOUNDS := Vector2(120.0, 90.0)
const SLOTS := {
    "TL": Vector2(-0.89, -0.83),
    "TR": Vector2(0.89, -0.83),
    "BL": Vector2(-0.89, 0.83),
    "BR": Vector2(0.89, 0.83),
    "CENTER": Vector2.ZERO,
}
const PVP_SLOTS := {
    "4-1": {"1-1": "TL", "4-2": "TR", "4-3": "BR"},
    "4-2": {"2-1": "TR", "4-1": "BL", "4-3": "BR"},
    "4-3": {"3-1": "BR", "4-1": "BL", "4-2": "TL"},
}

static func valid_map(map_id: String) -> bool:
    if map_id in ["U-1", "U-2", "U-3", "4-1", "4-2", "4-3"]:
        return true
    var parts := map_id.split("-")
    if parts.size() != 2 or not (parts[0] in FACTIONS):
        return false
    return parts[1].is_valid_int() and int(parts[1]) >= 1 and int(parts[1]) <= 8

static func neighbors(map_id: String, faction: String) -> Array[String]:
    var result: Array[String] = []
    if map_id.begins_with("U-"):
        match map_id:
            "U-1":
                result.append("%s-8" % faction)
                result.append("U-2")
            "U-2":
                result.append_array(["U-1", "U-3"])
            "U-3":
                result.append("U-2")
        return result
    if map_id.begins_with("4-"):
        match map_id:
            "4-1": result.append_array(["1-1", "4-2", "4-3"])
            "4-2": result.append_array(["2-1", "4-1", "4-3"])
            "4-3": result.append_array(["3-1", "4-1", "4-2"])
        return result
    var parts := map_id.split("-")
    if parts.size() != 2 or parts[0] != faction or not parts[1].is_valid_int():
        return result
    var number := int(parts[1])
    if number > 1:
        result.append("%s-%d" % [faction, number - 1])
    if number < 8:
        result.append("%s-%d" % [faction, number + 1])
    if number == 1:
        result.append("4-%s" % faction)
    if number == 8:
        result.append("U-1")
    return result

static func can_preview(from_id: String, to_id: String, faction: String) -> bool:
    if not (to_id in neighbors(from_id, faction)):
        return false
    if to_id.length() >= 2 and to_id.substr(0, 2) in ["1-", "2-", "3-"]:
        return to_id.begins_with(faction + "-")
    return true

static func portal_point(from_id: String, to_id: String, faction: String) -> Vector3:
    var slot := ""
    if PVP_SLOTS.has(from_id):
        slot = str(PVP_SLOTS[from_id].get(to_id, ""))
    elif from_id.begins_with("U-"):
        # U-X e apenas um preview local; coordenadas finais serao lidas do servidor.
        if to_id == "U-1" or to_id.ends_with("-8"):
            slot = "BL"
        elif to_id == "U-2" and from_id == "U-1":
            slot = "TR"
        elif to_id == "U-3":
            slot = "TR"
        else:
            slot = "BL"
    else:
        var parts := from_id.split("-")
        if parts.size() == 2 and parts[1].is_valid_int():
            var n := int(parts[1])
            if n == 1 and to_id == "4-%s" % faction:
                slot = "CENTER"
            elif n == 8 and to_id == "U-1":
                slot = "CENTER"
            elif n < 8 and to_id == "%s-%d" % [faction, n + 1]:
                slot = {"1": "BR", "2": "BL", "3": "TL"}.get(faction, "BR")
            elif n > 1 and to_id == "%s-%d" % [faction, n - 1]:
                slot = {"1": "TL", "2": "TR", "3": "BR"}.get(faction, "TL")
    var uv: Vector2 = SLOTS.get(slot, Vector2.ZERO)
    return Vector3(uv.x * BOUNDS.x, 0.0, uv.y * BOUNDS.y)

static func is_pvp(map_id: String) -> bool:
    return map_id.begins_with("4-")

static func is_universe(map_id: String) -> bool:
    return map_id.begins_with("U-")

static func portal_model(target: String) -> String:
    if is_pvp(target):
        return "res://assets/portals/portal_pvp.glb"
    if is_universe(target):
        return "res://assets/portals/portal_universe.glb"
    return "res://assets/portals/portal_normal.glb"

static func link_keys(faction: String) -> Array[PackedStringArray]:
    var links: Array[PackedStringArray] = []
    for i in range(1, 8):
        links.append(PackedStringArray(["%s-%d" % [faction, i], "%s-%d" % [faction, i + 1]]))
    links.append(PackedStringArray(["%s-1" % faction, "4-%s" % faction]))
    links.append(PackedStringArray(["%s-8" % faction, "U-1"]))
    links.append(PackedStringArray(["U-1", "U-2"]))
    links.append(PackedStringArray(["U-2", "U-3"]))
    links.append(PackedStringArray(["4-1", "4-2"]))
    links.append(PackedStringArray(["4-2", "4-3"]))
    links.append(PackedStringArray(["4-1", "4-3"]))
    return links
