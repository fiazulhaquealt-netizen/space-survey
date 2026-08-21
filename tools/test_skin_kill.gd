extends SceneTree
# Headless check: Earth kill is 29 km (r = 6400). Floor 100 m for other worlds.
# Run: godot --headless --path . --script res://tools/test_skin_kill.gd

const E := preload("res://scripts/autoload/ephemeris.gd")


func _initialize() -> void:
	var eph: Node = E.new()
	var failed := 0
	var earth_kill := E.EARTH_MIN_R_KM - E.EARTH_RADIUS_KM
	failed += _check("atmo_end_about_6500", is_equal_approx(E.EARTH_RADIUS_KM + E.EARTH_ATMO_TOP_KM, 6471.0))
	failed += _check("earth_min_r_6400", is_equal_approx(E.EARTH_MIN_R_KM, 6400.0))
	failed += _check("earth_kill_29km", is_equal_approx(earth_kill, 29.0))
	failed += _check("earth_uses_29km", is_equal_approx(eph.surface_kill_km("Earth"), 29.0))
	failed += _check("floor_still_100m", is_equal_approx(E.SURFACE_KILL_FLOOR_KM, 0.1))
	failed += _check("moon_at_floor", is_equal_approx(eph.surface_kill_km("Moon"), 0.1))
	failed += _check("cutscene_2_to_3s", E.SURFACE_KILL_SECS >= 2.0 and E.SURFACE_KILL_SECS <= 3.0)
	failed += _check("30km_lives_earth", 30.0 > eph.surface_kill_km("Earth"))
	failed += _check("29km_dies_earth", 29.0 <= eph.surface_kill_km("Earth"))
	failed += _check("never_below_floor", eph.surface_kill_km("Moon") >= E.SURFACE_KILL_FLOOR_KM)

	eph.surface_kill_extra_km["Jupiter"] = 0.4
	failed += _check("jupiter_raised", is_equal_approx(eph.surface_kill_km("Jupiter"), 0.5))
	eph.surface_kill_extra_km["Jupiter"] = -2.0
	failed += _check("negative_extra_clamped", eph.surface_kill_km("Jupiter") >= E.SURFACE_KILL_FLOOR_KM)
	eph.surface_kill_extra_km.erase("Jupiter")

	var park: Vector3 = eph.sweet_spot("Earth")
	failed += _check("earth_park_is_geo", park.length() > E.EARTH_MIN_R_KM + 1000.0)
	eph.free()

	if failed == 0:
		print("skin_kill: OK")
		quit(0)
	else:
		print("skin_kill: FAIL %d" % failed)
		quit(1)


func _check(name: String, ok: bool) -> int:
	if not ok:
		print("skin_kill: FAIL %s" % name)
		return 1
	return 0
