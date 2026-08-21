extends SceneTree
# Sun (any physical star) must stay drawn on close approach.
# Far: sky disc. Close: cook mesh once the near face is inside the far plane.
# Never both off. Recreate: F9 into the Sun past ~1.2 R.
# Run: godot --headless --path . --script res://tools/test_sol_sun_lod.gd

const E := preload("res://scripts/autoload/ephemeris.gd")


func _initialize() -> void:
	var failed := 0
	var r: float = E.SUN_RADIUS_KM
	var cut: float = E.CAM_FAR_SOL * 0.85
	var au: float = E.AU_TO_UNITS
	print("sol_sun_lod: R_sun %.0f  mesh_cut %.0f  1.2R %.0f" % [r, cut, r * 1.2])

	failed += _check("geo_sky", E.physical_too_far(au, r))
	failed += _check("geo_no_mesh", not E.show_physical_mesh(au, r))
	failed += _check("geo_sky_disc", E.show_sky_impostor(au, r))

	# The vanish: sky hid at 1.2 R while the cook mesh stayed forced off.
	var close: float = r * 1.2
	failed += _check("close_not_too_far", not E.physical_too_far(close, r))
	failed += _check("close_mesh", E.show_physical_mesh(close, r))
	failed += _check("close_no_sky", not E.show_sky_impostor(close, r))

	var skin: float = r + 100.0
	failed += _check("skin_mesh", E.show_physical_mesh(skin, r))
	failed += _check("skin_no_sky", not E.show_sky_impostor(skin, r))

	# Swap is the near face, not the centre. Star bigger than the far plane still works.
	failed += _check("swap_at_near_face", E.physical_too_far(r + cut + 1.0, r))
	failed += _check("mesh_when_near_in", E.show_physical_mesh(r + cut - 1.0, r))

	failed += _check("earth_geo_mesh", E.show_physical_mesh(E.GEO_RADIUS_KM, E.EARTH_RADIUS_KM))
	failed += _check("moon_from_geo_mesh", E.show_physical_mesh(384000.0, E.MOON_RADIUS_KM))

	for d in [au, r * 2.0, r * 1.2, r + cut, r + 100.0]:
		var mesh_on: bool = E.show_physical_mesh(d, r)
		var sky_on: bool = E.show_sky_impostor(d, r)
		if mesh_on == sky_on:
			print("sol_sun_lod: BOTH %s at dist %.0f" % ["on" if mesh_on else "off", d])
			failed += 1
		else:
			failed += _check("xor_%.0f" % d, true)

	var src := FileAccess.get_file_as_string("res://scripts/world/planet_system.gd")
	failed += _check("uses_too_far", src.find("physical_too_far") >= 0)
	failed += _check("no_star_force_off", src.find("too_far = true") < 0)
	failed += _check("no_1_2_r_hide", src.find("SUN_RADIUS_KM) * 1.2") < 0)

	if failed == 0:
		print("sol_sun_lod: OK")
		quit(0)
	else:
		print("sol_sun_lod: FAIL %d" % failed)
		quit(1)


func _check(name: String, ok: bool) -> int:
	if not ok:
		print("sol_sun_lod: FAIL %s" % name)
		return 1
	return 0
