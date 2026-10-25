extends RefCounted
## Inventario offline G0.15 - nomes proprios Stellar Legacy. Nenhum ID de banco antigo.
const SLOTS := {"ARMAS": 16, "ESCUDOS": 21, "MOTORES": 21, "EXTRAS": 14}
const CATEGORY_NAMES := ["ARMAS", "ESCUDOS", "MOTORES", "EXTRAS"]
const ITEMS := [
    {"name":"REPARADOR COMUM", "category":"EXTRAS", "model":"reparador-comum", "bonus":1, "desc":"Reparador basico de casco e sistemas"},
    {"name":"ARC-1", "category":"ARMAS", "model":"arc-1", "bonus":75, "desc":"Laser de energia azul / nivel inicial"},
    {"name":"ARC-2", "category":"ARMAS", "model":"arc-2", "bonus":160, "desc":"Laser de pulso rubro / dano estendido"},
    {"name":"ARC-4", "category":"ARMAS", "model":"arc-4", "bonus":235, "desc":"Laser avancado com nucleos de plasma"},
    {"name":"SG-1", "category":"ESCUDOS", "model":"sg-1", "bonus":350, "desc":"Gerador esferico de escudo leve"},
    {"name":"SG-2", "category":"ESCUDOS", "model":"sg-2", "bonus":650, "desc":"Gerador aprimorado de protecao"},
    {"name":"SG-3", "category":"ESCUDOS", "model":"sg-3", "bonus":1000, "desc":"Gerador reforcado de campo energetico"},
    {"name":"THR-1", "category":"MOTORES", "model":"thr-1", "bonus":3, "desc":"Propulsao compacta e estavel"},
    {"name":"THR-2", "category":"MOTORES", "model":"thr-2", "bonus":4, "desc":"Propulsor dual de longo alcance"},
    {"name":"THR-3", "category":"MOTORES", "model":"thr-3", "bonus":6, "desc":"Propulsor triplo de alto desempenho"},
    {"name":"AUTO-AIM", "category":"EXTRAS", "model":"auto-aim", "bonus":1, "desc":"Sensor tatico de mira automatizada"},
    {"name":"NANOBOT REP-2", "category":"EXTRAS", "model":"nanobot_rep-2", "bonus":1, "desc":"Microdrones de reparacao local"},
    {"name":"RELOAD BOOSTER", "category":"EXTRAS", "model":"reload_booster", "bonus":1, "desc":"Estabilizador de cadencia de lasers"},
    {"name":"VSH-0", "category":"ESCUDOS", "model":"vsh-0", "bonus":380, "desc":"Protecao esferica original"},
    {"name":"VSH-1", "category":"ESCUDOS", "model":"vsh-1", "bonus":1500, "desc":"Escudo esferico reforcado"},
    {"name":"VSH-2", "category":"ESCUDOS", "model":"vsh-2", "bonus":5000, "desc":"Escudo esferico estabilizado"},
    {"name":"VSH-3", "category":"ESCUDOS", "model":"vsh-3", "bonus":7600, "desc":"Escudo de singularidade"},
    {"name":"VSH-4", "category":"ESCUDOS", "model":"vsh-4", "bonus":11500, "desc":"Escudo epico de combate"},
    {"name":"VSH-5", "category":"ESCUDOS", "model":"vsh-5", "bonus":14500, "desc":"Escudo protetor avancado"},
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
    {"name":"BRASA", "category":"ARMAS", "model":"brasa", "bonus":32, "desc":"Arma metalhadora de combate"},
    {"name": "Repositor Automático", "category": "EXTRAS", "model": "repositor-automatico", "bonus": 1, "desc": "Compra automaticamente novo pacote da munição laser e do míssil selecionados quando o estoque estiver baixo."},
    {"name": "Mira Autônoma", "category": "EXTRAS", "model": "mira-autonoma", "bonus": 1, "desc": "Ao selecionar um alvo, inicia o laser automaticamente."},
    {"name": "Lançador Autônomo", "category": "EXTRAS", "model": "lancador-autonomo", "bonus": 1, "desc": "Dispara automaticamente o míssil selecionado durante o combate."},
    {"name": "Módulo de Porão Comum", "category": "EXTRAS", "model": "modulo-porao-comum", "bonus": 1, "desc": "Enquanto equipado, aumenta a capacidade do porão da nave ativa em +3.000 unidades. Não acumula com a versão Elite."},
    {"name": "Módulo de Porão Elite", "category": "EXTRAS", "model": "modulo-porao-elite", "bonus": 1, "desc": "Enquanto equipado, aumenta a capacidade do porão da nave ativa em +10.000 unidades. Não acumula com a versão Comum."},
    {"name": "Expansor de Extras Comum", "category": "EXTRAS", "model": "expansor-extras-comum", "bonus": 1, "desc": "Enquanto equipada, libera +4 slots EXTRAS adicionais na nave ativa. Não acumula com a versão Elite."},
    {"name": "Expansor de Extras Elite", "category": "EXTRAS", "model": "expansor-extras-elite", "bonus": 1, "desc": "Enquanto equipada, libera +9 slots EXTRAS adicionais na nave ativa. Não acumula com a versão Comum."},
    {"name": "Terminal Mercante Remoto", "category": "EXTRAS", "model": "terminal-mercante-remoto", "bonus": 1, "desc": "EXTRA Elite: enquanto equipado, permite vender recursos diretamente na aba Refinaria do Hangar em qualquer setor, sem retorno à base. Venda manual, nunca automática."},
    {"name": "Nanobot de Reparo Comum", "category": "EXTRAS", "model": "nanobot_rep-2", "bonus": 1, "desc": "Após 5s sem receber dano, repara +5.000 HP por segundo. O escudo regenera +10.000 por segundo."},
    {"name": "Nanobot de Reparo Elite", "category": "EXTRAS", "model": "nanobot-reparo-elite", "bonus": 1, "desc": "Após 5s sem receber dano, repara +10.000 HP por segundo. Enquanto equipado, o escudo regenera +15.000 por segundo."},
    {"name": "Propulsor de Recarga", "category": "EXTRAS", "model": "propulsor-recarga", "bonus": 1, "desc": "Reduz o cooldown de mísseis pela metade."},
    {"name": "AEG-1", "category": "ESCUDOS", "model": "fs-01", "bonus": 5600, "desc": "5.600 escudo • 70% absorção • +6,25% regeneração."},
    {"name": "AEG-2", "category": "ESCUDOS", "model": "fs-02", "bonus": 9000, "desc": "9.000 escudo • 78% absorção • +6,25% regeneração."},
    {"name": "THR-4", "category": "MOTORES", "model": "thr-4", "bonus": 8, "desc": "+8 velocidade."},
    {"name": "THR-5", "category": "MOTORES", "model": "thr-5", "bonus": 10, "desc": "+10 velocidade."},
    {"name": "THR-6", "category": "MOTORES", "model": "thr-6", "bonus": 12, "desc": "+12 velocidade."},
    {"name": "ARC-3", "category": "ARMAS", "model": "arc-3", "bonus": 190, "desc": "Laser Elite • dano 190 • +8% contra NPCs."},
    {"name": "ARC-P1", "category": "ARMAS", "model": "arc-p1", "bonus": 100, "desc": "Laser versátil • dano 100 (pilotos) / 90 (NPCs)."}
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
    var model_name: String = str(item["model"])
    var g015: String = "res://assets/ui/g015_models/%s.png" % model_name
    if ResourceLoader.exists(g015):
        return g015
    var path: String = "res://assets/ui/catalog/%s.webp" % model_name
    return path if ResourceLoader.exists(path) else ""
