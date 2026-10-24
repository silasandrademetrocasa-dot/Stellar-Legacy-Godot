extends RefCounted
## Dois layouts locais com inventario demonstrativo. Dados gravados APENAS em user://.
const Catalog = preload("res://scripts/data/equipment_catalog.gd")
const SAVE_PATH := "user://stellar_g06_equipment_demo.json"
const SWITCH_COOLDOWN := 5.0
var active_configuration := 0
var last_switch_ms := -100000
var configurations: Array[Dictionary] = []
var stock: Dictionary = {}

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
        f.store_string(JSON.stringify({"active":active_configuration,"configs":configurations,"stock":stock}))

func _read() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if f == null:
        return
    var parsed: Variant = JSON.parse_string(f.get_as_text())
    if not (parsed is Dictionary):
        return
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
