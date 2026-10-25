extends Node3D
const PixelSprite = preload("res://scripts/world/pixel_unit_sprite.gd")
## Suporte local da G0.3: 2 drones e AUX-9, desligáveis.
## Nenhum dano, farm ou reparo deste protótipo é gravado em produção.

var player_node: Node3D
var combat_world
var drones_root: Node3D
var aux_root: Node3D
var drone_models: Array[Node3D] = []
var aux_model: Node3D
var drones_enabled := true
var aux_enabled := true
var elapsed := 0.0
var drone_fire_clock := 1.2
var installed_signature: String = ""

func _ready() -> void:
    drones_root = Node3D.new()
    drones_root.name = "Drones"
    add_child(drones_root)
    aux_root = Node3D.new()
    aux_root.name = "AUX9"
    add_child(aux_root)
    # Inventory is applied by main after setup. Do not preload unequipped HQs.
    drones_enabled = false
    aux_enabled = false

func _refresh_fleet_models(equipped_drones: Array[String], installed_aux: String) -> void:
    var signature: String = ",".join(PackedStringArray(equipped_drones)) + "|" + installed_aux
    if signature == installed_signature:
        return
    installed_signature = signature
    for child in drones_root.get_children():
        drones_root.remove_child(child)
        child.queue_free()
    for child in aux_root.get_children():
        aux_root.remove_child(child)
        child.queue_free()
    drone_models.clear()
    aux_model = null
    var ids: Dictionary = {"Drone Alfa":"drone_a", "Drone Beta":"drone_b", "Drone Gama":"drone_c", "Drone Delta":"drone_d", "Drone Epsilon":"drone_e", "Drone Comum":"drone_common", "Drone Elite":"drone_elite", "Halo":"drone_common", "Nova":"drone_elite"}
    for drone_name in equipped_drones:
        var file_id: String = str(ids.get(drone_name, ""))
        if file_id.is_empty():
            continue
        var atlas_path := "res://assets/pixel/map_units/drones/%s.png" % file_id
        var instance: Node3D = Node3D.new()
        if ResourceLoader.exists(atlas_path):
            drones_root.add_child(instance)
            var sprite := PixelSprite.new()
            instance.add_child(sprite)
            sprite.configure(instance, atlas_path, 2.9, false)
            drone_models.append(instance)
        else:
            var model: PackedScene = load("res://assets/drones/%s.glb" % file_id) as PackedScene
            if model != null:
                instance.queue_free()
                instance = model.instantiate() as Node3D
                drones_root.add_child(instance)
                instance.scale = Vector3.ONE * 0.55
                drone_models.append(instance)
    if installed_aux == "AUX-9":
        var pixel_path := "res://assets/pixel/map_units/aux/aux9.png"
        if ResourceLoader.exists(pixel_path):
            aux_model = Node3D.new()
            aux_root.add_child(aux_model)
            var sprite := PixelSprite.new()
            aux_model.add_child(sprite)
            sprite.configure(aux_model, pixel_path, 3.2, false)
        else:
            var asset: PackedScene = load("res://assets/aux/aux9.glb") as PackedScene
            if asset != null:
                aux_model = asset.instantiate() as Node3D
                if aux_model != null:
                    aux_root.add_child(aux_model)
                    aux_model.scale = Vector3.ONE * 0.70
    drones_enabled = drone_models.size() > 0
    aux_enabled = aux_model != null
    snap_to_player()

func apply_equipment(equipment) -> void:
    if equipment == null:
        return
    _refresh_fleet_models(equipment.fitted_drones, equipment.fitted_aux)

func _process(delta: float) -> void:
    if player_node == null:
        return
    elapsed += delta
    drones_root.visible = drones_enabled
    aux_root.visible = aux_enabled
    for i in range(drone_models.size()):
        var phase := elapsed * 0.75 + TAU * float(i) / maxf(1.0, float(drone_models.size()))
        var offset := Vector3(cos(phase) * 5.5, 0.9, sin(phase) * 5.5)
        var drone := drone_models[i]
        drone.global_position = drone.global_position.lerp(player_node.global_position + offset, minf(delta * 7.0, 1.0))
        drone.rotation.y = phase
    if aux_model != null:
        var wanted := player_node.global_position + Vector3(-3.7, 0.4 + sin(elapsed * 2.4) * 0.18, 3.2)
        aux_model.global_position = aux_model.global_position.lerp(wanted, minf(delta * 5.0, 1.0))
        aux_model.rotation.y = player_node.rotation.y
    drone_fire_clock -= delta
    if drone_fire_clock <= 0.0:
        drone_fire_clock = 1.15
        if drones_enabled and combat_world != null and drone_models.size() > 0:
            combat_world.support_hit(drone_models[0].global_position, 175.0)

func snap_to_player() -> void:
    if player_node == null:
        return
    for i in range(drone_models.size()):
        var phase := TAU * float(i) / maxf(1.0, float(drone_models.size()))
        drone_models[i].global_position = player_node.global_position + Vector3(cos(phase) * 5.5, 0.9, sin(phase) * 5.5)
    if aux_model != null:
        aux_model.global_position = player_node.global_position + Vector3(-3.7, 0.4, 3.2)
