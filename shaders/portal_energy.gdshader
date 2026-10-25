shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never;
uniform vec4 energy_tint : source_color = vec4(0.15, 0.75, 1.0, 1.0);
void fragment() {
    float bands = 0.55 + 0.45 * sin(UV.x * 40.0 - TIME * 2.2);
    float pulse = 0.8 + 0.2 * sin(TIME * 2.2);
    ALBEDO = energy_tint.rgb;
    EMISSION = energy_tint.rgb * (1.0 + bands) * pulse;
    ALPHA = (0.25 + 0.5 * bands) * pulse;
}
