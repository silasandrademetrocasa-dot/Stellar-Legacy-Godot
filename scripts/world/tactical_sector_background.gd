extends Node3D
## G0.23: setor tatico inspirado na referencia fornecida pelo jogador.
## As estrelas/poeira sao apenas decorativas, sem colisao nem dados de servidor.

var background: MeshInstance3D
var glints: MultiMeshInstance3D
var dust: MultiMeshInstance3D
var sector: String = "1-1"
var quality: String = "MEDIO"

func _ready() -> void:
    background = MeshInstance3D.new()
    background.name = "FundoGalactico"
    var plane := PlaneMesh.new()
    plane.size = Vector2(950.0, 710.0)
    background.mesh = plane
    background.position = Vector3(0.0, -22.0, 0.0)
    background.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    add_child(background)
    glints = _make_scatter("EstrelasProximas", 260, -12.0, 0.10, false)
    dust = _make_scatter("PoeiraDeProfundidade", 65, -5.0, 0.22, true)

func _make_scatter(node_name: String, amount: int, elevation: float, radius: float, is_dust: bool) -> MultiMeshInstance3D:
    var sphere := SphereMesh.new()
    sphere.radius = radius
    sphere.height = radius * 2.0
    sphere.radial_segments = 6
    sphere.rings = 3
    var mat := StandardMaterial3D.new()
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mat.albedo_color = Color(0.50, 0.68, 0.92, 0.19 if is_dust else 0.84)
    mat.vertex_color_use_as_albedo = true
    sphere.material = mat
    var mm := MultiMesh.new()
    mm.transform_format = MultiMesh.TRANSFORM_3D
    mm.use_colors = true
    mm.mesh = sphere
    mm.instance_count = amount
    var instance := MultiMeshInstance3D.new()
    instance.name = node_name
    instance.multimesh = mm
    instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    add_child(instance)
    return instance

func set_sector(map_id: String, profile: String) -> void:
    sector = map_id
    var path: String = "res://assets/backgrounds/tactical_sectors/%s.jpg" % map_id.replace("-", "_")
    if not ResourceLoader.exists(path):
        path = "res://assets/backgrounds/tactical_sectors/1_1.jpg"
    var source_texture := load(path) as Texture2D
    var mat := StandardMaterial3D.new()
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    mat.albedo_color = Color.WHITE
    mat.albedo_texture = source_texture
    background.material_override = mat
    var rng := RandomNumberGenerator.new()
    rng.seed = absi(map_id.hash()) + 2300
    _place_scatter(glints, rng, -12.0, false)
    _place_scatter(dust, rng, -5.0, true)
    set_quality(profile)

func _place_scatter(layer: MultiMeshInstance3D, rng: RandomNumberGenerator, y: float, is_dust: bool) -> void:
    var mm: MultiMesh = layer.multimesh
    for i in range(mm.instance_count):
        var pos := Vector3(rng.randf_range(-375.0, 375.0), y + rng.randf_range(-1.5,1.5), rng.randf_range(-285.0, 285.0))
        var radius: float = rng.randf_range(0.5, 1.4) if not is_dust else rng.randf_range(1.5, 3.0)
        mm.set_instance_transform(i, Transform3D(Basis().scaled(Vector3.ONE * radius), pos))
        var tint := Color(0.75, 0.88, 1.0, rng.randf_range(0.52, 0.9))
        if is_dust:
            tint = Color(0.42, 0.64, 0.82, rng.randf_range(0.08, 0.16))
        mm.set_instance_color(i, tint)

func set_quality(profile: String) -> void:
    quality = profile
    if glints == null:
        return
    glints.multimesh.visible_instance_count = 65 if profile == "BAIXO" else (150 if profile == "MEDIO" else 260)
    dust.multimesh.visible_instance_count = 0 if profile == "BAIXO" else (20 if profile == "MEDIO" else 65)
    dust.visible = profile != "BAIXO"
