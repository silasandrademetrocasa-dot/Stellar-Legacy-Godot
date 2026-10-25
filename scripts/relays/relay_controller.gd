extends Node3D
## STELLAR LEGACY - Relés de clã; Godot 4.3 GL Compatibility / Android.
## All 3D structural meshes load from NEW relay GLBs. Runtime FX use lightweight CPU particles.

enum RelayState { IDLE, COMBAT, SHIELD_BROKEN, EVOLVING }

@export_range(1, 3, 1) var relay_level: int = 1
@export var use_mobile_lod: bool = false
@export var initial_state: RelayState = RelayState.IDLE
@export var enable_particles: bool = true

@onready var model_root: Node3D = $ModelRoot
@onready var core_pivot: Node3D = $CorePivot
@onready var ring_a: Node3D = $RingPivotA
@onready var ring_b: Node3D = $RingPivotB
@onready var shield_mesh: MeshInstance3D = $ShieldMesh
@onready var beam_mesh: MeshInstance3D = $BeamMesh
@onready var particle_root: Node3D = $ParticleRoot
@onready var combat_lights: Node3D = $CombatLights
@onready var energy_light: OmniLight3D = $EnergyLight
@onready var anim_player: AnimationPlayer = $AnimationPlayer

const SHIELD_SHADER: Shader = preload("res://shaders/relays/relay_shield.gdshader")
const BEAM_SHADER: Shader = preload("res://shaders/relays/relay_beam.gdshader")
const RING_MODEL: PackedScene = preload("res://assets/relays/modulo_anel.glb")

var current_state: int = RelayState.IDLE
var phase: float = 0.0
var field_material: ShaderMaterial
var beam_material: ShaderMaterial
var sparks: CPUParticles3D
var energy_particles: CPUParticles3D
var evolution_particles: CPUParticles3D
var _pending_upgrade: int = 0

func _ready() -> void:
    _load_level()
    _setup_fx()
    _setup_animation_library()
    anim_player.animation_finished.connect(_on_animation_finished)
    set_state(initial_state)

func _load_level() -> void:
    for node in model_root.get_children():
        node.queue_free()
    var stem: String = "rele_lv%d" % relay_level
    if use_mobile_lod:
        stem += "_lod"
    var path: String = "res://assets/relays/%s.glb" % stem
    var packed: PackedScene = load(path) as PackedScene
    if packed == null:
        push_error("Stellar Relay: nao foi possivel carregar " + path)
        return
    var visual: Node3D = packed.instantiate() as Node3D
    if visual != null:
        visual.name = "RelayVisual"
        model_root.add_child(visual)

func _energy_color() -> Color:
    match relay_level:
        1: return Color(0.19, 0.68, 1.0, 1.0)
        2: return Color(1.0, 0.16, 0.27, 1.0)
        _: return Color(0.31, 1.0, 0.35, 1.0)

func _setup_fx() -> void:
    phase = 0.0
    var radius: float = [0.0, 2.45, 3.0, 3.75][relay_level]
    for pivot in [core_pivot, ring_a, ring_b]:
        for node in pivot.get_children():
            node.queue_free()
    # Two genuinely animated 3D rotor GLBs (not just rotating a texture).
    var a: Node3D = RING_MODEL.instantiate() as Node3D
    var b: Node3D = RING_MODEL.instantiate() as Node3D
    if a != null:
        ring_a.add_child(a)
    if b != null:
        ring_b.add_child(b)
    ring_a.position = Vector3(0, 1.45, 0)
    ring_b.position = Vector3(0, 2.30, 0)
    ring_a.scale = Vector3.ONE * (0.68+0.10*relay_level)
    ring_b.scale = Vector3.ONE * (0.47+0.085*relay_level)
    ring_b.rotation_degrees.x = 23.0

    field_material = ShaderMaterial.new()
    field_material.shader = SHIELD_SHADER
    shield_mesh.mesh = SphereMesh.new()
    var shell: SphereMesh = shield_mesh.mesh as SphereMesh
    shell.radius = radius*0.94
    shell.height = radius*1.88
    field_material.set_shader_parameter("energy_tint", _energy_color())
    field_material.set_shader_parameter("strength", 0.0)
    field_material.set_shader_parameter("fracture", 0.0)
    shield_mesh.material_override = field_material
    shield_mesh.position.y = 1.22
    shield_mesh.visible = false

    beam_material = ShaderMaterial.new()
    beam_material.shader = BEAM_SHADER
    beam_material.set_shader_parameter("beam_tint", _energy_color())
    beam_material.set_shader_parameter("beam_power", 0.0)
    var beam_geo: CylinderMesh = CylinderMesh.new()
    beam_geo.top_radius = 0.11*relay_level
    beam_geo.bottom_radius = 0.28*relay_level
    beam_geo.height = 7.0+2.5*relay_level
    beam_mesh.mesh = beam_geo
    beam_mesh.material_override = beam_material
    beam_mesh.position.y = 4.0+0.75*relay_level
    beam_mesh.visible = false

    energy_light.light_color = _energy_color()
    energy_light.position.y = 1.85
    energy_light.omni_range = 7.0+2.0*relay_level
    energy_light.shadow_enabled = false

    for node in combat_lights.get_children():
        node.queue_free()
    for index in range(4+2*relay_level):
        var angle: float = float(index)*TAU/float(4+2*relay_level)
        var flare: MeshInstance3D = MeshInstance3D.new()
        var ball: SphereMesh = SphereMesh.new()
        ball.radius = 0.10
        ball.height = 0.20
        var glowing: StandardMaterial3D = StandardMaterial3D.new()
        glowing.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        glowing.albedo_color = _energy_color()
        glowing.emission_enabled = true
        glowing.emission = _energy_color()
        glowing.emission_energy_multiplier = 4.0
        ball.material = glowing
        flare.mesh = ball
        flare.position = Vector3(cos(angle)*radius*0.78, 0.85, sin(angle)*radius*0.78)
        combat_lights.add_child(flare)
    combat_lights.visible = false

    for node in particle_root.get_children():
        node.queue_free()
    energy_particles = _make_particles("EnergyParticles", 28, 2.2, _energy_color(), Vector3(0.0,1.0,0.0))
    energy_particles.position.y = 2.3
    sparks = _make_particles("SparkParticles", 42, 0.68, Color(1.0,0.40,0.13), Vector3(0.0,1.0,0.0))
    sparks.initial_velocity_min = 1.5
    sparks.initial_velocity_max = 5.5
    sparks.position.y = 1.8
    sparks.one_shot = true
    evolution_particles = _make_particles("EvolutionParticles", 70, 2.5, _energy_color(), Vector3(0.0,1.0,0.0))
    evolution_particles.position.y = 1.2
    evolution_particles.initial_velocity_max = 3.4

func _make_particles(name: String, count: int, lifetime_value: float, tint: Color, direction_value: Vector3) -> CPUParticles3D:
    var fx: CPUParticles3D = CPUParticles3D.new()
    fx.name = name
    fx.amount = count
    fx.lifetime = lifetime_value
    fx.emitting = false
    fx.direction = direction_value
    fx.spread = 180.0
    fx.gravity = Vector3(0.0,0.08,0.0)
    fx.initial_velocity_min = 0.25
    fx.initial_velocity_max = 0.95
    fx.color = tint
    var dot: SphereMesh = SphereMesh.new()
    dot.radius = 0.035
    dot.height = 0.07
    var glow: StandardMaterial3D = StandardMaterial3D.new()
    glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    glow.albedo_color = tint
    glow.emission_enabled = true
    glow.emission = tint
    glow.emission_energy_multiplier = 2.8
    dot.material = glow
    fx.mesh = dot
    particle_root.add_child(fx)
    return fx

func _setup_animation_library() -> void:
    # Real AnimationPlayer clips, separate from continuous mechanical rotations.
    var library: AnimationLibrary = AnimationLibrary.new()
    _animation(library, "idle_loop", 4.0, true, [Vector2(0.0,1.1),Vector2(2.0,1.7),Vector2(4.0,1.1)])
    _animation(library, "combat_enter", 0.55, false, [Vector2(0.0,1.4),Vector2(0.3,3.8),Vector2(0.55,3.1)])
    _animation(library, "combat_loop", 1.1, true, [Vector2(0.0,3.1),Vector2(0.25,4.7),Vector2(0.55,3.3),Vector2(0.8,4.3),Vector2(1.1,3.1)])
    _animation(library, "shield_break", 1.25, false, [Vector2(0.0,4.7),Vector2(0.23,0.2),Vector2(0.42,3.8),Vector2(0.65,0.1),Vector2(1.25,1.2)])
    _animation(library, "shield_recover", 1.10, false, [Vector2(0.0,0.2),Vector2(0.55,1.4),Vector2(1.10,2.4)])
    _animation(library, "evolve_start", 2.80, false, [Vector2(0.0,1.8),Vector2(0.7,3.9),Vector2(1.4,6.0),Vector2(2.2,5.0),Vector2(2.8,2.4)])
    _animation(library, "evolve_loop", 1.2, true, [Vector2(0.0,3.4),Vector2(0.6,5.3),Vector2(1.2,3.4)])
    _animation(library, "evolve_finish", 0.9, false, [Vector2(0.0,4.2),Vector2(0.9,1.6)])
    anim_player.add_animation_library("", library)

func _animation(library: AnimationLibrary, clip_name: String, duration: float, loops: bool, keys: Array) -> void:
    var clip: Animation = Animation.new()
    clip.length = duration
    clip.loop_mode = Animation.LOOP_LINEAR if loops else Animation.LOOP_NONE
    var track: int = clip.add_track(Animation.TYPE_VALUE)
    clip.track_set_path(track, NodePath("EnergyLight:light_energy"))
    clip.value_track_set_update_mode(track, Animation.UPDATE_CONTINUOUS)
    for key in keys:
        clip.track_insert_key(track, key.x, key.y)
    library.add_animation(clip_name, clip)

func set_state(next_state: int) -> void:
    if next_state < RelayState.IDLE or next_state > RelayState.EVOLVING:
        push_warning("Estado de rele invalido")
        return
    current_state = next_state
    match current_state:
        RelayState.IDLE:
            combat_lights.visible = false
            shield_mesh.visible = false
            beam_mesh.visible = false
            anim_player.play("idle_loop")
        RelayState.COMBAT:
            combat_lights.visible = true
            shield_mesh.visible = true
            beam_mesh.visible = false
            anim_player.play("combat_enter")
        RelayState.SHIELD_BROKEN:
            combat_lights.visible = true
            shield_mesh.visible = true
            beam_mesh.visible = false
            if enable_particles:
                sparks.restart()
            anim_player.play("shield_break")
        RelayState.EVOLVING:
            combat_lights.visible = true
            shield_mesh.visible = true
            beam_mesh.visible = true
            anim_player.play("evolve_start")
    energy_particles.emitting = enable_particles
    evolution_particles.emitting = enable_particles and current_state == RelayState.EVOLVING
    sparks.emitting = enable_particles and current_state == RelayState.SHIELD_BROKEN

func promote_to_next_level() -> void:
    if relay_level >= 3:
        set_state(RelayState.EVOLVING)
        return
    _pending_upgrade = relay_level + 1
    set_state(RelayState.EVOLVING)

func _on_animation_finished(clip_name: StringName) -> void:
    if clip_name == &"combat_enter" and current_state == RelayState.COMBAT:
        anim_player.play("combat_loop")
    elif clip_name == &"shield_break" and current_state == RelayState.SHIELD_BROKEN:
        # remains in damaged state until combat/idle/shield_recover is triggered
        anim_player.play("idle_loop")
    elif clip_name == &"shield_recover":
        set_state(RelayState.IDLE)
    elif clip_name == &"evolve_start" and current_state == RelayState.EVOLVING:
        if _pending_upgrade != 0:
            relay_level = _pending_upgrade
            _pending_upgrade = 0
            _load_level()
            _setup_fx()
            set_state(RelayState.IDLE)
        else:
            anim_player.play("evolve_loop")

func recover_shield() -> void:
    shield_mesh.visible = true
    anim_player.play("shield_recover")
    current_state = RelayState.IDLE
    sparks.emitting = false
    evolution_particles.emitting = false
    combat_lights.visible = false

func _process(delta: float) -> void:
    phase += delta
    var speed: float = 0.22
    if current_state == RelayState.COMBAT:
        speed = 1.05
    elif current_state == RelayState.SHIELD_BROKEN:
        speed = 0.35
    elif current_state == RelayState.EVOLVING:
        speed = 2.25
    core_pivot.rotation.y += delta*speed*0.65
    ring_a.rotation.y += delta*speed
    ring_b.rotation.y -= delta*speed*1.22
    ring_b.position.y = 2.3+0.08*sin(phase*1.9)
    if current_state == RelayState.SHIELD_BROKEN:
        field_material.set_shader_parameter("strength", 0.22+0.20*abs(sin(phase*19.0)))
        field_material.set_shader_parameter("fracture", 0.95)
    elif current_state == RelayState.COMBAT:
        field_material.set_shader_parameter("strength", 0.75+0.17*sin(phase*3.1))
        field_material.set_shader_parameter("fracture", 0.0)
    elif current_state == RelayState.EVOLVING:
        field_material.set_shader_parameter("strength", 1.05+0.3*sin(phase*2.8))
        field_material.set_shader_parameter("fracture", 0.0)
    else:
        field_material.set_shader_parameter("strength", 0.0)
        field_material.set_shader_parameter("fracture", 0.0)
    beam_material.set_shader_parameter("beam_power", 1.0+0.3*sin(phase*5.0) if current_state == RelayState.EVOLVING else 0.0)
    if combat_lights.visible:
        var flicker: float = 0.75+0.25*sin(phase*13.0)
        combat_lights.scale = Vector3.ONE * flicker
