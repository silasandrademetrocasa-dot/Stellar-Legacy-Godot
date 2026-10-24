extends Node3D
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

func _ready() -> void:
    drones_root = Node3D.new()
    drones_root.name = "Drones"
    add_child(drones_root)
    aux_root = Node3D.new()
    aux_root.name = "AUX9"
    add_child(aux_root)
    for i in range(2):
        var drone_id := "drone_a" if i == 0 else "drone_b"
        var resource := load("res://assets/drones/%s.glb" % drone_id) as PackedScene
        if resource != null:
            var instance := resource.instantiate() as Node3D
            if instance != null:
                drones_root.add_child(instance)
                instance.scale = Vector3.ONE * 0.55
                drone_models.append(instance)
    var aux_asset := load("res://assets/aux/aux9.glb") as PackedScene
    if aux_asset != null:
        aux_model = aux_asset.instantiate() as Node3D
        if aux_model != null:
            aux_root.add_child(aux_model)
            aux_model.scale = Vector3.ONE * 0.55

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

func toggle_drones() -> void:
    drones_enabled = not drones_enabled

func toggle_aux() -> void:
    aux_enabled = not aux_enabled

func snap_to_player() -> void:
    if player_node == null:
        return
    for i in range(drone_models.size()):
        var phase := TAU * float(i) / maxf(1.0, float(drone_models.size()))
        drone_models[i].global_position = player_node.global_position + Vector3(cos(phase) * 5.5, 0.9, sin(phase) * 5.5)
    if aux_model != null:
        aux_model.global_position = player_node.global_position + Vector3(-3.7, 0.4, 3.2)
