extends RefCounted
## Scene spans from the local G0.22.1 package; no changes to ship balance.
const SPANS := {
    "AURORA": 3.05, "PIONEER": 3.25, "RAPTOR": 3.30, "MERIDIAN": 3.45,
    "BASTION": 3.70, "LYNX": 3.30, "PHANTOM": 3.35, "PATHFINDER": 3.40,
    "KENSEI": 3.55, "VALKYRIE": 3.60, "LEVIATHAN": 4.10,
    "SERAPH": 3.85, "BULWARK": 4.10,
}

static func span(ship_id: String) -> float:
    return float(SPANS.get(ship_id, 3.40))
