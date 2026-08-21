extends SceneTree
# A celestial body is opaque. You never see the Sun or the HYG field through it.
# Run: godot --headless --path . --script res://tools/test_sol_occlude.gd

const E := preload("res://scripts/autoload/ephemeris.gd")
const StarfieldScript := preload("res://scripts/world/starfield.gd")


func _initialize() -> void:
	var failed := 0
	var mesh_cut: float = E.CAM_FAR_SOL * 0.85
	var sky: float = E.SKY_SHELL_KM
	var stars: float = E.SKY_STAR_KM

	# Impostors (Sun, far planets) must sit BEHIND every in-range cook mesh.
	failed += _check("impostors_behind_meshes", sky > mesh_cut)
	failed += _check("impostors_inside_far", sky < E.CAM_FAR_SOL)
	failed += _check("stars_behind_impostors", stars > sky)
	failed += _check("stars_inside_far", stars < E.CAM_FAR_SOL)
	failed += _check("star_shell_has_render_margin", E.CAM_RENDER_FAR_KM >= stars * 1.5)

	var moon_eq := Vector3.ZERO
	var sun_eq := Vector3.ZERO
	for p in E.PLANETS:
		if str(p.name) == "Moon":
			moon_eq = p.eq
		elif str(p.name) == "Sun":
			sun_eq = p.eq
	var moon_p := Vector3(moon_eq.x, moon_eq.z, moon_eq.y) * E.AU_TO_UNITS
	var sun_p := Vector3(sun_eq.x, sun_eq.z, sun_eq.y) * E.AU_TO_UNITS
	var geo: Vector3 = sun_p.normalized() * E.GEO_RADIUS_KM
	var moon_dist := (moon_p - geo).length()
	print("sol_occlude: GEO→Moon %.0f km  sky=%.0f  stars=%.0f  mesh_cut=%.0f" % [
		moon_dist, sky, stars, mesh_cut])
	failed += _check("moon_still_a_mesh", moon_dist < mesh_cut)
	failed += _check("moon_in_front_of_sky", moon_dist < sky)
	failed += _check("earth_in_front_of_sky", E.GEO_RADIUS_KM < sky)

	var venus: float = E.sky_impostor_km(E.AU_TO_UNITS * 0.3)
	var far_sun: float = E.sky_impostor_km(E.AU_TO_UNITS)
	print("sol_occlude: impostor Venus %.0f  Sun %.0f" % [venus, far_sun])
	failed += _check("transit_closer_in_front", venus < far_sun)
	failed += _check("impostor_on_shell", venus >= sky and far_sun <= stars)

	# Stars / corona used to ignore depth, so they painted through Earth.
	failed += _check("stars_depth_test", StarfieldScript.STAR_SHADER.find("depth_test_disabled") < 0)
	var sys_src := FileAccess.get_file_as_string("res://scripts/world/planet_system.gd")
	failed += _check("corona_depth_test", sys_src.find("depth_test_disabled") < 0)
	failed += _check("sky_disc_writes_depth", sys_src.find("DEPTH_DRAW_OPAQUE_ONLY") >= 0)
	failed += _check("star_dots_depth_test", sys_src.find("dot.no_depth_test = true") < 0)
	failed += _check("labels_depth_test", sys_src.find("label.no_depth_test = true") < 0)

	if failed == 0:
		print("sol_occlude: OK")
		quit(0)
	else:
		print("sol_occlude: FAIL %d" % failed)
		quit(1)


func _check(name: String, ok: bool) -> int:
	if not ok:
		print("sol_occlude: FAIL %s" % name)
		return 1
	return 0
