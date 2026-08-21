extends SceneTree
# Headless: Q-roll must not flip the nose. W along -Z after a 180° roll
# still burns toward Earth. A 180° yaw does flip it.
# Run: godot --headless --path . --script res://tools/test_sol_facing.gd


func _initialize() -> void:
	var failed := 0
	var pos := Vector3(0.0, 0.0, 42157.0)
	var earth := -pos

	var basis := Transform3D(Basis(), Vector3.ZERO).looking_at(earth, Vector3.UP).basis
	var nose := -basis.z
	failed += _check("spawn_nose_at_earth", nose.dot(earth.normalized()) > 0.99)

	var rolled := Basis(basis)
	rolled = rolled.rotated(rolled.z, PI)
	var nose_r := -rolled.z
	failed += _check("q_roll_keeps_nose", nose_r.dot(earth.normalized()) > 0.99)
	failed += _check("q_roll_w_still_in", nose_r.dot(-pos.normalized()) > 0.99)

	var yawed := Basis(basis)
	yawed = yawed.rotated(Vector3.UP, PI)
	var nose_y := -yawed.z
	failed += _check("yaw_180_points_away", nose_y.dot(earth.normalized()) < -0.99)

	if failed == 0:
		print("sol_facing: OK")
		quit(0)
	else:
		print("sol_facing: FAIL %d" % failed)
		quit(1)


func _check(name: String, ok: bool) -> int:
	if not ok:
		print("sol_facing: FAIL %s" % name)
		return 1
	return 0
