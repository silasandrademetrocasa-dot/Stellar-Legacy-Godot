extends RefCounted
## Inventario offline G0.6 - nomes proprios Stellar Legacy. Nenhum ID de banco antigo.
const SLOTS := {"ARMAS": 6, "ESCUDOS": 4, "MOTORES": 2, "EXTRAS": 3}
const CATEGORY_NAMES := ["ARMAS", "ESCUDOS", "MOTORES", "EXTRAS"]
const ITEMS := [
    {"name":"ARC-1", "category":"ARMAS", "model":"arc-1", "bonus":12, "desc":"Laser de energia azul / nivel inicial"},
    {"name":"ARC-2", "category":"ARMAS", "model":"arc-2", "bonus":19, "desc":"Laser de pulso rubro / dano estendido"},
    {"name":"ARC-4", "category":"ARMAS", "model":"arc-4", "bonus":32, "desc":"Laser avancado com nucleos de plasma"},
    {"name":"SG-1", "category":"ESCUDOS", "model":"sg-1", "bonus":350, "desc":"Gerador esferico de escudo leve"},
    {"name":"SG-2", "category":"ESCUDOS", "model":"sg-2", "bonus":650, "desc":"Gerador aprimorado de protecao"},
    {"name":"SG-3", "category":"ESCUDOS", "model":"sg-3", "bonus":1000, "desc":"Gerador reforcado de campo energetico"},
    {"name":"THR-1", "category":"MOTORES", "model":"thr-1", "bonus":4, "desc":"Propulsao compacta e estavel"},
    {"name":"THR-2", "category":"MOTORES", "model":"thr-2", "bonus":7, "desc":"Propulsor dual de longo alcance"},
    {"name":"THR-3", "category":"MOTORES", "model":"thr-3", "bonus":10, "desc":"Propulsor triplo de alto desempenho"},
    {"name":"AUTO-AIM", "category":"EXTRAS", "model":"auto-aim", "bonus":1, "desc":"Sensor tatico de mira automatizada"},
    {"name":"NANOBOT REP-2", "category":"EXTRAS", "model":"nanobot_rep-2", "bonus":1, "desc":"Microdrones de reparacao local"},
    {"name":"RELOAD BOOSTER", "category":"EXTRAS", "model":"reload_booster", "bonus":1, "desc":"Estabilizador de cadencia de lasers"},
    {"name":"VSH-0", "category":"ESCUDOS", "model":"vsh-0", "bonus":380, "desc":"Protecao esferica original"},
    {"name":"VSH-1", "category":"ESCUDOS", "model":"vsh-1", "bonus":590, "desc":"Escudo esferico reforcado"},
    {"name":"VSH-2", "category":"ESCUDOS", "model":"vsh-2", "bonus":860, "desc":"Escudo esferico estabilizado"},
    {"name":"VSH-3", "category":"ESCUDOS", "model":"vsh-3", "bonus":1270, "desc":"Escudo de singularidade"},
    {"name":"VSH-4", "category":"ESCUDOS", "model":"vsh-4", "bonus":1510, "desc":"Escudo epico de combate"},
    {"name":"VSH-5", "category":"ESCUDOS", "model":"vsh-5", "bonus":1920, "desc":"Escudo protetor avancado"},
    {"name":"VSH-6", "category":"ESCUDOS", "model":"vsh-6", "bonus":2450, "desc":"Escudo supremo de energia"},
    {"name":"FS-01", "category":"ESCUDOS", "model":"fs-01", "bonus":430, "desc":"Escudo de forca padrao"},
    {"name":"FS-02", "category":"ESCUDOS", "model":"fs-02", "bonus":670, "desc":"Escudo de forca aprimorado"},
    {"name":"FS-03", "category":"ESCUDOS", "model":"fs-03", "bonus":990, "desc":"Escudo de forca avancado"},
    {"name":"FS-04", "category":"ESCUDOS", "model":"fs-04", "bonus":1490, "desc":"Escudo de forca supremo"},
    {"name":"ARC-Q", "category":"ARMAS", "model":"arc-q", "bonus":110, "desc":"Laser de evento lendario"},
    {"name":"VORTEX-X", "category":"ARMAS", "model":"vortex-x", "bonus":83, "desc":"Canhao de plasma epico"},
    {"name":"PULSAR-7", "category":"ARMAS", "model":"pulsar-7", "bonus":56, "desc":"Laser tatico de precisao"},
    {"name":"FALCAO", "category":"ARMAS", "model":"falcao", "bonus":36, "desc":"Autocanhao de patrulha"},
    {"name":"CATACLISMO", "category":"ARMAS", "model":"cataclismo", "bonus":125, "desc":"Lancador de misseis estrategico: demo"},
    {"name":"RAIO CELESTE", "category":"ARMAS", "model":"raio-celeste", "bonus":79, "desc":"Canhao de ions especializado"},
    {"name":"SUSSURRO", "category":"ARMAS", "model":"sussurro", "bonus":66, "desc":"Rifle de precisao orbital"},
    {"name":"BRASA", "category":"ARMAS", "model":"brasa", "bonus":32, "desc":"Arma metalhadora de combate"}
]

static func get_item(item_name: String) -> Dictionary:
    for item in ITEMS:
        if str(item["name"]) == item_name:
            return item
    return {}

static func items_in_category(category: String) -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    for item in ITEMS:
        if str(item["category"]) == category:
            result.append(item)
    return result

static func model_path(item_name: String) -> String:
    var item: Dictionary = get_item(item_name)
    if item.is_empty():
        return ""
    return "res://assets/equipment/%s.glb" % str(item["model"])

static func thumbnail_path(item_name: String) -> String:
    var item: Dictionary = get_item(item_name)
    if item.is_empty():
        return ""
    var path: String = "res://assets/ui/catalog/%s.webp" % str(item["model"])
    return path if ResourceLoader.exists(path) else ""
