extends RefCounted
## G0.17: porao local. Itens vendidos apenas por Creditos de teste.
## Usa nomes ORIGINAIS exibidos pelo Stellar Legacy; nenhum servidor e consultado.
const ShipBalance = preload("res://scripts/data/ship_balance.gd")
const SAVE_PATH: String = "user://stellar_g017_cargo_local.json"
const ORES: Dictionary = {
    "Ferron": {"price": 1000, "asset": "minerio_plasma", "color": "#ff9f43"},
    "Cryon": {"price": 1500, "asset": "minerio_ciano", "color": "#59d3ff"},
    "Virel": {"price": 2500, "asset": "minerio_violeta", "color": "#d76bff"},
    "Ferrite": {"price": 10000, "asset": "minerio_plasma", "color": "#ff6b6b"},
    "Duracite": {"price": 15000, "asset": "minerio_esmeralda", "color": "#65f0bf"},
    "Solarium": {"price": 35000, "asset": "minerio_ouro", "color": "#ffe66d"},
    "Voidite": {"price": 0, "asset": "minerio_violeta", "color": "#ffffff"}
}
var minerals: Dictionary = {}
var stellar_dust: int = 0
var mined_nodes: int = 0
var bonus_collected: int = 0
var loot_collected: int = 0

func _init() -> void:
    for key in ORES.keys():
        minerals[str(key)] = 0
    _load()

func _load() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var f: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if f == null:
        return
    var parsed: Variant = JSON.parse_string(f.get_as_text())
    if not (parsed is Dictionary):
        return
    var stock: Variant = parsed.get("minerals", {})
    if stock is Dictionary:
        for key in ORES.keys():
            minerals[key] = clampi(int(stock.get(key, 0)), 0, 2000000)
    stellar_dust = clampi(int(parsed.get("stellar_dust", 0)), 0, 2000000)
    mined_nodes = clampi(int(parsed.get("mined_nodes", 0)), 0, 2000000)
    bonus_collected = clampi(int(parsed.get("bonus_collected", 0)), 0, 2000000)
    loot_collected = clampi(int(parsed.get("loot_collected", 0)), 0, 2000000)

func _save() -> void:
    var f: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if f != null:
        f.store_string(JSON.stringify({"version":1, "minerals":minerals, "stellar_dust":stellar_dust,
            "mined_nodes":mined_nodes, "bonus_collected":bonus_collected, "loot_collected":loot_collected}))

func capacity(ship_name: String, equipment) -> int:
    var stats: Dictionary = ShipBalance.get_ship(ship_name)
    var base: int = int(stats.get("cargo", 100))
    if equipment != null:
        var installed: Array[String] = equipment.equipped("EXTRAS")
        if installed.has("Módulo de Porão Elite"):
            base += 10000
        elif installed.has("Módulo de Porão Comum"):
            base += 3000
    return maxi(0, base)

func used() -> int:
    var amount: int = 0
    for key in minerals.keys():
        if str(key) != "Voidite":
            amount += int(minerals[key])
    return amount

func free_space(ship_name: String, equipment) -> int:
    return maxi(0, capacity(ship_name, equipment) - used())

func add_resource(name: String, amount: int, ship_name: String, equipment) -> int:
    if not ORES.has(name) or amount <= 0:
        return 0
    var taken: int = amount if name == "Voidite" else mini(amount, free_space(ship_name, equipment))
    if taken <= 0:
        return 0
    minerals[name] = int(minerals[name]) + taken
    _save()
    return taken

func add_dust(amount: int) -> void:
    if amount > 0:
        stellar_dust += amount
        _save()

func sell_all(wallet) -> Dictionary:
    if wallet == null:
        return {"credits":0, "units":0}
    var total: int = 0
    var units: int = 0
    for key in ORES.keys():
        var name: String = str(key)
        var unit_price: int = int(ORES[name].get("price", 0))
        if unit_price <= 0:
            continue
        var amount: int = int(minerals[name])
        total += amount * unit_price
        units += amount
        minerals[name] = 0
    if units > 0:
        wallet.credits += total
        wallet._save()
        _save()
    return {"credits": total, "units": units}

func summary() -> String:
    var parts: Array[String] = []
    for key in ORES.keys():
        var amount: int = int(minerals[key])
        if amount > 0:
            parts.append("%s: %d" % [str(key), amount])
    return " | ".join(PackedStringArray(parts)) if not parts.is_empty() else "Porao vazio"
