extends RefCounted
## G0.13: catalogo unico para vitrine e preco; nenhum preco vem do cliente remoto.
const Equipment = preload("res://scripts/data/equipment_catalog.gd")
const SHIPS: Array[String] = ["AURORA", "BASTION", "BULWARK", "KENSEI", "LEVIATHAN", "LYNX", "MERIDIAN", "PATHFINDER", "PHANTOM", "PIONEER", "RAPTOR", "SERAPH", "VALKYRIE"]
const DRONES: Array[String] = ["Drone Alfa", "Drone Beta", "Drone Gama", "Drone Delta", "Drone Epsilon", "Drone Comum", "Drone Elite"]
const CATEGORIES: Array[String] = ["NAVES", "ARMAS", "ESCUDOS", "MOTORES", "EXTRAS", "DRONES", "AUX-9"]

static func _rarity(bonus: int) -> String:
    if bonus >= 1500:
        return "LENDARIO"
    if bonus >= 750:
        return "EPICO"
    if bonus >= 200:
        return "RARO"
    return "COMUM"

static func all_in(category: String) -> Array[Dictionary]:
    var results: Array[Dictionary] = []
    if category == "NAVES":
        for i in range(SHIPS.size()):
            var key: String = SHIPS[i]
            var amount: int = 0 if key == "AURORA" else 3500 + i * 1750
            results.append({"name":key,"category":"NAVES","cost":amount,"path":"res://assets/ships/SL_%s_FINAL.glb" % key,"rarity":"PADRAO" if key == "AURORA" else ("EPICO" if i > 7 else "RARO"),"desc":"Nave original Stellar Legacy / modelo 3D integral"})
    elif category == "DRONES":
        for i in range(DRONES.size()):
            var name: String = DRONES[i]
            var suffix: String = ["a", "b", "c", "d", "e", "common", "elite"][i]
            results.append({"name":name,"category":category,"cost":1250+i*500,"path":"res://assets/drones/drone_%s.glb" % suffix,"rarity":"EPICO" if i == 6 else "RARO","desc":"Unidade automatica de apoio / equipe no Hangar"})
    elif category == "AUX-9":
        results.append({"name":"AUX-9","category":"AUX-9","cost":4900,"path":"res://assets/aux/aux9.glb","rarity":"EPICO","desc":"Modulo auxiliar de suporte / instale no Hangar"})
    elif Equipment.CATEGORY_NAMES.has(category):
        for eq in Equipment.items_in_category(category):
            var name: String = str(eq["name"])
            var power: int = int(eq.get("bonus", 0))
            var cost: int = 0
            match category:
                "ARMAS": cost = 275 + power * 42
                "ESCUDOS": cost = 320 + power * 3
                "MOTORES": cost = 320 + power * 110
                "EXTRAS": cost = 680
            if name == "REPARADOR COMUM":
                cost = 120
            results.append({"name":name,"category":category,"cost":cost,"path":Equipment.model_path(name),"rarity":_rarity(power),"desc":str(eq.get("desc","Equipamento Stellar Legacy")),"bonus":power})
    return results

static func find(name: String) -> Dictionary:
    for category in CATEGORIES:
        for entry in all_in(category):
            if str(entry["name"]) == name:
                return entry
    return {}
