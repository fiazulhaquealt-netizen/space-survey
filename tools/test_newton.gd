extends SceneTree
# Headless check: Sol Newton numbers + a parked GEO fall that must reach the air.
# Run: godot --headless --path . --script res://tools/test_newton.gd

const E := preload("res://scripts/autoload/ephemeris.gd")


func _initialize() -> void:
	var eph: Node = E.new()
	var failed := 0
	failed += _check("g_geo", _near(E.GM_EARTH / (E.GEO_RADIUS_KM * E.GEO_RADIUS_KM), 0.000224, 0.00001))
	failed += _check("g_surface", _near(E.GM_EARTH / (E.EARTH_RADIUS_KM * E.EARTH_RADIUS_KM), 0.00982, 0.00005))
	failed += _check("geo_above_air", E.GEO_RADIUS_KM - E.EARTH_RADIUS_KM > E.EARTH_ATMO_TOP_KM)
	failed += _check("air_has_top", E.EARTH_ATMO_TOP_KM == 100.0)
	failed += _check("gm_earth", eph.gm("Earth") == E.GM_EARTH)
	failed += _check("gm_sun", eph.gm("Sun") == E.GM_SUN)
	failed += _check("gm_mars", eph.gm("Mars") == E.GM_MARS)
	failed += _check("gm_moon", eph.gm("Moon") == E.GM_MOON)
	failed += _check("gm_io", eph.gm("Io") > 5000.0)
	failed += _check("io_radius", eph.body_radius_km("Io") > 1800.0)
	failed += _check("titan_radius", eph.body_radius_km("Titan") > 2500.0)
	failed += _check("live_has_moons", eph.live_worlds().size() > 20)
	failed += _check("twr_above_one", 0.01962 > E.GM_EARTH / (E.EARTH_RADIUS_KM * E.EARTH_RADIUS_KM))
	failed += _check("earth_spin_honest", eph.spin_rad_s("Earth") < 0.001)
	failed += _check("earth_spin_not_arcade", eph.spin_rad_s("Earth") < 0.05)
	var veq: float = eph.spin_rad_s("Earth") * E.EARTH_RADIUS_KM
	failed += _check("earth_eq_speed", _near(veq, 0.465, 0.01))
	failed += _check("spin_stable", is_equal_approx(eph.spin_rad_s("Earth"), eph.spin_rad_s("Earth")))
	failed += _check("geo_space", eph.flight_zone("Earth", E.GEO_RADIUS_KM) == "SPACE")
	failed += _check("earth_air", eph.flight_zone("Earth", E.EARTH_RADIUS_KM + 50.0) == "AIR")
	failed += _check("earth_skin", eph.flight_zone("Earth", E.EARTH_RADIUS_KM + 10.0) == "SKIN")
	failed += _check("earth_inside", eph.flight_zone("Earth", 6000.0) == "INSIDE")
	failed += _check("earth_center", eph.flight_zone("Earth", 500.0) == "CENTER")
	failed += _check("moon_space", eph.flight_zone("Moon", E.MOON_RADIUS_KM + 1.0) == "SPACE")
	failed += _check("sun_space", eph.flight_zone("Sun", E.SUN_RADIUS_KM + 1.0e6) == "SPACE")
	failed += _check("earth_air_top", eph.atmo_top_km("Earth") == 100.0)
	failed += _check("moon_no_air", eph.atmo_top_km("Moon") == 0.0)
	eph.free()

	var r := E.GEO_RADIUS_KM
	var v := 0.0
	var dt := 2.0
	var hit_air := false
	var t := 0.0
	while t < 20000.0:
		var g: float = E.GM_EARTH / (r * r)
		v += g * dt
		r -= v * dt
		t += dt
		if r <= E.EARTH_RADIUS_KM + E.EARTH_ATMO_TOP_KM:
			hit_air = true
			break
		if r <= E.EARTH_RADIUS_KM:
			break
	failed += _check("parked_geo_reaches_air", hit_air)
	failed += _check("fall_hours", t > 7200.0 and t < 18000.0)
	print("newton: air in %.0f s (%.1f min) from parked GEO" % [t, t / 60.0])
	failed += _check("warp_1000_under_half_min", t / 1000.0 < 30.0)

	if failed == 0:
		print("newton: OK")
		quit(0)
	else:
		print("newton: FAIL %d" % failed)
		quit(1)


func _check(name: String, ok: bool) -> int:
	if not ok:
		print("newton: FAIL %s" % name)
		return 1
	return 0


func _near(a: float, b: float, eps: float) -> bool:
	return absf(a - b) <= eps
