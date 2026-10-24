extends RefCounted
## Progresso OFFLINE: materializador X-1, chaves locais e tres ondas PvE.
const SAVE_PATH := "user://stellar_g09_astral_trials.json"
const ARENAS := {
    "A-AURORA": {"label":"AURORA", "difficulty":"EXPLORACAO", "description":"Ressonancia cian e patrulhas da aurora", "reward":800},
    "A-NEXUS": {"label":"NEXUS", "difficulty":"ELITE", "description":"Distorsao de energia e guardioes", "reward":1600},
    "A-ECLIPSE": {"label":"ECLIPSE", "difficulty":"EXTREMO", "description":"Fenda vermelha e nucleo instavel", "reward":3000},
}
const TOTAL_WAVES := 3
var map_id: String = ""
var wave: int = 1
var finished: bool = false
# Economia local isolada da producao: fragmentos ganhos em combate/coleta.
const KEY_COSTS := {"A-AURORA": 4, "A-NEXUS": 9, "A-ECLIPSE": 15}
var fragments: int = 22
var keys: Dictionary = {"A-AURORA": 1, "A-NEXUS": 0, "A-ECLIPSE": 0}
var clears: Dictionary = {"A-AURORA":0,"A-NEXUS":0,"A-ECLIPSE":0}
var best_wave: Dictionary = {"A-AURORA":0,"A-NEXUS":0,"A-ECLIPSE":0}

func _init() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
    if data is Dictionary:
        fragments = clampi(int(data.get("fragments", fragments)),0,99999)
        var saved_keys: Variant = data.get("keys", {})
        if saved_keys is Dictionary:
            for k in KEY_COSTS:
                keys[k] = clampi(int(saved_keys.get(k,keys[k])),0,999)
        for kind in ARENAS:
            clears[kind] = clampi(int(data.get("clears",{}).get(kind,0)),0,99999)
            best_wave[kind] = clampi(int(data.get("best_wave",{}).get(kind,0)),0,TOTAL_WAVES)

func begin(kind: String) -> void:
    map_id = kind
    wave = 1
    finished = false

func leave() -> void:
    map_id = ""
    wave = 1
    finished = false

func record_wave() -> bool:
    if map_id.is_empty() or finished:
        return false
    best_wave[map_id] = maxi(int(best_wave.get(map_id,0)),wave)
    if wave >= TOTAL_WAVES:
        finished = true
        clears[map_id] = int(clears.get(map_id,0)) + 1
        award_fragments(3)
        _save()
        return true
    wave += 1
    _save()
    return false

func _save() -> void:
    var f: FileAccess = FileAccess.open(SAVE_PATH,FileAccess.WRITE)
    if f != null:
        f.store_string(JSON.stringify({"clears":clears,"best_wave":best_wave,
            "fragments":fragments,"keys":keys}))

func status(kind: String) -> String:
    return "%s  |  MELHOR ONDA %d/%d  |  VITORIAS %d" % [str(ARENAS[kind]["difficulty"]), int(best_wave.get(kind,0)), TOTAL_WAVES, int(clears.get(kind,0))]

func award_fragments(amount: int) -> void:
    fragments = clampi(fragments + maxi(0,amount),0,99999)
    _save()

func materialize_key(kind: String) -> String:
    if not KEY_COSTS.has(kind):
        return "Portal desconhecido"
    var price: int = int(KEY_COSTS[kind])
    if fragments < price:
        return "Fragmentos insuficientes: %d/%d" % [fragments,price]
    fragments -= price
    keys[kind] = int(keys.get(kind,0)) + 1
    _save()
    return "CHAVE %s MATERIALIZADA (OFFLINE)" % str(ARENAS[kind]["label"])

func consume_entry(kind: String) -> bool:
    if not keys.has(kind) or int(keys[kind]) <= 0:
        return false
    keys[kind] = int(keys[kind]) - 1
    _save()
    return true

func entry_status(kind: String) -> String:
    return "CHAVES %d  |  CUSTO %d FRAG.  |  ESTOQUE %d FRAG." % [int(keys.get(kind,0)),int(KEY_COSTS.get(kind,0)),fragments]
