extends SceneTree
# Regression: facing Sgr A* must not put the camera inside an opaque galaxy mesh.
# Run: godot --headless --path . --script res://tools/test_galaxy_backdrop.gd

const G := preload("res://scripts/world/galaxy_model.gd")


func _initialize() -> void:
	var gal: Node3D = G.new()
	root.add_child(gal)

	var failed := 0
	var visible_meshes := 0
	var origin_inside_visible := false
	for mi in _meshes(gal):
		if not mi.is_visible_in_tree():
			continue
		visible_meshes += 1
		if _origin_inside(mi):
			origin_inside_visible = true
			print("galaxy: INSIDE visible mesh '%s' aabb=%s" % [mi.name, mi.mesh.get_aabb()])

	failed += _check("hidden_from_sol", not gal.visible)
	failed += _check("no_visible_meshes", visible_meshes == 0)
	failed += _check("camera_outside_meshes", not origin_inside_visible)

	if failed == 0:
		print("galaxy: OK  hidden (honest sky)")
		quit(0)
	else:
		print("galaxy: FAIL %d" % failed)
		quit(1)


func _check(name: String, ok: bool) -> int:
	if not ok:
		print("galaxy: FAIL %s" % name)
		return 1
	return 0


func _meshes(n: Node) -> Array:
	var out: Array = []
	if n is MeshInstance3D:
		out.append(n)
	for c in n.get_children():
		out.append_array(_meshes(c))
	return out


func _origin_inside(mi: MeshInstance3D) -> bool:
	if mi.mesh == null:
		return false
	var ab: AABB = mi.mesh.get_aabb()
	var local: Vector3 = mi.global_transform.affine_inverse() * Vector3.ZERO
	return ab.has_point(local)
