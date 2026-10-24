extends Node3D
## Base estelar original G0.11, presente somente nos mapas X-1.
## Geometria local Godot, sem downloads; cores de Terra/Marte/Jupiter.
var moving_ring: Node3D
var core_light: OmniLight3D
var details: Array[Node3D] = []
var glow_color: Color = Color(0.17, 0.64, 1.0)

func build(faction: String) -> void:
    # A base e cenografia abaixo do plano de voo, sem colisao e sem torres altas.
    # Y global = -4.5; a peca mais alta fica abaixo do casco da nave (Y 0).
    var tones: Dictionary = {"1": Color(0.13, 0.77, 1.0), "2": Color(1.0, 0.32, 0.28), "3": Color(0.26, 1.0, 0.58)}
    glow_color = tones.get(faction, Color(0.13, 0.77, 1.0))
    name = "BaseOrbital_%s" % faction
    var hull: StandardMaterial3D = _mat(Color(0.09, 0.15, 0.24), false)
    var armour: StandardMaterial3D = _mat(Color(0.18, 0.28, 0.40), false)
    var deck: StandardMaterial3D = _mat(Color(0.035, 0.075, 0.13), false)
    var neon: StandardMaterial3D = _mat(glow_color, true)
    var strip: StandardMaterial3D = _mat(glow_color.darkened(0.34), true)
    _cylinder(self, 17.0, 0.45, 0.0, hull)
    _cylinder(self, 15.4, 0.18, 0.31, deck)
    _cylinder(self, 8.0, 0.22, 0.51, armour)
    for index in range(4):
        _torus(self, 5.5 + float(index) * 2.5, 0.10, 0.68, neon if index % 2 == 0 else strip)
    # Pistas e docas rasantes, sem antenas ou torres que cortam a nave.
    for i in range(8):
        var angle: float = TAU * float(i) / 8.0
        var arm := Node3D.new()
        arm.rotation.y = angle
        add_child(arm)
        _box(arm, Vector3(3.1, 0.17, 14.4), Vector3(0, 0.28, 19.3), armour)
        _box(arm, Vector3(1.0, 0.055, 12.8), Vector3(0, 0.40, 19.8), strip)
        _box(arm, Vector3(7.5, 0.24, 5.8), Vector3(0, 0.38, 26.2), hull)
        for side in [-1.0, 1.0]:
            _box(arm, Vector3(0.2, 0.16, 3.3), Vector3(side * 3.1, 0.57, 26.2), neon)
    moving_ring = Node3D.new()
    add_child(moving_ring)
    _torus(moving_ring, 4.4, 0.16, 0.82, neon)
    _torus(moving_ring, 7.0, 0.08, 0.84, strip)
    _cylinder(self, 3.4, 0.52, 0.58, hull)
    _cylinder(self, 1.6, 0.12, 0.94, neon)
    core_light = OmniLight3D.new()
    core_light.position = Vector3(0, 1.0, 0)
    core_light.light_color = glow_color
    core_light.light_energy = 0.55
    core_light.omni_range = 18.0
    core_light.shadow_enabled = false
    add_child(core_light)

func _mat(color: Color, emissive: bool) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.metallic = 0.62 if not emissive else 0.18
    material.roughness = 0.28
    material.emission_enabled = emissive
    if emissive:
        material.emission = color
    return material

func _box(parent: Node3D, dim: Vector3, at: Vector3, material: Material) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = dim
    mesh.material = material
    node.mesh = mesh
    node.position = at
    parent.add_child(node)
    return node

func _cylinder(parent: Node3D, radius: float, height: float, y: float, material: Material) -> void:
    _cylinder_at(parent, radius, height, Vector3(0, y, 0), material)

func _cylinder_at(parent: Node3D, radius: float, height: float, at: Vector3, material: Material) -> void:
    var node := MeshInstance3D.new()
    var shape := CylinderMesh.new()
    shape.top_radius = radius
    shape.bottom_radius = radius * 1.045
    shape.height = height
    shape.radial_segments = 16
    shape.material = material
    node.mesh = shape
    node.position = at
    parent.add_child(node)

func _torus(parent: Node3D, radius: float, width: float, y: float, material: Material) -> void:
    var ring := MeshInstance3D.new()
    var tor := TorusMesh.new()
    tor.inner_radius = radius
    tor.outer_radius = radius + width
    tor.rings = 32
    tor.ring_segments = 6
    tor.material = material
    ring.mesh = tor
    ring.position = Vector3(0, y, 0)
    parent.add_child(ring)

func _sphere(parent: Node3D, radius: float, at: Vector3, material: Material) -> void:
    var node := MeshInstance3D.new()
    var ball := SphereMesh.new()
    ball.radius = radius
    ball.height = radius * 2.0
    ball.radial_segments = 16
    ball.rings = 8
    ball.material = material
    node.mesh = ball
    node.position = at
    parent.add_child(node)

func set_quality(preset: String) -> void:
    if core_light != null:
        core_light.visible = preset != "BAIXO"
    if moving_ring != null:
        moving_ring.visible = preset != "BAIXO"

func _process(delta: float) -> void:
    if moving_ring != null and is_instance_valid(moving_ring):
        moving_ring.rotation.y += delta * 0.1
