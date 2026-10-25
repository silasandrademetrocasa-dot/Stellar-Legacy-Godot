shader_type canvas_item;
render_mode unshaded;
uniform vec4 void_color : source_color = vec4(0.016, 0.031, 0.067, 1.0);
uniform vec4 ion_color : source_color = vec4(0.20, 0.86, 0.95, 1.0);
uniform float aspect_ratio = 1.77778;
uniform float motion_strength : hint_range(0.0, 1.0) = 1.0;
float hash21(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}
void fragment() {
    vec2 p = (UV - vec2(0.69, 0.38)) * vec2(aspect_ratio, 1.0);
    float radius = length(p);
    float orbit = 1.0 - smoothstep(0.001, 0.003, abs(radius - 0.44));
    float outer_orbit = 1.0 - smoothstep(0.001, 0.002, abs(radius - 0.51));
    float angle = atan(p.y, p.x);
    float segments = smoothstep(0.25, 0.6, sin(angle * 9.0 + TIME * 0.08 * motion_strength));
    vec2 cells = UV * vec2(96.0 * aspect_ratio, 96.0);
    float star = (1.0 - smoothstep(0.015, 0.12, length(fract(cells) - 0.5))) * step(0.989, hash21(floor(cells)));
    float halo = exp(-radius * radius * 3.0);
    vec3 color = void_color.rgb + ion_color.rgb * (halo * 0.025 + orbit * segments * 0.10 + outer_orbit * 0.035 + star * 0.3);
    COLOR = vec4(color, 1.0);
}
