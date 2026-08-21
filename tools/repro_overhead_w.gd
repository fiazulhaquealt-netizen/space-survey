extends SceneTree
# Headless footprint: pitch Earth overhead, F10, then W.
# Writes /tmp/astryx_sol_footprint.jsonl
# Run: godot --headless --path . --script res://tools/repro_overhead_w.gd

const E := preload("res://scripts/autoload/ephemeris.gd")


func _initialize() -> void:
	var out := FileAccess.open("/tmp/astryx_sol_footprint.jsonl", FileAccess.WRITE)
	var dt := 0.016
	var pos := Vector3(0.0, 0.0, E.GEO_RADIUS_KM)
	var earth := -pos.normalized()
	var basis := Basis.looking_at(earth, Vector3.UP)
	var vel := Vector3.ZERO
	var pitch_rate := 0.0
	var t := 0.0
	var rows := []

	# 1) Burn toward Earth a bit (DEV off, honest 2 g).
	for i in 80:
		vel += (-basis.z) * 0.01962 * dt
		vel += (-pos.normalized()) * (E.GM_EARTH / pos.length_squared()) * dt
		pos += vel * dt
		t += dt
		rows.append(_row(t, pos, vel, basis, pitch_rate, true, "dive"))

	# 2) Pitch up hard — Earth goes "overhead" in the view.
	pitch_rate = 2.2
	for i in 50:
		basis = basis.rotated(basis.x, -pitch_rate * dt)
		vel += (-pos.normalized()) * (E.GM_EARTH / pos.length_squared()) * dt
		pos += vel * dt
		t += dt
		rows.append(_row(t, pos, vel, basis, pitch_rate, false, "pitch"))

	# 3) F10 face Earth but KEEP leftover pitch (old bug).
	var dir := (-pos).normalized()
	var up := Vector3.UP if absf(dir.dot(Vector3.UP)) <= 0.98 else Vector3.RIGHT
	var faced := Basis.looking_at(dir, up)
	var old_basis := faced
	var old_pos := pos
	var old_vel := vel
	var old_rate := pitch_rate

	# Old: F10 does not kill pitch_rate
	for i in 40:
		old_basis = old_basis.rotated(old_basis.x, -old_rate * dt)
		old_rate = lerpf(old_rate, 0.0, clampf(3.0 * dt, 0.0, 1.0))
		var wdir := -old_basis.z
		old_vel += wdir * 0.01962 * dt
		old_vel += (-old_pos.normalized()) * (E.GM_EARTH / old_pos.length_squared()) * dt
		old_pos += old_vel * dt
		t += dt
		var r := _row(t, old_pos, old_vel, old_basis, old_rate, true, "old_f10_w")
		rows.append(r)
		if out:
			out.store_line(JSON.stringify(r))

	# New: F10 kills pitch_rate
	dir = (-pos).normalized()
	up = Vector3.UP if absf(dir.dot(Vector3.UP)) <= 0.98 else Vector3.RIGHT
	var new_basis := Basis.looking_at(dir, up)
	var new_pos := pos
	var new_vel := vel
	var new_rate := 0.0
	for i in 40:
		new_basis = new_basis.rotated(new_basis.x, -new_rate * dt)
		var wdir2 := -new_basis.z
		new_vel += wdir2 * 0.01962 * dt
		new_vel += (-new_pos.normalized()) * (E.GM_EARTH / new_pos.length_squared()) * dt
		new_pos += new_vel * dt
		t += dt
		rows.append(_row(t, new_pos, new_vel, new_basis, new_rate, true, "new_f10_w"))

	if out:
		out.close()

	var old_rdot := old_vel.dot(old_pos.normalized())
	var new_rdot := new_vel.dot(new_pos.normalized())
	print("repro: after overhead+F10+W")
	print("  old F10 (pitch kept)  alt=%.1f  rdot=%.3f  (%s)" % [
		old_pos.length() - E.EARTH_RADIUS_KM, old_rdot, "OUT" if old_rdot > 0.0 else "IN"])
	print("  new F10 (pitch killed) alt=%.1f  rdot=%.3f  (%s)" % [
		new_pos.length() - E.EARTH_RADIUS_KM, new_rdot, "OUT" if new_rdot > 0.0 else "IN"])
	print("repro: wrote /tmp/astryx_sol_footprint.jsonl (%d old-path samples)" % 40)
	quit(0)


func _row(t: float, pos: Vector3, vel: Vector3, basis: Basis, prate: float, w: bool, phase: String) -> Dictionary:
	var r := pos.length()
	var rdot := vel.dot(pos / r) if r > 0.001 else 0.0
	var earth := -pos / r
	return {
		"t": snappedf(t, 0.01),
		"phase": phase,
		"alt": snappedf(r - E.EARTH_RADIUS_KM, 0.1),
		"rdot": snappedf(rdot, 0.001),
		"nose": snappedf((-basis.z).dot(earth), 0.001),
		"prate": snappedf(prate, 0.001),
		"w": w,
		"spd": snappedf(vel.length(), 0.001),
	}
