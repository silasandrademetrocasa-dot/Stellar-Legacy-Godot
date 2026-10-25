extends Node3D
## G0.24: ambientes taticos com texturas em escala de tela e parallax local.
## Nada aqui possui colisor, radar, selecao, recompensa ou acesso de rede.

const SKY_HIGH := "res://assets/backgrounds/tactical_sectors/"
const SKY_LOW := "res://assets/backgrounds/tactical_sectors_low/"
var background: MeshInstance3D
var glints: MultiMeshInstance3D
var dust: MultiMeshInstance3D
var debris: MultiMeshInstance3D
var following: Node3D
var sector := "1-1"
var quality := "MEDIO"
var sky_material: StandardMaterial3D
var displayed_texture := ""

func _ready() -> void:
    background = MeshInstance3D.new()
    background.name = "NebulosaParallax"
    var plane := PlaneMesh.new()
    # A camera ortografica enxerga cerca de 70 x 42 unidades:
    # este plano mostra centenas de pixels da arte, nao apenas um fragmento borrado.
    plane.size = Vector2(166.0, 112.0)
    background.mesh = plane
    background.position = Vector3(0.0, -27.0, 0.0)
    background.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    add_child(background)
    sky_material = StandardMaterial3D.new()
    sky_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    sky_material.cull_mode = BaseMaterial3D.CULL_DISABLED
    sky_material.albedo_color = Color.WHITE
    sky_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
    background.material_override = sky_material
    glints = _make_scatter("EstrelasParallax", 340, 0.11, false, false)
    dust = _make_scatter("PoeiraCosmica", 96, 0.28, true, false)
    debris = _make_scatter("DestrocosDistantes", 34, 0.68, false, true)

func set_follow_target(target: Node3D) -> void:
    following = target
    _update_follow()

func _process(_delta: float) -> void:
    _update_follow()

func _update_follow() -> void:
    if not is_instance_valid(following):
        return
    var p: Vector3 = following.global_position
    background.position = Vector3(p.x, -27.0, p.z)
    # Lentissimo deslocamento da nebulosa, evitando uma textura grudada na nave.
    if sky_material != null:
        sky_material.uv1_offset = Vector3(p.x / 1550.0, p.z / 1280.0, 0.0)
    # Camadas em profundidades diferentes: movimento relativo ao setor.
    glints.position = Vector3(p.x * 0.92, -13.0, p.z * 0.92)
    dust.position = Vector3(p.x * 0.82, -7.0, p.z * 0.82)
    debris.position = Vector3(p.x * 0.75, -18.0, p.z * 0.75)

func _make_scatter(node_name: String, amount: int, radius: float, is_dust: bool, is_debris: bool) -> MultiMeshInstance3D:
    var sphere := SphereMesh.new()
    sphere.radius = radius
    sphere.height = radius * 2.0
    sphere.radial_segments = 6
    sphere.rings = 3
    var mat := StandardMaterial3D.new()
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mat.albedo_color = Color(0.46, 0.63, 0.89, 0.27) if is_dust else (Color(0.20, 0.29, 0.43, 0.72) if is_debris else Color(0.71, 0.85, 1.0, 0.92))
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
    var rng := RandomNumberGenerator.new()
    rng.seed = absi(map_id.hash()) + 24024
    _place_scatter(glints, rng, false, false)
    _place_scatter(dust, rng, true, false)
    _place_scatter(debris, rng, false, true)
    set_quality(profile)

func _place_scatter(layer: MultiMeshInstance3D, rng: RandomNumberGenerator, is_dust: bool, is_debris: bool) -> void:
    var mm: MultiMesh = layer.multimesh
    for i in range(mm.instance_count):
        var p := Vector3(rng.randf_range(-93.0, 93.0), rng.randf_range(-1.5, 1.5), rng.randf_range(-66.0, 66.0))
        var radius: float = rng.randf_range(0.45, 1.45)
        if is_dust:
            radius = rng.randf_range(1.5, 4.0)
        if is_debris:
            radius = rng.randf_range(0.6, 1.9)
        mm.set_instance_transform(i, Transform3D(Basis().scaled(Vector3.ONE * radius), p))
        var tint := Color(0.80, 0.92, 1.0, rng.randf_range(0.58, 0.95))
        if is_dust:
            tint = Color(0.48, 0.66, 0.88, rng.randf_range(0.08, 0.24))
        if is_debris:
            tint = Color(0.31, 0.40, 0.58, rng.randf_range(0.25, 0.56))
        mm.set_instance_color(i, tint)

func _set_background_texture() -> void:
    var file_name: String = "%s.jpg" % sector.replace("-", "_")
    var base: String = SKY_LOW if quality == "BAIXO" else SKY_HIGH
    var path: String = base + file_name
    if not ResourceLoader.exists(path):
        path = base + "1_1.jpg"
    if path == displayed_texture:
        return
    var image := load(path) as Texture2D
    if image == null:
        push_warning("Fundo espacial nao encontrado: " + path)
        return
    displayed_texture = path
    sky_material.albedo_texture = image

func set_quality(profile: String) -> void:
    quality = profile
    if glints == null:
        return
    _set_background_texture()
    glints.multimesh.visible_instance_count = 44 if profile == "BAIXO" else (175 if profile == "MEDIO" else 340)
    dust.multimesh.visible_instance_count = 0 if profile == "BAIXO" else (36 if profile == "MEDIO" else 96)
    debris.multimesh.visible_instance_count = 0 if profile == "BAIXO" else (9 if profile == "MEDIO" else 34)
    glints.visible = true
    dust.visible = profile != "BAIXO"
    debris.visible = profile != "BAIXO"
