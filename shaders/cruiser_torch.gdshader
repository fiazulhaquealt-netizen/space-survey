shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never;

// Volumetric-looking sheath for a real authored booster socket. The mesh begins
// behind the nozzle and tapers rearward; all brightness comes from HDR emission,
// so it blooms like a torch without adding a Light3D that could bleach the hull.
uniform vec4 edge_color : source_color = vec4(0.32, 0.74, 1.0, 1.0);
uniform float power : hint_range(0.0, 1.0) = 0.45;
uniform float flow_speed : hint_range(0.0, 6.0) = 1.4;
uniform float brightness : hint_range(0.05, 2.0) = 1.0;
uniform float opacity : hint_range(0.0, 1.0) = 0.8;
uniform float white_mix : hint_range(0.0, 1.0) = 0.96;
uniform float plume_length = 1.0;
varying vec3 local_position;

void vertex() {
	local_position = VERTEX;
}

void fragment() {
	// CylinderMesh runs from -Y at the nozzle to +Y at the plume tip.
	float axial = clamp(local_position.y / max(plume_length, 0.001) + 0.5, 0.0, 1.0);
	float tip_fade = 1.0 - smoothstep(0.48, 1.0, axial);
	float facing = abs(dot(normalize(NORMAL), normalize(VIEW)));
	float soft_edge = mix(0.28, 1.0, smoothstep(0.03, 0.72, facing));
	float flow = TIME * flow_speed;
	float coarse = sin(axial * 31.0 - flow * 7.0 + local_position.x * 0.18);
	float fine = sin(axial * 67.0 - flow * 13.0 + local_position.z * 0.27);
	float flicker = clamp(0.90 + coarse * 0.07 + fine * 0.03, 0.78, 1.05);
	// The inner layer reaches >1,000 HDR emission at full burn. Bloom reads as a
	// saturated torch core, while the lack of a Light3D keeps the hull unbleached.
	float energy = mix(160.0, 640.0, power) * brightness * flicker;
	vec3 torch_color = mix(edge_color.rgb, vec3(1.0), white_mix);

	ALBEDO = torch_color;
	EMISSION = torch_color * energy * tip_fade * soft_edge;
	ALPHA = clamp(opacity * tip_fade * soft_edge, 0.0, 0.96);
}
