extends Node3D
## Base estelar original G0.11, presente somente nos mapas X-1.
## Geometria local Godot, sem downloads; cores de Terra/Marte/Jupiter.
var moving_ring: Node3D
var core_light: OmniLight3D
var details: Array[Node3D] = []
var glow_color: Color = Color(0.17, 0.64, 1.0)

func build(faction: String) -> void:
    name = "BaseOrbital_Pixel_%s" % faction
    var texture: Texture2D = load("res://assets/pixel/world/base.png") as Texture2D
    if texture != null:
        var sprite := Sprite3D.new()
        sprite.texture = texture
        sprite.pixel_size = 0.46
        sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        sprite.shaded = false
        sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
        sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
        add_child(sprite)

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
