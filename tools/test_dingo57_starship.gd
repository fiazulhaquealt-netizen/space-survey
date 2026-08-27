extends SceneTree
# Headless contract check for Dingo57's eight authored booster groups.
# Run: godot --headless --path . --script res://tools/test_dingo57_starship.gd

const MeshStyler := preload("res://scripts/flight/ship_mesh.gd")
const MODEL_PATH := "res://assets/dingo57_starship/3d-model.obj"
const BOOSTER_GROUPS := ["115", "113", "111", "109", "076", "074", "072", "070"]
const DOUBLE_SIDED_GROUPS := ["107", "068"]


func _initialize() -> void:
	var failed := 0
	var mesh := load(MODEL_PATH) as Mesh
	failed += _check("model_imported", mesh != null)
	if mesh == null:
		quit(1)
		return

	failed += _check("godot_safe_surface_count", mesh.get_surface_count() == 41)
	var imported_indices := 0
	var booster_surfaces := {}
	var booster_surface_count := 0
	for si in mesh.get_surface_count():
		var arrays := mesh.surface_get_arrays(si)
		if arrays[Mesh.ARRAY_INDEX] != null:
			imported_indices += (arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).size()
		var surface_name: String = mesh.surface_get_name(si).to_lower()
		if not surface_name.begins_with("booster_group_"):
			failed += _check("hull_import_material_%d_untouched" % si, mesh.surface_get_material(si) == null)
		for group in BOOSTER_GROUPS:
			if surface_name == "booster_group_%s" % group:
				if not booster_surfaces.has(group):
					booster_surfaces[group] = []
				(booster_surfaces[group] as Array).append(si)
				booster_surface_count += 1
	for group in BOOSTER_GROUPS:
		failed += _check("group_%s_preserved" % group, booster_surfaces.has(group))
	for group in DOUBLE_SIDED_GROUPS:
		var surface_name := "double_sided_group_%s" % group
		var found := false
		for si in mesh.get_surface_count():
			if mesh.surface_get_name(si).to_lower() == surface_name:
				found = true
		failed += _check("group_%s_preserved_separately" % group, found)
	failed += _check("complete_source_geometry", imported_indices == 354492)

	var model := MeshInstance3D.new()
	model.mesh = mesh
	var propulsion := MeshStyler.style_dingo57_starship(model)
	failed += _check("eight_booster_surfaces_styled", propulsion.size() == 8 and booster_surface_count == 8)
	for group in BOOSTER_GROUPS:
		for si in booster_surfaces.get(group, []):
			var material := model.get_surface_override_material(si)
			failed += _check("group_%s_torch_shader" % group,
				material is ShaderMaterial \
				and (material as ShaderMaterial).get_shader_parameter("plasma_color") == Color.WHITE \
				and float((material as ShaderMaterial).get_shader_parameter("brightness")) == 4.0)
	for si in mesh.get_surface_count():
		if not mesh.surface_get_name(si).begins_with("booster_group_"):
			failed += _check("hull_surface_%d_untouched" % si, model.get_surface_override_material(si) == null)

	MeshStyler.color_authored_ship(model, Color(0.30, 0.31, 0.34), "metallic")
	for group in DOUBLE_SIDED_GROUPS:
		var surface_name := "double_sided_group_%s" % group
		for si in mesh.get_surface_count():
			if mesh.surface_get_name(si).to_lower() != surface_name:
				continue
			var repaired := model.get_surface_override_material(si) as BaseMaterial3D
			failed += _check("group_%s_opaque" % group, repaired != null \
				and repaired.transparency == BaseMaterial3D.TRANSPARENCY_DISABLED)
			failed += _check("group_%s_double_sided" % group, repaired != null \
				and repaired.cull_mode == BaseMaterial3D.CULL_DISABLED)

	var source := FileAccess.get_file_as_string(MODEL_PATH)
	for group in BOOSTER_GROUPS:
		failed += _check("group_%s_source_mapping" % group,
			source.contains("o booster_group_%s\n" % group) \
			and source.contains("usemtl booster_group_%s" % group))
	for group in DOUBLE_SIDED_GROUPS:
		failed += _check("group_%s_source_mapping" % group,
			source.contains("o double_sided_group_%s\n" % group))

	propulsion.clear()
	for si in model.mesh.get_surface_count():
		model.set_surface_override_material(si, null)
	model.mesh = null
	model.free()

	if failed == 0:
		print("dingo57_starship: OK")
		quit(0)
	else:
		print("dingo57_starship: FAIL %d" % failed)
		quit(1)


func _check(name: String, ok: bool) -> int:
	if not ok:
		print("dingo57_starship: FAIL %s" % name)
		return 1
	return 0
