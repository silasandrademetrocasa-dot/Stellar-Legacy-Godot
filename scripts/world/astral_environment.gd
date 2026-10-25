extends Node3D
## Cenario astral ornamental. Importante: qualidade controla somente os FX,
## nunca troca modelos de naves, drones, AUX, NPCs ou portais.
const Routes = preload("res://scripts/world_routes.gd")
const PortalAnimation = preload("res://scripts/world/portal_animation.gd")
var portal_visual: Node3D
var accent: Color = Color.CYAN
var sparks: Array[MeshInstance3D] = []
var current_quality: String = "MEDIO"
var uptime: float = 0.0

func reset_arena(map_id: String, quality: String) -> void:
    for child in get_children():
        remove_child(child)
        child.queue_free()
    portal_visual = null
    sparks.clear()
    uptime = 0.0
    current_quality = quality
    if not Routes.is_astral(map_id):
        return
    accent = Routes.ASTRAL_COLORS[map_id]
    var resource: PackedScene = load(Routes.portal_model(map_id)) as PackedScene
    if resource != null:
        portal_visual = resource.instantiate() as Node3D
        if portal_visual != null:
            add_child(portal_visual)
            portal_visual.position = Vector3(0.0, 0.0, 59.0)
            portal_visual.scale = Vector3.ONE * 1.85
            var animation := PortalAnimation.new()
            portal_visual.add_child(animation)
            animation.setup(portal_visual, quality, accent)
    var platform := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = 18.0
    mesh.bottom_radius = 20.0
    mesh.height = 0.32
    mesh.radial_segments = 48
    var mat := StandardMaterial3D.new()
    mat.metallic = 0.85
    mat.roughness = 0.28
    mat.albedo_color = accent.darkened(0.79)
    mat.emission_enabled = true
    mat.emission = accent.darkened(0.6)
    mesh.material = mat
    platform.mesh = mesh
    platform.position = Vector3(0,-0.8,59)
    add_child(platform)
    var sparks_count: int = 3 if quality == "BAIXO" else (10 if quality == "MEDIO" else 22)
    for i in range(sparks_count):
        var sp := MeshInstance3D.new()
        var orb := SphereMesh.new()
        orb.radius = .28 if i % 3 else .53
        orb.height = .56 if i % 3 else 1.06
        orb.radial_segments = 12
        orb.rings = 6
        var spark_mat := StandardMaterial3D.new()
        spark_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        spark_mat.albedo_color = accent
        spark_mat.emission_enabled = true
        spark_mat.emission = accent
        orb.material = spark_mat
        sp.mesh = orb
        var a: float = float(i) * TAU / float(sparks_count)
        sp.position = Vector3(cos(a) * (22.0 + float(i % 3) * 7.0), 1.0 + float(i % 4) * 1.5, 52.0 + sin(a) * 18.0)
        add_child(sp)
        sparks.append(sp)

func _process(delta: float) -> void:
    if portal_visual == null or not is_instance_valid(portal_visual):
        return
    uptime += delta
    for i in range(sparks.size()):
        var sp: MeshInstance3D = sparks[i]
        sp.position.y = 2.0 + float(i % 4) * 1.3 + sin(uptime * (0.8 + float(i % 3) * 0.25) + float(i)) * 1.15
