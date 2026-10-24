extends RefCounted
## Stellar Legacy G0.8: laboratorio OFFLINE de sistemas sociais, eventos e economia.
## NUNCA concede permissoes ADM ou altera contas, saldos e relés de producao.
const SAVE_PATH := "user://stellar_g08_hub_demo.json"
const VERSION := 1
const CAPTURE_SECONDS := 12.0
const CAPTURE_DISTANCE := 19.0
const RELAY_MAPS := ["4-1", "4-2", "4-3"]
const SHOP := [
    {"name": "Insignia de Explorador", "cost": 150, "info": "Colecionavel local; nao altera a nave"},
    {"name": "Emblema Sentinela", "cost": 280, "info": "Colecionavel local; nao altera atributos"},
    {"name": "Distintivo da Frota", "cost": 430, "info": "Colecionavel local de demonstracao"},
]
const AUCTION := [
    {"name": "Lote de motores THR", "opening": 300},
    {"name": "Lote de escudos SG", "opening": 500},
    {"name": "Lote de lasers ARC", "opening": 750},
]
const CONTRACTS := [
    {"key": "hunter", "label": "Patrulha da Fronteira", "goal": 8, "credits": 450},
    {"key": "salvage", "label": "Recuperacao de Carga", "goal": 5, "credits": 290},
    {"key": "cartographer", "label": "Cartografo Estelar", "goal": 6, "credits": 360},
]
const PASS_GOALS := [2, 6, 12, 20]
const PASS_REWARDS := [100, 200, 350, 500]

var callsign: String = "PILOTO ESTELAR"
var title: String = "Explorador"
var alliance: String = ""
var alliance_tag: String = ""
var bonus_credits: int = 450
var spent_credits: int = 0
var purchases: Array[String] = []
var relay_owners: Dictionary = {"4-1": "", "4-2": "", "4-3": ""}
var capture_progress: float = 0.0
var capture_map: String = ""
var contract_claims: Dictionary = {}
var pass_claims: Dictionary = {}
var auction_bids: Dictionary = {}
var relay_captures: int = 0
var news: Array[String] = []

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
    var data: Dictionary = parsed
    if int(data.get("version", 0)) != VERSION:
        return
    callsign = str(data.get("callsign", callsign)).substr(0, 24)
    title = str(data.get("title", title)).substr(0, 30)
    alliance = str(data.get("alliance", "")).substr(0, 28)
    alliance_tag = str(data.get("alliance_tag", "")).substr(0, 5)
    bonus_credits = clampi(int(data.get("bonus_credits", 450)), 0, 1000000)
    spent_credits = clampi(int(data.get("spent_credits", 0)), 0, 1000000)
    relay_captures = clampi(int(data.get("relay_captures", 0)), 0, 1000000)
    var got: Variant = data.get("purchases", [])
    if got is Array:
        for item in got:
            if purchases.size() < 20 and not purchases.has(str(item)):
                purchases.append(str(item).substr(0, 55))
    var loaded: Variant = data.get("relay_owners", {})
    if loaded is Dictionary:
        for map_id in RELAY_MAPS:
            var owner: String = str(loaded.get(map_id, ""))
            relay_owners[map_id] = owner if owner in ["", "1", "2", "3"] else ""
    for pair in [["contract_claims", contract_claims], ["pass_claims", pass_claims], ["auction_bids", auction_bids]]:
        var source: Variant = data.get(str(pair[0]), {})
        if source is Dictionary:
            var target: Dictionary = pair[1]
            for key in source.keys():
                if str(key).length() <= 35:
                    target[str(key)] = source[key]

func _save() -> void:
    var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return
    var payload: Dictionary = {"version": VERSION, "callsign": callsign, "title": title,
        "alliance": alliance, "alliance_tag": alliance_tag, "bonus_credits": bonus_credits,
        "spent_credits": spent_credits, "purchases": purchases,
        "relay_owners": relay_owners, "relay_captures": relay_captures,
        "contract_claims": contract_claims, "pass_claims": pass_claims,
        "auction_bids": auction_bids}
    file.store_string(JSON.stringify(payload))

func credit_balance(pilot_credits: int) -> int:
    return maxi(0, pilot_credits + bonus_credits - spent_credits)

func set_callsign(new_name: String) -> String:
    var clean: String = new_name.strip_edges().substr(0, 24)
    if clean.length() < 3:
        return "Apelido deve ter ao menos 3 caracteres"
    callsign = clean
    _save()
    return "Identidade local atualizada: " + callsign

func create_alliance(new_name: String, faction: String) -> String:
    if not alliance.is_empty():
        return "Voce ja tem uma alianca de teste. Saia antes de criar outra."
    var clean: String = new_name.strip_edges().substr(0, 28)
    if clean.length() < 3:
        return "Informe um nome de alianca com ao menos 3 caracteres"
    alliance = clean
    alliance_tag = clean.substr(0, 3).to_upper()
    _save()
    return "Alianca local %s criada para a faccao %s" % [alliance, faction]

func leave_alliance() -> String:
    alliance = ""
    alliance_tag = ""
    _save()
    return "Alianca local removida"

func progress_contract(key: String, pilot) -> int:
    match key:
        "hunter": return pilot.kills
        "salvage": return pilot.boxes
        "cartographer": return pilot.visited.size()
    return 0

func claim_contract(key: String, pilot) -> String:
    for c in CONTRACTS:
        if str(c["key"]) == key:
            if bool(contract_claims.get(key, false)):
                return "Recompensa ja recebida"
            if progress_contract(key, pilot) < int(c["goal"]):
                return "Missao ainda nao concluida"
            contract_claims[key] = true
            bonus_credits += int(c["credits"])
            _save()
            return "Missao concluida! +%d creditos de simulacao" % int(c["credits"])
    return "Missao invalida"

func pass_score(pilot) -> int:
    return pilot.kills + pilot.boxes + pilot.visited.size()

func claim_pass(level_index: int, pilot) -> String:
    if level_index < 0 or level_index >= PASS_GOALS.size():
        return "Etapa inexistente"
    var key: String = str(level_index)
    if bool(pass_claims.get(key, false)):
        return "Premio de simulacao ja recebido"
    if pass_score(pilot) < PASS_GOALS[level_index]:
        return "Etapa ainda bloqueada"
    pass_claims[key] = true
    bonus_credits += PASS_REWARDS[level_index]
    _save()
    return "Passe gratuito: +%d creditos de simulacao" % PASS_REWARDS[level_index]

func buy_demo(name: String, pilot_credits: int) -> String:
    for entry in SHOP:
        if name == str(entry["name"]):
            if purchases.has(name):
                return "Item de demonstracao ja adquirido"
            if credit_balance(pilot_credits) < int(entry["cost"]):
                return "Saldo local de simulacao insuficiente"
            spent_credits += int(entry["cost"])
            purchases.append(name)
            _save()
            return "%s adicionado a colecao offline" % name
    return "Produto desconhecido"

func simulate_bid(lot: int) -> String:
    if lot < 0 or lot >= AUCTION.size():
        return "Lote desconhecido"
    var key: String = str(lot)
    var current: int = int(auction_bids.get(key, int(AUCTION[lot]["opening"])))
    auction_bids[key] = current + 50
    _save()
    return "Lance de teste: %d (sem pagamento, sem leilao online)" % int(auction_bids[key])

func relay_text(map_id: String) -> String:
    if not RELAY_MAPS.has(map_id):
        return "Reles disponiveis apenas em 4-1, 4-2 e 4-3"
    var owner: String = str(relay_owners.get(map_id, ""))
    if owner.is_empty():
        return "NEUTRO"
    return "FACCAO " + owner

func relay_tick(map_id: String, faction: String, distance: float, delta: float) -> String:
    if not RELAY_MAPS.has(map_id):
        capture_progress = 0.0
        capture_map = ""
        return ""
    if str(relay_owners.get(map_id, "")) == faction:
        capture_progress = 0.0
        capture_map = map_id
        return ""
    if distance > CAPTURE_DISTANCE:
        capture_progress = 0.0
        capture_map = map_id
        return ""
    if capture_map != map_id:
        capture_progress = 0.0
        capture_map = map_id
    capture_progress += delta
    if capture_progress >= CAPTURE_SECONDS:
        relay_owners[map_id] = faction
        capture_progress = 0.0
        relay_captures += 1
        _save()
        return "RELE %s DOMINADO PELA FACCAO %s (SIMULACAO)" % [map_id, faction]
    return ""

func capture_ratio(map_id: String) -> float:
    if capture_map != map_id:
        return 0.0
    return clampf(capture_progress / CAPTURE_SECONDS, 0.0, 1.0)
