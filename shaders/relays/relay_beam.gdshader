shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never;
uniform vec4 beam_tint : source_color = vec4(0.17,0.65,1.0,1.0);
uniform float beam_power : hint_range(0.0,5.0) = 1.0;
void fragment() {
  float swirl=0.55+0.45*sin(UV.x*25.0+TIME*5.0+sin(UV.y*11.0+TIME*2.0));
  float pulse=0.65+0.35*sin(UV.y*28.0-TIME*8.0);
  ALBEDO=beam_tint.rgb;
  EMISSION=beam_tint.rgb*beam_power*(2.1+1.3*swirl)*pulse;
  ALPHA=clamp((0.12+0.35*swirl)*beam_power,0.0,0.9);
}
