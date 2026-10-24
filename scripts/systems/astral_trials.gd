extends RefCounted
## Progresso puramente LOCAL dos Portais Astrais. Entrada pelos X-8, três ondas PvE.
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
var clears: Dictionary = {"A-AURORA":0,"A-NEXUS":0,"A-ECLIPSE":0}
var best_wave: Dictionary = {"A-AURORA":0,"A-NEXUS":0,"A-ECLIPSE":0}

func _init() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
    if data is Dictionary:
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
        _save()
        return true
    wave += 1
    _save()
    return false

func _save() -> void:
    var f: FileAccess = FileAccess.open(SAVE_PATH,FileAccess.WRITE)
    if f != null:
        f.store_string(JSON.stringify({"clears":clears,"best_wave":best_wave}))

func status(kind: String) -> String:
    return "%s  |  MELHOR ONDA %d/%d  |  VITORIAS %d" % [str(ARENAS[kind]["difficulty"]), int(best_wave.get(kind,0)), TOTAL_WAVES, int(clears.get(kind,0))]
