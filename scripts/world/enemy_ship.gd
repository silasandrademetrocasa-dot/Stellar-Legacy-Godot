extends Node3D
const Routes = preload("res://scripts/world_routes.gd")
const Presentation = preload("res://scripts/world/model_presentation.gd")
const NpcVisualScale = preload("res://scripts/world/npc_visual_scale.gd")
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
var respawn_allowed := true
var attack_clock := 0.0
var elapsed := 0.0
var visual: Node3D
var name_tag: Label3D
var hit_light: MeshInstance3D
var aim_ring: MeshInstance3D
var hit_clock := 0.0
var attack_flash_clock := 0.0
var muzzle_flash: MeshInstance3D

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
        var imported: Node3D = scene.instantiate() as Node3D
        if imported != null:
            visual = Presentation.create_visual(imported, NpcVisualScale.span(kind))
            visual.name = "NPC_Visual_Padronizado"
            add_child(visual)
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
    # Impacto de laser e anel de alvo: geometrias persistentes sem alocacoes por tiro.
    hit_light = MeshInstance3D.new()
    var flash := SphereMesh.new()
    flash.radius = 1.1
    flash.height = 2.2
    flash.radial_segments = 8
    flash.rings = 4
    var spark := StandardMaterial3D.new()
    spark.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    spark.albedo_color = Color(1.0, 0.56, 0.17, 0.63)
    spark.emission_enabled = true
    spark.emission = Color(1.0, 0.42, 0.08)
    spark.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    flash.material = spark
    hit_light.mesh = flash
    hit_light.visible = false
    add_child(hit_light)
    aim_ring = MeshInstance3D.new()
    var tor := TorusMesh.new()
    tor.inner_radius = 2.4
    tor.outer_radius = 2.52
    tor.rings = 24
    tor.ring_segments = 6
    var target_mat := StandardMaterial3D.new()
    target_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    target_mat.albedo_color = Color(1.0, 0.72, 0.22)
    target_mat.emission_enabled = true
    target_mat.emission = Color(0.7, 0.4, 0.06)
    tor.material = target_mat
    aim_ring.mesh = tor
    aim_ring.position.y = 0.08
    add_child(aim_ring)
    set_targeted(false)
    muzzle_flash = MeshInstance3D.new()
    muzzle_flash.name = "WeaponMuzzle"
    var muzzle_mesh := SphereMesh.new()
    muzzle_mesh.radius = 0.15
    muzzle_mesh.height = 0.3
    muzzle_mesh.radial_segments = 8
    muzzle_mesh.rings = 4
    var muzzle_material := StandardMaterial3D.new()
    muzzle_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    muzzle_material.albedo_color = Color(1.0, 0.5, 0.2)
    muzzle_material.emission_enabled = true
    muzzle_material.emission = muzzle_material.albedo_color
    muzzle_mesh.material = muzzle_material
    muzzle_flash.mesh = muzzle_mesh
    muzzle_flash.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    if visual != null:
        var box: AABB = visual.transform * Presentation.bounds(visual)
        muzzle_flash.position = Vector3(0, 0.1, box.end.z + 0.05)
    muzzle_flash.visible = false
    add_child(muzzle_flash)

func show_attack() -> void:
    attack_flash_clock = 0.12
    muzzle_flash.visible = true

func muzzle_position() -> Vector3:
    return muzzle_flash.global_position

func tick(delta: float, player_pos: Vector3) -> void:
    if not alive:
        if not respawn_allowed:
            return
        respawn_left -= delta
        if respawn_left <= 0.0:
            _revive()
        return
    elapsed += delta
    attack_flash_clock = maxf(0.0, attack_flash_clock - delta)
    muzzle_flash.visible = attack_flash_clock > 0.0
    hit_clock = maxf(0.0, hit_clock - delta)
    if hit_light != null:
        hit_light.visible = hit_clock > 0.0
        if hit_light.visible:
            hit_light.scale = Vector3.ONE * (0.65 + hit_clock * 3.0)
    if aim_ring != null and aim_ring.visible:
        aim_ring.rotation.y += delta * 1.1
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
    position.x = clampf(position.x, -Routes.BOUNDS.x + 8.0, Routes.BOUNDS.x - 8.0)
    position.z = clampf(position.z, -Routes.BOUNDS.y + 8.0, Routes.BOUNDS.y - 8.0)
    rotation.y = lerp_angle(rotation.y, want_heading, minf(delta * 5.2, 1.0))
    if aggressive:
        attack_clock -= delta

func apply_hit(amount: float) -> bool:
    if not alive:
        return false
    aggressive = true
    hit_clock = 0.16
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
    if aim_ring != null:
        aim_ring.visible = alive and selected
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
    attack_flash_clock = 0.0
    muzzle_flash.visible = false
    set_targeted(false)
