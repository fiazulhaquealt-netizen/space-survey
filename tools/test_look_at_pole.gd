extends SceneTree
# When Earth is overhead, looking with world UP can flip the nose.
# Run: godot --headless --path . --script res://tools/test_look_at_pole.gd


func _initialize() -> void:
	var failed := 0

	var geo := Transform3D.IDENTITY.looking_at(Vector3(0, 0, -1000), Vector3.UP)
	failed += _check("geo_nose", (-geo.basis.z).dot(Vector3(0, 0, -1)) > 0.99)

	var overhead := Transform3D.IDENTITY.looking_at(Vector3(0, 1000, 0), Vector3.UP)
	var nose_up: Vector3 = -overhead.basis.z
	print("overhead looking_at(UP,UP) nose=", nose_up, " dot=", nose_up.dot(Vector3.UP))
	if nose_up.dot(Vector3.UP) <= 0.9:
		print("look_at_pole: overhead+UP does not face Earth")
		failed += _check("overhead_up", false)
	else:
		failed += _check("overhead_up", true)

	var safe := Transform3D.IDENTITY.looking_at(Vector3(0, 1000, 0), Vector3.RIGHT)
	var nose_safe: Vector3 = -safe.basis.z
	print("overhead looking_at(UP,RIGHT) nose=", nose_safe, " dot=", nose_safe.dot(Vector3.UP))
	failed += _check("overhead_safe_up", nose_safe.dot(Vector3.UP) > 0.99)

	var almost_dir := Vector3(0.08, 1.0, 0.0).normalized()
	var almost := Transform3D.IDENTITY.looking_at(almost_dir * 1000.0, Vector3.UP)
	var nose_almost: Vector3 = -almost.basis.z
	print("almost-overhead looking_at UP nose=", nose_almost, " dot=", nose_almost.dot(almost_dir))
	failed += _check("almost_overhead", nose_almost.dot(almost_dir) > 0.95)

	var w_dir: Vector3 = safe.basis * Vector3(0, 0, -1)
	failed += _check("w_after_safe_face", w_dir.dot(Vector3.UP) > 0.99)

	# Same helper the ship now uses: Basis.looking_at + safe up when Earth is overhead.
	var dir := Vector3(0, 1, 0)
	var up := Vector3.UP
	if absf(dir.dot(up)) > 0.98:
		up = Vector3.RIGHT
	var b := Basis.looking_at(dir, up)
	failed += _check("ship_face_overhead", (-b.z).dot(dir) > 0.99)
	failed += _check("ship_w_overhead", (b * Vector3(0, 0, -1)).dot(dir) > 0.99)

	if failed == 0:
		print("look_at_pole: OK")
		quit(0)
	else:
		print("look_at_pole: FAIL %d" % failed)
		quit(1)


func _check(name: String, ok: bool) -> int:
	if not ok:
		print("look_at_pole: FAIL %s" % name)
		return 1
	return 0
