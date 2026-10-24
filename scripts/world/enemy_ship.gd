extends Node3D
## G0.3: NPC 3D local. Não representa entidades reais do servidor.

var npc_id := ""
var display_name := ""
var home := Vector3.ZERO
var hp := 0.0
var max_hp := 0.0
var shield := 0.0
var max_shield := 0.0
var damage := 0.0
var speed := 0.0
var aggressive := false
var alive := true
var respawn_left := 0.0
var attack_clock := 0.0
var elapsed := 0.0
var visual: Node3D
var name_tag: Label3D

func setup(kind: String, display: String, model_path: String, where: Vector3, hp_max: float, shield_max: float, attack_damage: float, move_speed: float) -> void:
    npc_id = kind
    display_name = display
    home = where
    position = where
    max_hp = hp_max
    max_shield = shield_max
    hp = max_hp
    shield = max_shield
    damage = attack_damage
    speed = move_speed
    attack_clock = randf_range(0.3, 1.6)
    var scene := load(model_path) as PackedScene
    if scene != null:
        visual = scene.instantiate() as Node3D
        if visual != null:
            add_child(visual)
            visual.scale = Vector3.ONE * 0.86
    if visual == null:
        var placeholder := MeshInstance3D.new()
        var fallback := SphereMesh.new()
        fallback.radius = 1.2
        fallback.height = 2.4
        placeholder.mesh = fallback
        add_child(placeholder)
    name_tag = Label3D.new()
    name_tag.text = display_name
    name_tag.position = Vector3(0, 3.6, 0)
    name_tag.font_size = 36
    name_tag.pixel_size = 0.012
    name_tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    name_tag.no_depth_test = true
    name_tag.modulate = Color(1.0, 0.72, 0.64)
    add_child(name_tag)
    set_targeted(false)

func tick(delta: float, player_pos: Vector3) -> void:
    if not alive:
        respawn_left -= delta
        if respawn_left <= 0.0:
            _revive()
        return
    elapsed += delta
    var before := position
    var want_heading := rotation.y
    var facing_player := aggressive and position.distance_to(player_pos) < 75.0
    if facing_player:
        var direction := player_pos - position
        direction.y = 0.0
        if direction.length() > 16.0:
            position += direction.normalized() * speed * delta
        # Mesmo quando parado atacando, o NPC aponta para a nave do jogador.
        if direction.length_squared() > 0.01:
            want_heading = atan2(direction.x, direction.z)
    else:
        var drift := home + Vector3(sin(elapsed * 0.47 + float(get_instance_id() % 7)) * 7.0, 0.0, cos(elapsed * 0.35 + float(get_instance_id() % 11)) * 6.0)
        position = position.lerp(drift, minf(delta * 0.6, 1.0))
        var move_vector := position - before
        if move_vector.length_squared() > 0.00001:
            want_heading = atan2(move_vector.x, move_vector.z)
    position.x = clampf(position.x, -112.0, 112.0)
    position.z = clampf(position.z, -82.0, 82.0)
    rotation.y = lerp_angle(rotation.y, want_heading, minf(delta * 5.2, 1.0))
    if aggressive:
        attack_clock -= delta

func apply_hit(amount: float) -> bool:
    if not alive:
        return false
    aggressive = true
    var amount_remaining := maxf(amount, 0.0)
    var absorbed := minf(shield, amount_remaining)
    shield -= absorbed
    amount_remaining -= absorbed
    hp = maxf(0.0, hp - amount_remaining)
    if hp <= 0.0:
        alive = false
        respawn_left = 11.0
        visible = false
        return true
    return false

func set_targeted(selected: bool) -> void:
    if name_tag != null:
        name_tag.visible = alive and selected
        name_tag.modulate = Color(1.0, 0.93, 0.36) if selected else Color(1.0, 0.72, 0.64)

func _revive() -> void:
    alive = true
    visible = true
    aggressive = false
    hp = max_hp
    shield = max_shield
    position = home
    attack_clock = 2.0
    set_targeted(false)
