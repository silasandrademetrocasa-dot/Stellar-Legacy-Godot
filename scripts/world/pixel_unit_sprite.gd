extends Sprite3D
## Lote Pixel Art: spritesheets 8x4, 32 direcoes reais a 11.25 graus.
## Todo o gameplay, colisao, navegação e saves continuam no Node3D pai.
var tracked: Node3D
var frame_count: int = 32
var yaw_offset: float = 0.0

func configure(unit: Node3D, texture_path: String, width_world: float = 4.6, directional: bool = true) -> void:
    tracked = unit
    var tex: Texture2D = load(texture_path) as Texture2D
    if tex == null:
        push_warning("Sprite pixel ausente: " + texture_path)
        return
    texture = tex
    hframes = 8 if directional else 1
    vframes = 4 if directional else 1
    frame_count = 32 if directional else 1
    centered = true
    # Independente da rotacao do pai: a imagem ja contem o angulo escolhido.
    top_level = true
    pixel_size = width_world / 64.0
    billboard = BaseMaterial3D.BILLBOARD_ENABLED
    shaded = false
    alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
    texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
    cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    double_sided = true
    _process(0.0)

func _process(_delta: float) -> void:
    if tracked == null:
        return
    global_position = tracked.global_position + Vector3(0.0, 0.48, 0.0)
    if frame_count != 32:
        return
    var degrees: float = fposmod(rad_to_deg(tracked.global_rotation.y) + yaw_offset, 360.0)
    frame = posmod(roundi(degrees / 11.25), 32)
