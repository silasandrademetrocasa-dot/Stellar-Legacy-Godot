extends RefCounted
## Dois layouts locais com inventario demonstrativo. Dados gravados APENAS em user://.
const Catalog = preload("res://scripts/data/equipment_catalog.gd")
const ShipBalance = preload("res://scripts/data/ship_balance.gd")
const SAVE_PATH := "user://stellar_g015_equipment_demo.json"
const SWITCH_COOLDOWN := 5.0
var active_configuration := 0
var last_switch_ms := -100000
var configurations: Array[Dictionary] = []
var stock: Dictionary = {}
# G0.12: suporte instalado no hangar, nunca por botoes de combate.
const SUPPORT_ITEMS: Array[String] = ["Drone Alfa", "Drone Beta", "Drone Gama", "Drone Delta", "Drone Epsilon", "Drone Comum", "Drone Elite", "Halo", "Nova", "AUX-9", "Coletor de Cargas", "Guarda Estelar", "Pulso Kamikaze", "Coletor de Minérios", "Reparador AUX"]
var support_stock: Dictionary = {}
var fitted_drones: Array[String] = []
var fitted_aux: String = ""
var owned_ships: Dictionary = {"AURORA": 1}
var consumables: Dictionary = {}
var active_ship: String = "AURORA"
var configuration_drones: Array = [[], []]
var configuration_aux: Array = ["", ""]
var configuration_modules: Array = [[], []]
const DRONE_SHOP: Array[String] = ["Halo", "Nova"]
const AUX_MODULE_NAMES: Array[String] = ["Coletor de Cargas", "Guarda Estelar", "Pulso Kamikaze", "Coletor de Minérios", "Reparador AUX"]

func set_active_ship(name: String) -> void:
    active_ship = name
    # Configuracoes guardam o equipamento possuido, mas nao podem violar o limite da nave.
    for cfg in configurations:
        for kind in ["ARMAS", "EXTRAS"]:
            var limit: int = ShipBalance.max_slots(active_ship, kind)
            var arr: Array = cfg[kind]
            for i in range(limit, arr.size()):
                arr[i] = ""
        var generator_limit: int = ShipBalance.max_slots(active_ship, "ESCUDOS")
        var used: int = 0
        for kind in ["ESCUDOS", "MOTORES"]:
            var arr: Array = cfg[kind]
            for i in range(arr.size()):
                if i >= generator_limit or (str(arr[i]) != "" and used >= generator_limit):
                    arr[i] = ""
                elif str(arr[i]) != "":
                    used += 1
    _save()

func _sync_active_support() -> void:
    fitted_drones.clear()
    for name in configuration_drones[active_configuration]:
        fitted_drones.append(str(name))
    fitted_aux = str(configuration_aux[active_configuration])

func equipped_modules() -> Array:
    return configuration_modules[active_configuration]

func allowed_slots(category: String) -> int:
    var base: int = ShipBalance.max_slots(active_ship, category)
    if category == "EXTRAS":
        if equipped("EXTRAS").has("Expansor de Extras Elite"):
            base += 9
        elif equipped("EXTRAS").has("Expansor de Extras Comum"):
            base += 4
    return mini(base, int(Catalog.SLOTS.get(category, 0)))

func used_generators() -> int:
    var result: int = 0
    for kind in ["ESCUDOS", "MOTORES"]:
        for item in equipped(kind):
            if item != "":
                result += 1
    return result

func _slot_allowed(kind: String, idx: int) -> bool:
    if idx < 0 or idx >= allowed_slots(kind):
        return false
    if kind in ["ESCUDOS", "MOTORES"] and used_generators() >= ShipBalance.max_slots(active_ship, "ESCUDOS"):
        return false
    return true
const STARTER_MARKER: int = 15
const BACKUP_PATH := "user://stellar_pre_g015_inventory_backup.json"

func owned_support(item_name: String) -> int:
    return int(support_stock.get(item_name, 0))

func equipped_support(item_name: String) -> bool:
    return fitted_drones.has(item_name) or fitted_aux == item_name

func buy_support(item_name: String) -> String:
    if not SUPPORT_ITEMS.has(item_name):
        return "Suporte nao cadastrado"
    if owned_support(item_name) >= 4:
        return "Limite local de unidades alcancado"
    support_stock[item_name] = owned_support(item_name) + 1
    _save()
    return "%s adicionado ao inventario de teste" % item_name

func toggle_support(item_name: String) -> String:
    if not SUPPORT_ITEMS.has(item_name):
        return "Modelo desconhecido"
    if item_name == "AUX-9":
        if fitted_aux == "AUX-9":
            configuration_aux[active_configuration] = ""
            configuration_modules[active_configuration] = []
        elif owned_support("AUX-9") > 0:
            configuration_aux[active_configuration] = "AUX-9"
        else:
            return "Adquira AUX-9 na loja"
    elif AUX_MODULE_NAMES.has(item_name):
        if fitted_aux != "AUX-9":
            return "Equipe AUX-9 primeiro"
        var modules: Array = configuration_modules[active_configuration]
        if modules.has(item_name):
            modules.erase(item_name)
        elif owned_support(item_name) > 0 and modules.size() < 4:
            modules.append(item_name)
        else:
            return "Sem modulo ou 4 slots ocupados"
    elif fitted_drones.has(item_name):
        configuration_drones[active_configuration].erase(item_name)
    elif owned_support(item_name) > 0:
        if configuration_drones[active_configuration].size() >= 8:
            return "8 slots de drones ocupados"
        configuration_drones[active_configuration].append(item_name)
    else:
        return "Adquira o drone na loja"
    _sync_active_support()
    _save()
    return "%s: configuracao %d atualizada" % [item_name, active_configuration + 1]


func _init() -> void:
    for _i in range(2):
        configurations.append(_blank())
    for item in Catalog.ITEMS:
        stock[str(item["name"])] = 0
    _read()
    _migrate_starter_once()

func _migrate_starter_once() -> void:
    # Uma unica migracao: a G0.13 nao deve recriar o kit nem dar itens gratuitos toda abertura.
    var already_migrated: bool = false
    if FileAccess.file_exists(SAVE_PATH):
        var previous: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
        if previous != null:
            var raw: String = previous.get_as_text()
            var parsed: Variant = JSON.parse_string(raw)
            already_migrated = parsed is Dictionary and int(parsed.get("inventory_schema", 0)) >= STARTER_MARKER
            if not already_migrated and not FileAccess.file_exists(BACKUP_PATH):
                var backup: FileAccess = FileAccess.open(BACKUP_PATH, FileAccess.WRITE)
                if backup != null:
                    backup.store_string(raw)
    if already_migrated:
        return
    configurations.clear()
    for _i in range(2):
        configurations.append(_blank())
    for item_name in stock.keys():
        stock[item_name] = 0
    for name in ["ARC-1", "SG-1", "THR-1", "REPARADOR COMUM"]:
        stock[name] = 1
    configurations[0]["ARMAS"][0] = "ARC-1"
    configurations[0]["ESCUDOS"][0] = "SG-1"
    # THR-1 fica no inventario: Aurora tem 1 gerador compartilhado (motor OU escudo).
    configurations[0]["EXTRAS"][0] = "REPARADOR COMUM"
    support_stock.clear()
    fitted_drones.clear()
    fitted_aux = ""
    configuration_drones = [[], []]
    configuration_aux = ["", ""]
    configuration_modules = [[], []]
    consumables.clear()
    owned_ships = {"AURORA": 1}
    active_configuration = 0
    last_switch_ms = -100000
    _save()

func owns_ship(ship_id: String) -> bool:
    return int(owned_ships.get(ship_id, 0)) > 0

func grant_ship(ship_id: String) -> bool:
    if owns_ship(ship_id):
        return false
    owned_ships[ship_id] = 1
    _save()
    return true

func _blank() -> Dictionary:
    var result: Dictionary = {}
    for kind in Catalog.CATEGORY_NAMES:
        var slots: Array[String] = []
        for _j in range(int(Catalog.SLOTS[kind])):
            slots.append("")
        result[kind] = slots
    return result

func equipped(category: String) -> Array[String]:
    if not Catalog.SLOTS.has(category):
        return []
    var source: Array = configurations[active_configuration][category]
    var result: Array[String] = []
    for item in source:
        result.append(str(item))
    return result

func free_amount(item_name: String) -> int:
    var item: Dictionary = Catalog.get_item(item_name)
    if item.is_empty():
        return 0
    var used := 0
    for equipped_item in equipped(str(item["category"])):
        if equipped_item == item_name:
            used += 1
    return maxi(0, int(stock.get(item_name, 0)) - used)

func equip(item_name: String) -> String:
    var item: Dictionary = Catalog.get_item(item_name)
    if item.is_empty():
        return "Equipamento desconhecido"
    var kind := str(item["category"])
    if free_amount(item_name) == 0:
        return "Sem unidades livres no estoque local"
    var arr: Array = configurations[active_configuration][kind]
    for i in range(mini(arr.size(), allowed_slots(kind))):
        if str(arr[i]) == "" and _slot_allowed(kind, i):
            arr[i] = item_name
            _save()
            return "%s equipado no slot %d" % [item_name, i + 1]
    return "Slots de %s ocupados" % kind

func equip_at(item_name: String, index: int) -> String:
    var item: Dictionary = Catalog.get_item(item_name)
    if item.is_empty():
        return "Equipamento desconhecido"
    var kind: String = str(item["category"])
    var arr: Array = configurations[active_configuration][kind]
    if index < 0 or index >= arr.size():
        return "Slot invalido"
    if str(arr[index]) != "":
        return "Slot ja ocupado"
    if not _slot_allowed(kind, index):
        return "Sem slots livres nesta nave (geradores compartilhados)"
    if free_amount(item_name) <= 0:
        return "Nao ha unidades livres"
    arr[index] = item_name
    _save()
    return "%s equipado no slot %d" % [item_name, index + 1]

func remove_at(kind: String, index: int) -> String:
    if not Catalog.SLOTS.has(kind):
        return "Categoria invalida"
    var arr: Array = configurations[active_configuration][kind]
    if index < 0 or index >= arr.size() or str(arr[index]) == "":
        return "Slot vazio"
    var name := str(arr[index])
    arr[index] = ""
    _save()
    return "%s removido (estoque local)" % name

func remove_matching(item_name: String) -> String:
    var item: Dictionary = Catalog.get_item(item_name)
    if item.is_empty():
        return "Item desconhecido"
    var kind := str(item["category"])
    var arr: Array = configurations[active_configuration][kind]
    for i in range(arr.size() - 1, -1, -1):
        if str(arr[i]) == item_name:
            return remove_at(kind, i)
    return "Este item nao esta equipado"

func select_configuration(index: int) -> String:
    if index < 0 or index > 1:
        return "Configuracao invalida"
    if index == active_configuration:
        return "Configuracao %d ja ativa" % (index + 1)
    var now := Time.get_ticks_msec()
    var remaining := SWITCH_COOLDOWN - float(now - last_switch_ms) / 1000.0
    if remaining > 0.0:
        return "Aguarde %.1fs para alternar" % remaining
    active_configuration = index
    last_switch_ms = now
    _sync_active_support()
    _save()
    return "Configuracao %d ativada" % (index + 1)

func bonus(kind: String) -> float:
    var total := 0.0
    for item_name in equipped(kind):
        if item_name != "":
            total += float(Catalog.get_item(item_name).get("bonus", 0))
    return total

func _save() -> void:
    var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if f != null:
        f.store_string(JSON.stringify({"active":active_configuration,"configs":configurations,"stock":stock,"support_stock":support_stock,"fitted_drones":fitted_drones,"fitted_aux":fitted_aux,"owned_ships":owned_ships,"inventory_schema":STARTER_MARKER,"configuration_drones":configuration_drones,"configuration_aux":configuration_aux,"configuration_modules":configuration_modules,"consumables":consumables}))

func _read() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if f == null:
        return
    var parsed: Variant = JSON.parse_string(f.get_as_text())
    if not (parsed is Dictionary):
        return
    var ship_data: Variant = parsed.get("owned_ships", {})
    if ship_data is Dictionary:
        owned_ships = {"AURORA":1}
        for key in ship_data.keys():
            var id: String = str(key)
            if id in ["AURORA", "BASTION", "BULWARK", "KENSEI", "LEVIATHAN", "LYNX", "MERIDIAN", "PATHFINDER", "PHANTOM", "PIONEER", "RAPTOR", "SERAPH", "VALKYRIE"] and int(ship_data[key]) > 0:
                owned_ships[id] = 1
    var loaded_support: Variant = parsed.get("support_stock", {})
    if loaded_support is Dictionary:
        for name in SUPPORT_ITEMS:
            support_stock[name] = clampi(int(loaded_support.get(name, support_stock.get(name, 0))), 0, 4)
    var loaded_drones: Variant = parsed.get("fitted_drones", fitted_drones)
    if loaded_drones is Array:
        fitted_drones.clear()
        for value in loaded_drones:
            var drone_name: String = str(value)
            if drone_name != "AUX-9" and SUPPORT_ITEMS.has(drone_name) and owned_support(drone_name) > 0 and not fitted_drones.has(drone_name) and fitted_drones.size() < 2:
                fitted_drones.append(drone_name)
    var saved_aux: String = str(parsed.get("fitted_aux", fitted_aux))
    fitted_aux = "AUX-9" if saved_aux == "AUX-9" and owned_support("AUX-9") > 0 else ""
    var saved_c_drones: Variant = parsed.get("configuration_drones", [])
    var saved_c_aux: Variant = parsed.get("configuration_aux", [])
    var saved_c_modules: Variant = parsed.get("configuration_modules", [])
    if saved_c_drones is Array and saved_c_drones.size() == 2:
        configuration_drones = [[], []]
        for i in range(2):
            if saved_c_drones[i] is Array:
                for n in saved_c_drones[i]:
                    if SUPPORT_ITEMS.has(str(n)) and owned_support(str(n)) > 0 and configuration_drones[i].size() < 8:
                        configuration_drones[i].append(str(n))
    else:
        configuration_drones[0] = fitted_drones.duplicate()
    if saved_c_aux is Array and saved_c_aux.size() == 2:
        for i in range(2):
            configuration_aux[i] = "AUX-9" if str(saved_c_aux[i]) == "AUX-9" and owned_support("AUX-9") > 0 else ""
    else:
        configuration_aux[0] = fitted_aux
    if saved_c_modules is Array and saved_c_modules.size() == 2:
        for i in range(2):
            if saved_c_modules[i] is Array:
                for n in saved_c_modules[i]:
                    if AUX_MODULE_NAMES.has(str(n)) and owned_support(str(n)) > 0 and configuration_modules[i].size() < 4:
                        configuration_modules[i].append(str(n))
    var loaded_consumables: Variant = parsed.get("consumables", {})
    if loaded_consumables is Dictionary:
        consumables = loaded_consumables
    var loaded_stock: Variant = parsed.get("stock", {})
    if loaded_stock is Dictionary:
        for catalog_item in Catalog.ITEMS:
            var official_name: String = str(catalog_item["name"])
            stock[official_name] = clampi(int(loaded_stock.get(official_name, stock[official_name])),0,9999)
    var cfgs: Variant = parsed.get("configs", [])
    if not (cfgs is Array) or cfgs.size() != 2:
        return
    var clean: Array[Dictionary] = []
    for cfg in cfgs:
        if not (cfg is Dictionary):
            return
        var result: Dictionary = _blank()
        for kind in Catalog.CATEGORY_NAMES:
            var values: Variant = cfg.get(kind, [])
            if not (values is Array):
                continue
            var limit := mini(values.size(), int(Catalog.SLOTS[kind]))
            var used: Dictionary = {}
            for i in range(limit):
                var item_name := str(values[i])
                var item: Dictionary = Catalog.get_item(item_name)
                if str(item.get("category", "")) == kind:
                    used[item_name] = int(used.get(item_name, 0)) + 1
                    if int(used[item_name]) <= int(stock.get(item_name, 0)):
                        result[kind][i] = item_name
        clean.append(result)
    configurations = clean
    active_configuration = clampi(int(parsed.get("active", 0)), 0, 1)
    _sync_active_support()

func copy_to_other() -> String:
    var dest := 1 - active_configuration
    var copied: Dictionary = {}
    for kind in Catalog.CATEGORY_NAMES:
        copied[kind] = equipped(kind)
    configurations[dest] = copied
    configuration_drones[dest] = configuration_drones[active_configuration].duplicate()
    configuration_aux[dest] = configuration_aux[active_configuration]
    configuration_modules[dest] = configuration_modules[active_configuration].duplicate()
    _save()
    return "Config %d copiada para Config %d (simulacao)" % [active_configuration + 1, dest + 1]
