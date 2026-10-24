extends Node3D
## G0.3 Mundo Vivo: NPCs, seleção de alvos, lasers e drops locais.
## NÃO envia requisições, NÃO altera inventário, créditos, STL ou progresso.

signal incoming_damage(amount: float)

const Enemy = preload("res://scripts/world/enemy_ship.gd")
const LASER_RANGE := 78.0
const LASER_INTERVAL := 0.42
const NPC_POOL := [
    ["streuner", "Streuner", 1000.0, 350.0, 175.0, 3.8],
    ["recruitStreuner", "Recruta Streuner", 700.0, 200.0, 125.0, 4.2],
    ["mordon", "Mordon", 1800.0, 550.0, 240.0, 3.1],
    ["saimon", "Saimon", 2150.0, 700.0, 290.0, 3.3],
    ["sibelon", "Sibelon", 2500.0, 950.0, 360.0, 2.7],
    ["lordakia", "Lordakia", 2900.0, 1100.0, 410.0, 2.8],
    ["devolarium", "Devolarium", 3100.0, 1200.0, 465.0, 3.0]
]
const ELITE_POOL := [
    ["riftScout", "Rift Scout", 3100.0, 1400.0, 450.0, 4.5],
    ["voidCorsair", "Void Corsair", 3900.0, 1700.0, 500.0, 3.3],
    ["astralReaper", "Astral Reaper", 4600.0, 2100.0, 600.0, 3.1],
    ["nexusWarden", "Nexus Warden", 5200.0, 2400.0, 680.0, 2.8]
]

var player_node: Node3D
var enemies: Array[Enemy] = []
var selected: Enemy
var laser_clock := 0.0
var kills := 0
var map_kills := 0
var effects: Array[Dictionary] = []
var loot_root: Node3D
var enemy_root: Node3D
var effects_root: Node3D
var drops: Array[Dictionary] = []
var live_map := "1-1"
var status_message := "Selecione um NPC para testar o combate"
var status_clock := 4.0

func _ready() -> void:
    enemy_root = Node3D.new()
    enemy_root.name = "EnemyShips"
    add_child(enemy_root)
    loot_root = Node3D.new()
    loot_root.name = "LocalLoot"
    add_child(loot_root)
    effects_root = Node3D.new()
    effects_root.name = "Lasers"
    add_child(effects_root)

func configure(map_id: String, portal_positions: Array[Vector3]) -> void:
    live_map = map_id
    selected = null
    map_kills = 0
    laser_clock = 0.0
    for unit in enemies:
        if is_instance_valid(unit):
            unit.free()
    enemies.clear()
    for drop in drops:
        var node: Node3D = drop["node"]
        if is_instance_valid(node):
            node.free()
    drops.clear()
    for item in effects:
        var node: Node3D = item["node"]
        if is_instance_valid(node):
            node.free()
    effects.clear()
    if map_id.begins_with("4-"):
        _message("4-X: PvP reservado. Sem NPC comum.")
        return
    var pool := ELITE_POOL if map_id.begins_with("U-") else NPC_POOL
    var map_rank := 3 if map_id.begins_with("U-") else (int(map_id.split("-")[1]) if map_id.split("-").size() > 1 else 1)
    var amount := 4 if map_id.begins_with("U-") else mini(6 + map_rank / 3, 9)
    var rng := RandomNumberGenerator.new()
    rng.seed = int(abs(hash("npc-spawn:" + map_id)))
    for i in range(amount):
        var spawn := Vector3.ZERO
        for attempt in range(30):
            spawn = Vector3(rng.randf_range(-97, 97), 0.0, rng.randf_range(-69, 69))
            var good := spawn.length() > 27.0
            for portal in portal_positions:
                if spawn.distance_to(portal) < 17.0:
                    good = false
                    break
            if good:
                break
        var spec: Array = pool[(i + map_rank - 1) % pool.size()]
        var model := "res://assets/npcs/npc_%s.glb" % str(spec[0])
        var enemy := Enemy.new()
        enemy.name = "NPC_%d_%s" % [i, spec[0]]
        enemy_root.add_child(enemy)
        var factor := 1.0 + 0.13 * float(map_rank - 1)
        enemy.setup(str(spec[0]), str(spec[1]), model, spawn, float(spec[2]) * factor, float(spec[3]) * factor, float(spec[4]) * factor, float(spec[5]))
        enemies.append(enemy)
    _message("NPCs locais carregados: %d" % enemies.size())

func _process(delta: float) -> void:
    if player_node == null:
        return
    laser_clock = maxf(0.0, laser_clock - delta)
    status_clock = maxf(0.0, status_clock - delta)
    for enemy in enemies:
        if not is_instance_valid(enemy):
            continue
        enemy.tick(delta, player_node.position)
        if enemy.alive and enemy.aggressive and enemy.attack_clock <= 0.0 and enemy.position.distance_to(player_node.position) < 59.0:
            enemy.attack_clock = 2.15
            _draw_beam(enemy.global_position + Vector3.UP * 0.4, player_node.global_position + Vector3.UP * 0.4, Color(1.0, 0.38, 0.3))
            incoming_damage.emit(enemy.damage)
    for i in range(effects.size() - 1, -1, -1):
        effects[i]["time"] = float(effects[i]["time"]) - delta
        if float(effects[i]["time"]) <= 0.0:
            var node: Node3D = effects[i]["node"]
            if is_instance_valid(node):
                node.queue_free()
            effects.remove_at(i)
    for i in range(drops.size() - 1, -1, -1):
        drops[i]["time"] = float(drops[i]["time"]) - delta
        if float(drops[i]["time"]) <= 0.0:
            var box: Node3D = drops[i]["node"]
            if is_instance_valid(box):
                box.queue_free()
            drops.remove_at(i)
    if selected != null and (not is_instance_valid(selected) or not selected.alive):
        selected = null

func select_nearest() -> void:
    if player_node == null:
        return
    var candidates: Array[Enemy] = []
    for enemy in enemies:
        if is_instance_valid(enemy) and enemy.alive:
            candidates.append(enemy)
    candidates.sort_custom(func(a: Enemy, b: Enemy) -> bool: return a.position.distance_squared_to(player_node.position) < b.position.distance_squared_to(player_node.position))
    if candidates.is_empty():
        selected = null
        _message("Nenhum NPC disponível neste mapa")
        return
    var index := candidates.find(selected)
    var next_index := 0 if index < 0 else (index + 1) % candidates.size()
    _set_selected(candidates[next_index])

func _set_selected(unit: Enemy) -> void:
    if selected != null and is_instance_valid(selected):
        selected.set_targeted(false)
    selected = unit
    if selected != null:
        selected.set_targeted(true)
        _message("Alvo: " + selected.display_name)

func fire_from_player() -> void:
    if player_node == null or laser_clock > 0.0:
        return
    if selected == null or not is_instance_valid(selected) or not selected.alive:
        select_nearest()
    if selected == null:
        return
    if player_node.position.distance_to(selected.position) > LASER_RANGE:
        _message("FORA DE ALCANCE: aproxime-se do alvo")
        laser_clock = 0.3
        return
    laser_clock = LASER_INTERVAL
    _draw_beam(player_node.global_position + Vector3.UP * 0.3, selected.global_position + Vector3.UP * 0.3, Color(0.4, 0.9, 1.0))
    var destroyed: bool = selected.apply_hit(425.0)
    if destroyed:
        _destroy_enemy(selected)

func support_hit(from_position: Vector3, amount: float) -> void:
    if selected == null or not is_instance_valid(selected) or not selected.alive:
        return
    if player_node.position.distance_to(selected.position) > LASER_RANGE:
        return
    _draw_beam(from_position, selected.global_position, Color(0.75, 1.0, 0.42))
    if selected.apply_hit(amount):
        _destroy_enemy(selected)

func _destroy_enemy(enemy: Enemy) -> void:
    kills += 1
    map_kills += 1
    _spawn_local_drop(enemy.position)
    _message("%s destruído! +1 eliminação de teste" % enemy.display_name)
    selected = null

func _spawn_local_drop(where: Vector3) -> void:
    if drops.size() >= 8:
        return
    var asset := load("res://assets/loot/box_loot.glb") as PackedScene
    if asset == null:
        return
    var box := asset.instantiate() as Node3D
    if box == null:
        return
    loot_root.add_child(box)
    box.position = where
    box.scale = Vector3.ONE * 0.8
    drops.append({"node": box, "time": 18.0})

func _draw_beam(a: Vector3, b: Vector3, tint: Color) -> void:
    var length := a.distance_to(b)
    if length < 0.1:
        return
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.07
    mesh.bottom_radius = 0.07
    mesh.height = length
    mesh.radial_segments = 6
    var mat := StandardMaterial3D.new()
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.albedo_color = tint
    mat.emission_enabled = true
    mat.emission = tint
    mesh.material = mat
    var beam := MeshInstance3D.new()
    beam.mesh = mesh
    effects_root.add_child(beam)
    beam.global_position = (a + b) * 0.5
    beam.quaternion = Quaternion(Vector3.UP, (b - a).normalized())
    effects.append({"node": beam, "time": 0.14})

func enemy_positions() -> Array[Vector3]:
    var result: Array[Vector3] = []
    for enemy in enemies:
        if is_instance_valid(enemy) and enemy.alive:
            result.append(enemy.position)
    return result

func target_status() -> Dictionary:
    if selected == null or not is_instance_valid(selected) or not selected.alive or player_node == null:
        return {}
    return {"name": selected.display_name, "hp": selected.hp, "max_hp": selected.max_hp, "shield": selected.shield, "max_shield": selected.max_shield, "distance": player_node.position.distance_to(selected.position)}

func _message(value: String) -> void:
    status_message = value
    status_clock = 2.6
