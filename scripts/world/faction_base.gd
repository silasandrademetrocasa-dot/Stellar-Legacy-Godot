extends Node3D
## Base estelar original G0.11, presente somente nos mapas X-1.
## Geometria local Godot, sem downloads; cores de Terra/Marte/Jupiter.
var moving_ring: Node3D
var core_light: OmniLight3D
var details: Array[Node3D] = []
var glow_color: Color = Color(0.17, 0.64, 1.0)

func build(faction: String) -> void:
    var tones: Dictionary = {"1": Color(0.16, 0.72, 1.0), "2": Color(1.0, 0.30, 0.23), "3": Color(0.31, 1.0, 0.51)}
    glow_color = tones.get(faction, Color(0.16, 0.72, 1.0))
    name = "BaseEstelar" + faction
    var metal: StandardMaterial3D = _mat(Color(0.14, 0.23, 0.35), false)
    var black: StandardMaterial3D = _mat(Color(0.043, 0.084, 0.14), false)
    var energy: StandardMaterial3D = _mat(glow_color, true)
    _cylinder(self, 11.0, 0.75, 0.0, metal)
    _cylinder(self, 9.5, 0.34, 0.5, black)
    _cylinder(self, 7.5, 0.16, 0.8, metal)
    for i in range(4):
        _torus(self, 4.2 + float(i) * 2.1, 0.10, 0.92 + i * 0.03, energy if i % 2 == 0 else metal)
    # Corredores hexagonais com plataformas de atracacao.
    for i in range(8):
        var angle: float = TAU * float(i) / 8.0
        var wing := Node3D.new()
        wing.rotation.y = angle
        add_child(wing)
        var arm := _box(wing, Vector3(3.5, 0.7, 15.0), Vector3(0, 0.45, 10.4), metal)
        arm.rotation.y = 0.0
        _box(wing, Vector3(1.1, 0.12, 12.0), Vector3(0, 0.85, 11.5), energy)
        _box(wing, Vector3(8.2, 0.9, 5.0), Vector3(0, 0.45, 19.2), black)
        _box(wing, Vector3(7.5, 0.09, 3.8), Vector3(0, 0.96, 19.1), metal)
        for side in [-1.0, 1.0]:
            _cylinder_at(wing, 0.7, 5.5, Vector3(side * 3.5, 3.2, 19.2), metal)
            _cylinder_at(wing, 0.16, 6.0, Vector3(side * 3.5, 6.1, 19.2), energy)
            _box(wing, Vector3(0.14, 0.16, 3.5), Vector3(side * 2.2, 1.0, 19.2), energy)
    # Nucleo de comando com domo hexagonal e farol orbital.
    _cylinder(self, 4.9, 5.0, 3.0, metal)
    _cylinder(self, 4.0, 5.9, 7.4, black)
    _cylinder(self, 2.6, 3.9, 11.0, metal)
    _cylinder(self, 0.75, 9.0, 16.5, energy)
    _sphere(self, 2.2, Vector3(0, 21.1, 0), energy)
    for i in range(6):
        var a: float = TAU * float(i) / 6.0
        _cylinder_at(self, 0.34, 12.0, Vector3(cos(a) * 5.4, 8.0, sin(a) * 5.4), metal)
        _sphere(self, 0.55, Vector3(cos(a) * 5.4, 14.1, sin(a) * 5.4), energy)
    moving_ring = Node3D.new()
    add_child(moving_ring)
    _torus(moving_ring, 7.1, 0.18, 15.2, energy)
    _torus(moving_ring, 9.0, 0.11, 17.7, energy)
    _torus(moving_ring, 5.0, 0.2, 12.2, metal)
    core_light = OmniLight3D.new()
    core_light.position = Vector3(0, 12, 0)
    core_light.light_color = glow_color
    core_light.light_energy = 0.85
    core_light.omni_range = 34.0
    core_light.shadow_enabled = false
    add_child(core_light)
    var banner := Label3D.new()
    banner.text = "BASE %s  |  COMANDO ESTELAR" % {"1": "TERRA", "2": "MARTE", "3": "JUPITER"}.get(faction, "ESTELAR")
    banner.font_size = 48
    banner.pixel_size = 0.013
    banner.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    banner.no_depth_test = true
    banner.position = Vector3(0, 26, 0)
    add_child(banner)

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
