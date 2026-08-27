shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never;

// Animated rainbow chase for the cruiser's authored a1 window strip. The source
// texture is a black/white mask, so only the tiny window dashes illuminate.
uniform sampler2D led_mask : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform float intensity : hint_range(0.0, 6.0) = 3.2;
uniform float spin_speed : hint_range(-1.0, 1.0) = 0.12;
uniform vec4 color_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);
varying vec3 local_position;

vec3 rainbow(float phase) {
	return 0.56 + 0.44 * cos(6.2831853 * (phase + vec3(0.0, 0.333333, 0.666667)));
}

void vertex() {
	local_position = VERTEX;
}

void fragment() {
	vec3 sampled = texture(led_mask, UV).rgb;
	float mask = smoothstep(0.22, 0.78, max(sampled.r, max(sampled.g, sampled.b)));
	// Angular position makes the colour/chase travel around the hull instead of
	// simply scrolling across the texture atlas.
	float around_hull = atan(local_position.z, local_position.x) / 6.2831853 + 0.5;
	float travel = fract(around_hull - TIME * spin_speed);
	float chase = 0.68 + 0.32 * pow(0.5 + 0.5 * cos(travel * 6.2831853), 4.0);
	vec3 color = rainbow(around_hull * 1.35 - TIME * spin_speed);
	// Keep the full rainbow chase while letting the hangar colour gently tint it.
	color = mix(color, color * color_tint.rgb, 0.35);

	ALBEDO = vec3(0.0);
	EMISSION = color * intensity * mask * chase;
	ALPHA = mask * (0.72 + chase * 0.28);
}
