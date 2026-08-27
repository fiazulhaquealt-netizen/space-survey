shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never;

// Uses only the model's authored propulsion geometry, keeping the exhaust seated
// at the rear. The core never fades out at grazing angles: many authored booster
// meshes are open cylinders whose visible walls are nearly perpendicular to VIEW.
uniform vec4 plasma_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float power : hint_range(0.0, 1.0) = 0.45;
uniform float flow_speed : hint_range(0.0, 6.0) = 1.4;
uniform float brightness : hint_range(0.5, 4.0) = 4.0;
varying vec3 local_position;

void vertex() {
	local_position = VERTEX;
}

void fragment() {
	float facing = abs(dot(normalize(NORMAL), normalize(VIEW)));
	float edge_softness = smoothstep(0.02, 0.72, facing);
	float visibility = mix(0.58, 1.0, edge_softness);
	float flow = TIME * flow_speed;
	float broad = sin(local_position.x * 0.24 - flow * 2.1 + sin(local_position.y * 0.19 + flow));
	float fine = sin(local_position.z * 0.62 + local_position.x * 0.41 + flow * 4.7);
	float turbulence = clamp(0.72 + broad * 0.16 + fine * 0.12, 0.35, 1.0);
	float shimmer = mix(0.86, 1.12, turbulence);
	// Deliberately far above display white so the WorldEnvironment glow produces a
	// torch-hot core and soft bloom. This is emissive geometry, not a Light3D, so it
	// cannot illuminate or bleach the ship hull.
	float energy = mix(64.0, 128.0, power) * shimmer * brightness;
	vec3 white_core = mix(plasma_color.rgb, vec3(1.0), 0.96);

	ALBEDO = vec3(1.0);
	EMISSION = white_core * energy * visibility;
	ALPHA = clamp(mix(0.78, 0.96, power) * visibility, 0.45, 0.96);
}
