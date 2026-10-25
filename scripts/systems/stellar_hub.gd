extends RefCounted
## Stellar Legacy G0.8: laboratorio OFFLINE de sistemas sociais, eventos e economia.
## NUNCA concede permissoes ADM ou altera contas, saldos e relés de producao.
const StoreCatalog = preload("res://scripts/data/store_catalog.gd")
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
const SHOP_EQUIPMENT := [
    {"name":"ARC-1","cost":380,"description":"Emissor de pulso estelar"},
    {"name":"ARC-2","cost":680,"description":"Lasers de patrulha reforcados"},
    {"name":"ARC-4","cost":1450,"description":"Armamento de alto impacto"},
    {"name":"SG-1","cost":420,"description":"Campo defensivo"},
    {"name":"SG-3","cost":1300,"description":"Escudo de alta resistencia"},
    {"name":"THR-2","cost":760,"description":"Propulsao de combate"},
    {"name":"THR-3","cost":1380,"description":"Propulsor de elite"},
    {"name":"AUTO-AIM","cost":950,"description":"Assistencia tatica"},
    {"name":"VSH-0","cost":500,"description":"Vitrine GLB do arsenal Stellar Legacy"},
    {"name":"VSH-2","cost":1800,"description":"Vitrine GLB do arsenal Stellar Legacy"},
    {"name":"VSH-3","cost":3200,"description":"Vitrine GLB do arsenal Stellar Legacy"},
    {"name":"VSH-5","cost":6200,"description":"Vitrine GLB do arsenal Stellar Legacy"},
    {"name":"FS-01","cost":700,"description":"Vitrine GLB do arsenal Stellar Legacy"},
    {"name":"FS-03","cost":2450,"description":"Vitrine GLB do arsenal Stellar Legacy"},
    {"name":"ARC-Q","cost":12500,"description":"Vitrine GLB do arsenal Stellar Legacy"},
    {"name":"VORTEX-X","cost":8750,"description":"Vitrine GLB do arsenal Stellar Legacy"},
    {"name":"PULSAR-7","cost":4250,"description":"Vitrine GLB do arsenal Stellar Legacy"},
    {"name":"FALCAO","cost":1850,"description":"Vitrine GLB do arsenal Stellar Legacy"},
    {"name":"BRASA","cost":1600,"description":"Vitrine GLB do arsenal Stellar Legacy"},
    {"name":"RAIO CELESTE","cost":8900,"description":"Vitrine GLB do arsenal Stellar Legacy"},
    {"name":"THR-1","cost":200,"description":"Vitrine GLB do arsenal Stellar Legacy"},
]
const AUCTION := [
    {"name":"THR-3 | MOTOR DE ELITE","opening":900,"model":"res://assets/equipment/thr-3.glb"},
    {"name":"SG-3 | ESCUDO ELITE","opening":1100,"model":"res://assets/equipment/sg-3.glb"},
    {"name":"ARC-4 | LASER ELITE","opening":1400,"model":"res://assets/equipment/arc-4.glb"},
    {"name":"RELOAD BOOSTER | EXTRA","opening":1200,"model":"res://assets/equipment/reload_booster.glb"},
    {"name":"ARC-Q | ARMAMENTO LENDARIO","opening":12500,"model":"res://assets/equipment/arc-q.glb"},
    {"name":"VSH-3 | ESCUDO DE SINGULARIDADE","opening":5200,"model":"res://assets/equipment/vsh-3.glb"},
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
# G0.21: fases dos relés persistidas no MESMO save, sem resetar capturas anteriores.
var relay_levels: Dictionary = {"4-1": 1, "4-2": 1, "4-3": 1}
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
    # Dados novos sao opcionais: arquivos de G0.20 continuam validos.
    var levels_saved: Variant = data.get("relay_levels", {})
    if levels_saved is Dictionary:
        for map_id in RELAY_MAPS:
            relay_levels[map_id] = clampi(int(levels_saved.get(map_id, 1)), 1, 3)
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
        "relay_owners": relay_owners, "relay_levels": relay_levels, "relay_captures": relay_captures,
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

func buy_equipment(item_name: String, amount: int, pilot_credits: int, equipment) -> String:
    # Economias de G0.9 sempre locais; nunca converter lances em saldos reais.
    var authorized: bool = false
    for item in SHOP_EQUIPMENT:
        if str(item["name"]) == item_name and int(item["cost"]) == amount:
            authorized = true
            break
    if not authorized:
        return "Equipamento indisponivel nesta loja de teste"
    if credit_balance(pilot_credits) < amount:
        return "Creditos locais insuficientes"
    if equipment == null:
        return "Inventario indisponivel"
    equipment.stock[item_name] = int(equipment.stock.get(item_name,0)) + 1
    equipment._save()
    spent_credits += amount
    _save()
    return "%s adquirido no inventario LOCAL (sem compra online)" % item_name

func buy_store_item(item_name: String, pilot_credits: int, equipment) -> String:
    # Apenas mercado offline; categoria e preco derivam exclusivamente do catalogo interno.
    var product: Dictionary = StoreCatalog.find(item_name)
    if product.is_empty() or equipment == null:
        return "Item nao encontrado no arsenal"
    var cost: int = int(product.get("cost", 0))
    var category: String = str(product.get("category", ""))
    if category == "NAVES" and equipment.owns_ship(item_name):
        return "Esta nave ja pertence ao hangar"
    if category in ["DRONES", "AUX-9"] and equipment.owned_support(item_name) >= 4:
        return "Limite de unidades atingido"
    if cost <= 0:
        return "Item inicial: disponivel somente no hangar"
    if credit_balance(pilot_credits) < cost:
        return "Creditos de simulacao insuficientes"
    if category == "NAVES":
        equipment.grant_ship(item_name)
    elif category in ["DRONES", "AUX-9"]:
        var message: String = equipment.buy_support(item_name)
        if not message.begins_with(item_name):
            return message
    else:
        equipment.stock[item_name] = int(equipment.stock.get(item_name, 0)) + 1
        equipment._save()
    spent_credits += cost
    _save()
    return "%s comprado! Abra HANGAR / EQUIPAMENTOS para instalar." % item_name

func simulate_bid(lot: int) -> String:
    if lot < 0 or lot >= AUCTION.size():
        return "Lote desconhecido"
    var key: String = str(lot)
    var current: int = int(auction_bids.get(key, int(AUCTION[lot]["opening"])))
    auction_bids[key] = current + 50
    _save()
    return "Lance de teste: %d (sem pagamento, sem leilao online)" % int(auction_bids[key])

func relay_level(map_id: String) -> int:
    if not RELAY_MAPS.has(map_id):
        return 1
    return clampi(int(relay_levels.get(map_id, 1)), 1, 3)

func upgrade_relay_local(map_id: String, faction: String, near_center: bool) -> String:
    # Teste local: evolucao permitida somente se a faccao domina E o piloto esta no rele.
    # Nao representa administracao de cla nem permissao no servidor multiplayer.
    if not RELAY_MAPS.has(map_id):
        return "Evolucao disponivel nos mapas PvP 4-X"
    if str(relay_owners.get(map_id, "")) != faction:
        return "Capture primeiro o rele com sua faccao"
    if not near_center:
        return "Aproxime-se do centro do rele (19 unidades)"
    var level: int = relay_level(map_id)
    if level >= 3:
        return "Rele %s ja esta na fase maxima LV3" % map_id
    relay_levels[map_id] = level + 1
    _save()
    return "RELE %s EVOLUINDO LV%d > LV%d (SIMULACAO LOCAL)" % [map_id, level, level + 1]

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

func refine_astral(astral, pilot_credits: int) -> String:
    const COST = 350
    if astral == null:
        return "Materializador indisponivel"
    if credit_balance(pilot_credits) < COST:
        return "Creditos locais insuficientes para a refinaria"
    spent_credits += COST
    astral.award_fragments(4)
    _save()
    return "REFINARIA: +4 FRAGMENTOS ASTRAIS por 350 CR (TESTE)"

func change_title(next_title: String, pilot, astral) -> String:
    var unlocked: bool = false
    match next_title:
        "Explorador": unlocked = true
        "Sentinela": unlocked = pilot.kills >= 5
        "Cacador Estelar": unlocked = pilot.kills >= 20
        "Conquistador": unlocked = relay_captures >= 1
        "Navegante Astral":
            for k in astral.clears:
                if int(astral.clears[k]) > 0:
                    unlocked = true
    if not unlocked:
        return "Titulo bloqueado: conclua seu requisito local"
    title = next_title
    _save()
    return "TITULO ATIVO: " + title
