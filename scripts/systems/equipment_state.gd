extends RefCounted
## Dois layouts locais com inventario demonstrativo. Dados gravados APENAS em user://.
const Catalog = preload("res://scripts/data/equipment_catalog.gd")
const SAVE_PATH := "user://stellar_g06_equipment_demo.json"
const SWITCH_COOLDOWN := 5.0
var active_configuration := 0
var last_switch_ms := -100000
var configurations: Array[Dictionary] = []
var stock: Dictionary = {}
# G0.12: suporte instalado no hangar, nunca por botoes de combate.
const SUPPORT_ITEMS: Array[String] = ["Drone Alfa", "Drone Beta", "Drone Gama", "Drone Delta", "Drone Epsilon", "Drone Comum", "Drone Elite", "AUX-9"]
var support_stock: Dictionary = {"Drone Alfa":1, "Drone Beta":1, "AUX-9":1}
var fitted_drones: Array[String] = ["Drone Alfa", "Drone Beta"]
var fitted_aux: String = "AUX-9"

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
            fitted_aux = ""
        elif owned_support("AUX-9") > 0:
            fitted_aux = "AUX-9"
        else:
            return "Adquira AUX-9 para instalar"
    elif fitted_drones.has(item_name):
        fitted_drones.erase(item_name)
    elif owned_support(item_name) > 0:
        if fitted_drones.size() >= 2:
            return "Dois slots ocupados: remova um drone"
        fitted_drones.append(item_name)
    else:
        return "Adquira o drone antes de equipar"
    _save()
    return "%s: %s" % [item_name, "INSTALADO" if equipped_support(item_name) else "REMOVIDO"]


func _init() -> void:
    for _i in range(2):
        configurations.append(_blank())
    # Equipamentos iniciais da G0.6 continuam disponíveis. Itens novos devem ser conquistados/comprados no teste.
    const STARTER_ITEMS = ["ARC-1", "ARC-2", "ARC-4", "SG-1", "SG-2", "SG-3", "THR-1", "THR-2", "THR-3", "AUTO-AIM", "NANOBOT REP-2", "RELOAD BOOSTER"]
    for item in Catalog.ITEMS:
        var label: String = str(item["name"])
        stock[label] = 2 if STARTER_ITEMS.has(label) else 0
    _read()

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
    for i in range(arr.size()):
        if str(arr[i]) == "":
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
        f.store_string(JSON.stringify({"active":active_configuration,"configs":configurations,"stock":stock,"support_stock":support_stock,"fitted_drones":fitted_drones,"fitted_aux":fitted_aux}))

func _read() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if f == null:
        return
    var parsed: Variant = JSON.parse_string(f.get_as_text())
    if not (parsed is Dictionary):
        return
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

func copy_to_other() -> String:
    var dest := 1 - active_configuration
    var copied: Dictionary = {}
    for kind in Catalog.CATEGORY_NAMES:
        copied[kind] = equipped(kind)
    configurations[dest] = copied
    _save()
    return "Config %d copiada para Config %d (simulacao)" % [active_configuration + 1, dest + 1]
