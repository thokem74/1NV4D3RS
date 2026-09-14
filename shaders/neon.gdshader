shader_type canvas_item;
render_mode unshaded;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
void fragment() {
 vec3 base = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
 vec3 bloom = textureLod(screen_texture, SCREEN_UV, 2.5).rgb;
 float vignette = 1.0 - 0.22 * pow(length((SCREEN_UV - 0.5) * 1.2), 2.0);
 float scan = 1.0 - 0.025 * (0.5 + 0.5 * sin(SCREEN_UV.y * 360.0 * 3.14159));
 COLOR = vec4((base + max(bloom - vec3(0.13), vec3(0.0)) * 0.32) * vignette * scan, 1.0);
}
