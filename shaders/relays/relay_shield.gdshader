shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never;
uniform vec4 energy_tint : source_color = vec4(0.17,0.65,1.0,0.25);
uniform float strength : hint_range(0.0,4.0) = 1.0;
uniform float fracture : hint_range(0.0,1.0) = 0.0;
void fragment() {
  float f = pow(1.0 - abs(dot(normalize(NORMAL), normalize(VIEW))), 2.6);
  vec2 cells = UV*vec2(28.0,15.0);
  vec2 p = fract(cells);
  float edge = max(1.0-smoothstep(0.0,0.065,p.x), 1.0-smoothstep(0.0,0.065,p.y));
  float shimmer=0.85 + 0.15*sin(UV.y*75.0+TIME*4.0);
  float disruption = step(0.58,sin(UV.x*93.0+TIME*42.0)*sin(UV.y*68.0-TIME*23.0));
  float intensity = max(0.0,strength)*(1.0-fracture*0.78);
  ALBEDO = energy_tint.rgb;
  EMISSION = energy_tint.rgb * (1.6*f + 0.5*edge)*intensity*shimmer;
  ALPHA = clamp( (0.10+0.64*f+0.11*edge)*intensity - 0.6*fracture*disruption, 0.0, 0.85);
}
