extends SceneTree
# Headless: a turn must carry Sol velocity with the hull.
# Run: godot --headless --path . --script res://tools/test_turn_carry.gd

const S := preload("res://scripts/flight/turn_carry.gd")


func _initialize() -> void:
	var failed := 0
	var old_b := Basis.IDENTITY
	var vel := Vector3(0.0, 0.0, -10.0)   # forward along the nose
	var new_b := old_b.rotated(Vector3.UP, PI)
	var out: Vector3 = S.apply(vel, old_b, new_b)
	failed += _check("flip_goes_with_nose", out.z > 8.0)
	failed += _check("speed_kept", is_equal_approx(out.length(), 10.0))

	var inward := Vector3(0.0, 0.0, -1.0)
	var still_in := vel.dot(inward) > 0.0
	var now_out := out.dot(inward) < 0.0
	failed += _check("was_in", still_in)
	failed += _check("now_out", now_out)

	var same: Vector3 = S.apply(vel, old_b, old_b)
	failed += _check("no_turn_no_change", same.distance_to(vel) < 0.0001)

	if failed == 0:
		print("turn_carry: OK")
		quit(0)
	else:
		print("turn_carry: FAIL %d" % failed)
		quit(1)


func _check(name: String, ok: bool) -> int:
	if not ok:
		print("turn_carry: FAIL %s" % name)
		return 1
	return 0
