extends Node3D
## G0.3 Mundo Vivo: NPCs, seleção de alvos, lasers e drops locais.
## NÃO envia requisições, NÃO altera inventário, créditos, STL ou progresso.

signal incoming_damage(amount: float)
signal enemy_destroyed(enemy_name: String, map_id: String, position: Vector3)
signal loot_collected(map_id: String)
signal loot_resources_collected(map_id: String, resource_name: String, amount: int)
signal astral_wave_finished(wave_number: int)

const Enemy = preload("res://scripts/world/enemy_ship.gd")
const NpcCatalog = preload("res://scripts/data/npc_catalog.gd")
const NPC_DROP_RESOURCES: Dictionary = {
    "scavenger":{"Ferron":10,"Virel":10},
    "scavenger_scout":{"Ferron":12,"Virel":12},
    "vrax":{"Ferron":20,"Virel":20,"Cryon":20},
    "zyron":{"Ferron":40,"Virel":40,"Cryon":40,"Ferrite":2,"Duracite":2},
    "kharon":{"Ferron":80,"Virel":80,"Cryon":80,"Ferrite":8,"Duracite":8,"Solarium":1},
    "dreadnox":{"Ferron":100,"Virel":100,"Cryon":100,"Ferrite":16,"Duracite":16,"Solarium":2},
    "colossar":{"Ferron":200,"Virel":200,"Cryon":200,"Ferrite":32,"Duracite":32,"Solarium":4}
}
const LASER_RANGE := 78.0
const LASER_INTERVAL := 0.42
const NPC_POOL := [
    ["scavenger", "Scavenger", 1000.0, 350.0, 175.0, 3.8],
    ["scavenger_scout", "Scavenger Scout", 700.0, 200.0, 125.0, 4.2],
    ["kharon", "Kharon", 1800.0, 550.0, 240.0, 3.1],
    ["zyron", "Zyron", 2150.0, 700.0, 290.0, 3.3],
    ["colossar", "Colossar", 2500.0, 950.0, 360.0, 2.7],
    ["vrax", "Vrax", 2900.0, 1100.0, 410.0, 2.8],
    ["dreadnox", "Dreadnox", 3100.0, 1200.0, 465.0, 3.0]
]
const ELITE_POOL := [
    ["batedor_fenda", "Batedor da Fenda", 3100.0, 1400.0, 450.0, 4.5],
    ["corsario_vazio", "Corsário do Vazio", 3900.0, 1700.0, 500.0, 3.3],
    ["ceifador_astral", "Ceifador Astral", 4600.0, 2100.0, 600.0, 3.1],
    ["guardiao_nexus", "Guardião Nexus", 5200.0, 2400.0, 680.0, 2.8]
]

var player_node: Node3D
var enemies: Array[Enemy] = []
var selected: Enemy
var laser_clock := 0.0
var missile_clock := 0.0
var player_laser_damage := 425.0
var kills := 0
var map_kills := 0
var effects: Array[Dictionary] = []
var beam_pool: Array[MeshInstance3D] = []
var beam_materials: Dictionary = {}
const MAX_BEAMS := 18
var loot_root: Node3D
var enemy_root: Node3D
var effects_root: Node3D
var drops: Array[Dictionary] = []
var live_map := "1-1"
var active_astral_wave: int = 0
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
    active_astral_wave = 0
    selected = null
    map_kills = 0
    laser_clock = 0.0
    missile_clock = 0.0
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
        var node: MeshInstance3D = item["node"]
        if is_instance_valid(node):
            node.visible = false
            beam_pool.append(node)
    effects.clear()
    if map_id.begins_with("4-"):
        _message("4-X: PvP reservado. Sem NPC comum.")
        return
    var pool := ELITE_POOL if map_id.begins_with("U-") else NPC_POOL
    var map_rank := 3 if map_id.begins_with("U-") else (int(map_id.split("-")[1]) if map_id.split("-").size() > 1 else 1)
    var amount: int = 6 if map_id.begins_with("U-") else mini(12 + int(map_rank / 2), 17)
    var rng := RandomNumberGenerator.new()
    rng.seed = int(abs(hash("npc-spawn:" + map_id)))
    for i in range(amount):
        var spawn := Vector3.ZERO
        for attempt in range(30):
            spawn = Vector3(rng.randf_range(-330.0, 330.0), 0.0, rng.randf_range(-238.0, 238.0))
            var good: bool = spawn.length() > 36.0
            if map_id.ends_with("-1") and spawn.distance_to(Vector3(0.0, 0.0, 44.0)) < 35.0:
                good = false
            for portal in portal_positions:
                if spawn.distance_to(portal) < 20.0:
                    good = false
                    break
            if good:
                break
        var spec: Array = pool[(i + map_rank - 1) % pool.size()]
        var model := "res://assets/npcs/%s.glb" % str(spec[0])
        var enemy := Enemy.new()
        enemy.name = "Enemy_%d" % i
        enemy_root.add_child(enemy)
        var factor := 1.0 + 0.13 * float(map_rank - 1)
        enemy.setup(str(spec[0]), NpcCatalog.display_name(str(spec[0])), model, spawn, float(spec[2]) * factor, float(spec[3]) * factor, float(spec[4]) * factor, float(spec[5]))
        enemies.append(enemy)
    _message("NPCs locais carregados: %d" % enemies.size())

## As ondas usam os GLBs FULL dos NPCs: nenhum LOD simplificado.
func configure_astral(arena_map: String, wave_number: int) -> void:
    configure("4-1", [])  # limpa NPCs sem gerar patrulhas de PvP.
    live_map = arena_map
    active_astral_wave = wave_number
    var picks: Array[String] = []
    match arena_map:
        "A-AURORA": picks = ["scavenger_prime", "vrax", "kharon", "zyron"]
        "A-NEXUS": picks = ["guardiao_nexus", "colossar_prime", "kharon_prime", "zyron"]
        "A-ECLIPSE": picks = ["ceifador_astral", "ceifador_astral_prime", "dreadnox", "corsario_vazio"]
        _: picks = ["scavenger"]
    var count: int = 2 + wave_number
    for i in range(count):
        var code: String = picks[(i + wave_number - 1) % picks.size()]
        var enemy: Enemy = Enemy.new()
        enemy.name = "Astral_%d_%d" % [wave_number, i]
        enemy_root.add_child(enemy)
        var angle: float = TAU * float(i) / float(count)
        var radius: float = 34.0 + 8.0 * float((i + wave_number) % 2)
        var place: Vector3 = Vector3(sin(angle) * radius,0.0,cos(angle) * radius)
        var level: float = 1.0 + float(wave_number) * 0.48
        enemy.setup(code,NpcCatalog.display_name(code),"res://assets/npcs/%s.glb" % code,place,1350.0 * level,640.0 * level,120.0 * level,3.0)
        enemy.respawn_allowed = false
        enemies.append(enemy)
    _message("PORTAL %s: ONDA %d / 3" % [arena_map.trim_prefix("A-"),wave_number])

func _process(delta: float) -> void:
    if player_node == null:
        return
    laser_clock = maxf(0.0, laser_clock - delta)
    missile_clock = maxf(0.0, missile_clock - delta)
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
            var node: MeshInstance3D = effects[i]["node"]
            if is_instance_valid(node):
                node.visible = false
                beam_pool.append(node)
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

## Picking por posição projetada: não precisa carregar colisores físicos dos GLBs.
## Prioridade para NPCs vivos, não seleciona naves atrás da câmera.
func enemy_at_screen(screen_point: Vector2, camera: Camera3D) -> Node3D:
    var best: Enemy = null
    var best_score := INF
    for enemy in enemies:
        if not is_instance_valid(enemy) or not enemy.alive:
            continue
        var center: Vector3 = enemy.global_position + Vector3(0.0, 1.2, 0.0)
        if camera.is_position_behind(center):
            continue
        var pixel: Vector2 = camera.unproject_position(center)
        var distance_px := pixel.distance_to(screen_point)
        var world_distance := camera.global_position.distance_to(center)
        var hit_radius := clampf(960.0 / maxf(world_distance, 5.0), 30.0, 59.0)
        if distance_px <= hit_radius and distance_px < best_score:
            best_score = distance_px
            best = enemy
    return best

func select_enemy(unit: Node3D) -> bool:
    if not (unit is Enemy) or not is_instance_valid(unit) or not (unit as Enemy).alive:
        return false
    _set_selected(unit as Enemy)
    return true

func get_selected_enemy() -> Node3D:
    if selected != null and is_instance_valid(selected) and selected.alive:
        return selected
    return null

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
        _message("Toque em um NPC antes de disparar")
        return
    if player_node.position.distance_to(selected.position) > LASER_RANGE:
        _message("FORA DE ALCANCE: aproxime-se do alvo")
        laser_clock = 0.3
        return
    laser_clock = LASER_INTERVAL
    _draw_beam(player_node.global_position + Vector3.UP * 0.3, selected.global_position + Vector3.UP * 0.3, Color(0.4, 0.9, 1.0))
    var destroyed: bool = selected.apply_hit(player_laser_damage)
    if destroyed:
        _destroy_enemy(selected)

# Míssil local demonstrativo. Não utiliza saldo de munição, não há economia.
func fire_missile_from_player() -> void:
    if player_node == null or missile_clock > 0.0:
        return
    if selected == null or not is_instance_valid(selected) or not selected.alive:
        return
    if player_node.position.distance_to(selected.position) > LASER_RANGE:
        return
    missile_clock = 2.0
    _draw_beam(player_node.global_position + Vector3.UP * 0.45, selected.global_position + Vector3.UP * 0.45, Color(1.0, 0.64, 0.2))
    if selected.apply_hit(1100.0):
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
    _spawn_local_drop(enemy.position, enemy.npc_id)
    enemy_destroyed.emit(enemy.display_name, live_map, enemy.position)
    _message("%s destruído! +1 eliminação de teste" % enemy.display_name)
    selected = null
    if active_astral_wave > 0:
        var all_destroyed: bool = true
        for foe in enemies:
            if is_instance_valid(foe) and foe.alive:
                all_destroyed = false
                break
        if all_destroyed:
            var cleared_wave: int = active_astral_wave
            active_astral_wave = 0
            astral_wave_finished.emit(cleared_wave)

func _spawn_local_drop(where: Vector3, npc_id: String) -> void:
    if drops.size() >= 8:
        return
    var asset: PackedScene = load("res://assets/loot/box_loot.glb") as PackedScene
    if asset == null:
        return
    var box: Node3D = asset.instantiate() as Node3D
    if box == null:
        return
    loot_root.add_child(box)
    box.position = where + Vector3.UP * 0.25
    box.scale = Vector3.ONE * 1.12
    var payload: Dictionary = NPC_DROP_RESOURCES.get(npc_id, {"Ferron":12,"Cryon":10})
    drops.append({"node":box, "time":30.0, "resources":payload.duplicate(true), "counted":false})

## Caixas NPC no minimapa; não devem ser confundidas com bonus independentes.
func loot_positions() -> Array[Vector3]:
    var result: Array[Vector3] = []
    for drop in drops:
        var node: Node3D = drop["node"]
        if is_instance_valid(node):
            result.append(node.global_position)
    return result

func loot_at_screen(screen_point: Vector2, camera: Camera3D) -> Dictionary:
    var best: Dictionary = {}
    var best_pixels: float = 43.0
    for drop in drops:
        var node: Node3D = drop["node"]
        if not is_instance_valid(node):
            continue
        var center: Vector3 = node.global_position + Vector3.UP * 0.7
        if camera.is_position_behind(center):
            continue
        var pixels: float = camera.unproject_position(center).distance_to(screen_point)
        if pixels < best_pixels:
            best_pixels = pixels
            best = {"position":node.global_position}
    return best

func collect_nearby(player_pos: Vector3, cargo, ship_name: String, equipment) -> void:
    var fitted_modules: Array = equipment.equipped_modules() if equipment != null else []
    var has_aux: bool = equipment != null and equipment.fitted_aux == "AUX-9"
    var pickup_radius: float = 15.0 if has_aux and fitted_modules.has("Coletor de Cargas") else 7.5
    for i in range(drops.size() - 1, -1, -1):
        var box: Node3D = drops[i]["node"]
        if not is_instance_valid(box):
            drops.remove_at(i)
            continue
        if box.global_position.distance_to(player_pos) > pickup_radius:
            continue
        var resources: Dictionary = drops[i].get("resources", {})
        var collected_amount: int = 0
        for name in resources.keys():
            var picked: int = cargo.add_resource(str(name), int(resources[name]), ship_name, equipment)
            if picked <= 0:
                continue
            resources[name] = int(resources[name]) - picked
            collected_amount += picked
            loot_resources_collected.emit(live_map, str(name), picked)
            if int(resources[name]) <= 0:
                resources.erase(name)
        if collected_amount <= 0:
            continue
        if not bool(drops[i].get("counted", false)):
            drops[i]["counted"] = true
            cargo.loot_collected += 1
            cargo._save()
            loot_collected.emit(live_map)
        if resources.is_empty():
            box.queue_free()
            drops.remove_at(i)
        else:
            drops[i]["resources"] = resources
        _message("Loot recolhido! +%d recursos (OFFLINE)" % collected_amount)

## Reutiliza malhas de laser; evita alocar geometria/material a cada disparo.
## Máximo 18 raios simultâneos de teste para proteger celulares modestos.
func _draw_beam(a: Vector3, b: Vector3, tint: Color) -> void:
    var length := a.distance_to(b)
    if length < 0.1:
        return
    var beam: MeshInstance3D = null
    if beam_pool.size() > 0:
        beam = beam_pool.pop_back()
    elif effects.size() < MAX_BEAMS:
        beam = MeshInstance3D.new()
        var cylinder := CylinderMesh.new()
        cylinder.top_radius = 0.065
        cylinder.bottom_radius = 0.065
        cylinder.height = 1.0
        cylinder.radial_segments = 6
        beam.mesh = cylinder
        effects_root.add_child(beam)
    if beam == null:
        return
    var material_key := tint.to_html(false)
    if not beam_materials.has(material_key):
        var mat := StandardMaterial3D.new()
        mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        mat.albedo_color = tint
        mat.emission_enabled = true
        mat.emission = tint
        beam_materials[material_key] = mat
    beam.material_override = beam_materials[material_key]
    beam.global_position = (a + b) * 0.5
    beam.quaternion = Quaternion(Vector3.UP, (b - a).normalized())
    beam.scale = Vector3(1.0, length, 1.0)
    beam.visible = true
    effects.append({"node": beam, "time": 0.16})

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
