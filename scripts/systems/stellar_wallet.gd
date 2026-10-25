extends RefCounted
## Carteira DEMONSTRATIVA do Godot; nunca comunica com banco/financeiro.
## Os precos sao copiados do Supabase, mas os saldos abaixo sao creditos de teste.
const SAVE_PATH := "user://stellar_g015_wallet_demo.json"
var credits: int = 150000000
var stellarium: int = 2500000
var purchases: int = 0

func _init() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        var f: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
        if f != null:
            var data: Variant = JSON.parse_string(f.get_as_text())
            if data is Dictionary:
                credits = maxi(0, int(data.get("credits", credits)))
                stellarium = maxi(0, int(data.get("stellarium", stellarium)))
                purchases = maxi(0, int(data.get("purchases", 0)))

func balance(currency: String) -> int:
    return stellarium if currency == "uridium" else credits

func display_currency(currency: String) -> String:
    return "STL" if currency == "uridium" else "CR"

func buy(product: Dictionary, equipment) -> String:
    if equipment == null or product.is_empty():
        return "Produto indisponivel"
    if not bool(product.get("shop_visible", false)) or bool(product.get("event_only", false)):
        return "Reservado para evento / fora da loja"
    var cost: int = int(product.get("cost", 0))
    var currency: String = str(product.get("currency", "credits"))
    if cost <= 0 or currency not in ["credits", "uridium"]:
        return "Preco invalido / item nao comercializado"
    if balance(currency) < cost:
        return "Saldo de %s insuficiente (simulacao local)" % display_currency(currency)
    var name: String = str(product.get("name", ""))
    var category: String = str(product.get("category", ""))
    if category == "NAVES":
        if not equipment.grant_ship(name):
            return "Nave ja adquirida"
    elif category in ["DRONES", "AUX-9", "MODULOS AUX"]:
        var message: String = equipment.buy_support(name)
        if not message.begins_with(name):
            return message
    elif category in ["MUNICOES LASER", "MISSEIS"]:
        equipment.consumables[name] = int(equipment.consumables.get(name, 0)) + int(product.get("pack", 100))
        equipment._save()
    else:
        equipment.stock[name] = int(equipment.stock.get(name, 0)) + 1
        equipment._save()
    if currency == "uridium":
        stellarium -= cost
    else:
        credits -= cost
    purchases += 1
    _save()
    return "%s comprado por %d %s (OFFLINE)" % [name, cost, display_currency(currency)]

func _save() -> void:
    var f: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if f != null:
        f.store_string(JSON.stringify({"credits":credits,"stellarium":stellarium,"purchases":purchases}))
