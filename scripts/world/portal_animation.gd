extends Node3D
## Animate identified parts; never rotate color-merged structural meshes.
const ENERGY = preload("res://shaders/portal_energy.gdshader")
var rings: Array[Node3D] = []
var core_materials: Array[StandardMaterial3D] = []
var phase := 0.0
var halo: MeshInstance3D

func setup(model: Node3D, quality: String, tint: Color) -> void:
    name = "PortalAnimation"
    for child in model.find_children("*", "MeshInstance3D", true, false):
        var mesh := child as MeshInstance3D
        if str(mesh.name).begins_with("ring_") or str(mesh.name).begins_with("tilted_rune_ring_"):
            rings.append(mesh)
        if str(mesh.name) in ["reactor_core", "reactor_interior", "group_blue", "group_ruby", "group_amethyst"]:
            for surface in range(mesh.mesh.get_surface_count()):
                var original := mesh.get_active_material(surface) as StandardMaterial3D
                if original != null:
                    var animated := original.duplicate() as StandardMaterial3D
                    animated.emission_enabled = true
                    if animated.emission.is_equal_approx(Color.BLACK):
                        animated.emission = tint
                    mesh.set_surface_override_material(surface, animated)
                    core_materials.append(animated)
    if rings.is_empty():
        # Normal portal GLBs merge the frame by material. Add a thin rotor
        # around the energy aperture instead of rotating the entire frame.
        var torus := TorusMesh.new()
        torus.inner_radius = 1.82
        torus.outer_radius = 1.90
        torus.rings = 32
        torus.ring_segments = 6
        var energy := ShaderMaterial.new()
        energy.shader = ENERGY
        energy.set_shader_parameter("energy_tint", tint)
        torus.material = energy
        var pivot := Node3D.new()
        add_child(pivot)
        halo = MeshInstance3D.new()
        halo.mesh = torus
        halo.rotation.x = PI * 0.5
        halo.position.z = 0.15
        halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
        pivot.add_child(halo)
        rings.append(pivot)
    set_quality(quality)

func set_quality(quality: String) -> void:
    if halo != null:
        halo.visible = quality != "BAIXO"

func _process(delta: float) -> void:
    phase += delta
    for index in range(rings.size()):
        # Authored rings lie in XY; rotate around their local Z normal.
        rings[index].rotate_object_local(Vector3.BACK, delta * (0.12 + 0.035 * index) * (1.0 if index % 2 == 0 else -1.0))
    for material in core_materials:
        material.emission_energy_multiplier = 1.15 + 0.25 * sin(phase * 2.2)
