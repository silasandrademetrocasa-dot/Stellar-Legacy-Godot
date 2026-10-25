shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never;
uniform float progress : hint_range(0.0, 1.0) = 0.0;
void fragment() {
    float fade = 1.0 - progress;
    vec3 tint = mix(vec3(1.0, 0.75, 0.25), vec3(1.0, 0.18, 0.02), progress);
    ALBEDO = tint;
    EMISSION = tint * fade * 2.0;
    ALPHA = fade * (0.35 + 0.2 * sin(UV.y * 28.0 + progress * 15.0));
}
