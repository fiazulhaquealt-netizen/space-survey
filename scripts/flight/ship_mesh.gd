class_name ShipMesh
extends RefCounted
# Stateless mesh / material / FX helpers for the player ship. Pulled out of ship.gd
# to keep that file focused on flight + state. Everything here is a static function
# that operates only on its arguments (no ship state), so it's safe to call from
# anywhere and easy to reason about.

const CRUISER_LED_SHADER := preload("res://shaders/cruiser_led.gdshader")
const CRUISER_PROPULSION_SHADER := preload("res://shaders/cruiser_propulsion.gdshader")
const CRUISER_TORCH_SHADER := preload("res://shaders/cruiser_torch.gdshader")

# Exact centers and usable radii of the six disconnected patches in the Class II
# OBJ's authored `propulsion` object. These are asset sockets, not a random layout.
# Its nozzle planes face local -Z; the imported hull's 180-degree yaw then presents
# the exhaust correctly toward the chase camera behind the ship.
const CLASS_II_BOOSTER_SOCKETS := [
	{ "center": Vector3(60.12385, 81.96715, -107.8570), "radius": 8.59805 },
	{ "center": Vector3(46.55385, 66.84465, -94.2746), "radius": 8.59805 },
	{ "center": Vector3(40.99215, 83.45400, -100.9570), "radius": 5.16870 },
	{ "center": Vector3(-21.43830, 81.96715, -107.8570), "radius": 8.59805 },
	{ "center": Vector3(-7.86826, 66.84465, -94.2746), "radius": 8.59805 },
	{ "center": Vector3(-2.30657, 83.45400, -100.9570), "radius": 5.16870 },
]

# Exact rear centers of Snarkrans' authored .000 upper booster and the two circular
# sockets inside .005_...035. The source objects contain the housings, but their
# open centers need a luminous plug and exhaust volume to read as active engines.
const SNARKRANS_BOOSTER_SOCKETS := [
	{ "center": Vector3(0.0, 5.41215, -9.26658), "radius": 0.78 },
	{ "center": Vector3(-1.45544, 2.95375, -9.26658), "radius": 0.78 },
	{ "center": Vector3(1.45544, 2.95375, -9.26658), "radius": 0.78 },
]

# --- AABB / fitting --------------------------------------------------------

static func gather_mesh_instances(node: Node) -> Array[MeshInstance3D]:
	var out: Array[MeshInstance3D] = []
	if node is MeshInstance3D:
		out.append(node as MeshInstance3D)
	for c in node.get_children():
		out.append_array(gather_mesh_instances(c))
	return out


# Union of every child MeshInstance3D's AABB, expressed in `root`'s local space.
static func combined_aabb(root: Node3D) -> AABB:
	var out := AABB()
	var first := true
	var inv := root.global_transform.affine_inverse()
	for mi in gather_mesh_instances(root):
		if mi.mesh == null:
			continue
		var box := (inv * mi.global_transform) * mi.get_aabb()
		if first:
			out = box
			first = false
		else:
			out = out.merge(box)
	return out


# Scale `model` so its longest axis spans `target_len`, then recenter it. Measured in
# `mesh_root` space (the model's parent) so it accounts for the model's yaw/pitch.
static func fit_model(mesh_root: Node3D, model: Node3D, target_len: float) -> AABB:
	var box := combined_aabb(mesh_root)
	var size := box.size
	var longest := maxf(size.x, maxf(size.y, size.z))
	if longest <= 0.0001:
		return AABB(Vector3(-1, -1, -1), Vector3(2, 2, 2))
	var factor := target_len / longest
	model.scale = model.scale * factor
	var center := box.position + size * 0.5
	model.position -= center * factor
	return AABB(-size * factor * 0.5, size * factor)



# Dedicated material pass for Herminio Nieves' Class II Galactic Cruiser. The OBJ
# imports as five material surfaces: cockpit glass, a1 window LEDs, propulsion,
# textured ship body, and engine covers. Matching by material/surface name keeps
# the treatment resilient; the ordinal checks cover importers that discard names.
# Returns the propulsion ShaderMaterials so ship.gd can drive them from live speed.
static func style_class_ii_cruiser(model: Node3D) -> Array[ShaderMaterial]:
	var propulsion_materials: Array[ShaderMaterial] = []
	var ordinal := 0
	for mi in gather_mesh_instances(model):
		if mi.mesh == null:
			continue
		_prepare_legacy_obj(mi)
		for si in mi.mesh.get_surface_count():
			var orig := mi.get_active_material(si)
			var tag: String = mi.mesh.surface_get_name(si).to_lower()
			if orig != null:
				tag += " " + orig.resource_name.to_lower()
			var source_texture: Texture2D = null
			if orig is BaseMaterial3D:
				source_texture = (orig as BaseMaterial3D).albedo_texture

			if tag.contains("a1window") or ordinal == 1:
				var led := ShaderMaterial.new()
				led.shader = CRUISER_LED_SHADER
				if source_texture == null:
					source_texture = load("res://assets/class_ii_galactic_cruiser/Maps/wns1c.jpg") as Texture2D
				led.set_shader_parameter("led_mask", source_texture)
				mi.set_surface_override_material(si, led)
			elif tag.contains("propulsion") or ordinal == 2:
				var propulsion := ShaderMaterial.new()
				propulsion.shader = CRUISER_PROPULSION_SHADER
				propulsion.set_shader_parameter("plasma_color", Color.WHITE)
				propulsion.set_shader_parameter("brightness", 4.0)
				mi.set_surface_override_material(si, propulsion)
				propulsion_materials.append(propulsion)
			elif tag.contains("eng_covers") or tag.contains("eng covers") or ordinal == 4:
				var cover := StandardMaterial3D.new()
				cover.albedo_color = Color(0.10, 0.22, 0.34)
				cover.metallic = 0.82
				cover.metallic_specular = 0.88
				cover.roughness = 0.20
				cover.rim_enabled = true
				cover.rim = 0.28
				cover.rim_tint = 0.30
				cover.emission_enabled = true
				cover.emission = Color(0.025, 0.09, 0.16)
				cover.emission_energy_multiplier = 0.35
				mi.set_surface_override_material(si, cover)
			elif tag.contains("ship_body") or tag.contains("ship body") or ordinal == 3:
				var hull := StandardMaterial3D.new()
				hull.albedo_texture = source_texture
				hull.albedo_color = Color(0.92, 0.95, 1.0)
				hull.metallic = 0.42
				hull.metallic_specular = 0.72
				hull.roughness = 0.34
				hull.rim_enabled = true
				hull.rim = 0.16
				hull.rim_tint = 0.42
				mi.set_surface_override_material(si, hull)
			else:
				var glass := StandardMaterial3D.new()
				glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				glass.cull_mode = BaseMaterial3D.CULL_DISABLED
				glass.albedo_color = Color(0.12, 0.32, 0.48, 0.24)
				glass.metallic = 0.0
				glass.metallic_specular = 0.95
				glass.roughness = 0.035
				glass.rim_enabled = true
				glass.rim = 0.52
				glass.rim_tint = 0.18
				mi.set_surface_override_material(si, glass)
			ordinal += 1
	return propulsion_materials


# Give every flat Class II propulsion patch a real, tapered exhaust volume. Two
# nested layers form each torch: a broad blue-white fog sheath and a shorter,
# near-solid white core. They are added after model fitting so their length does
# not shrink the hull, and both layers are returned for live throttle animation.
static func add_class_ii_booster_plumes(model: Node3D) -> Array[ShaderMaterial]:
	var propulsion_materials: Array[ShaderMaterial] = []
	var plume_root := Node3D.new()
	plume_root.name = "ClassIIAuthoredBoosterPlumes"
	model.add_child(plume_root)

	for i in CLASS_II_BOOSTER_SOCKETS.size():
		var socket: Dictionary = CLASS_II_BOOSTER_SOCKETS[i]
		var center: Vector3 = socket.center
		var radius: float = float(socket.radius)
		# Outer haze: longer and wider, but dimmer and translucent at the edge.
		propulsion_materials.append(_add_torch_layer(
			plume_root, "BoosterFog%02d" % (i + 1), center, radius,
			radius * 5.2, 0.98, 0.16, 0.18, 0.36, 0.72))
		# Inner torch: tight white-hot spear that produces the convincing bright core.
		propulsion_materials.append(_add_torch_layer(
			plume_root, "BoosterCore%02d" % (i + 1), center, radius,
			radius * 3.8, 0.58, 0.055, 1.75, 0.92, 0.995))
	return propulsion_materials


static func _add_torch_layer(parent: Node3D, layer_name: String,
		center: Vector3, socket_radius: float, length: float, base_ratio: float,
		tip_ratio: float, brightness: float, opacity: float,
		white_mix: float) -> ShaderMaterial:
	var cone := CylinderMesh.new()
	cone.height = length
	cone.bottom_radius = socket_radius * base_ratio
	cone.top_radius = socket_radius * tip_ratio
	cone.radial_segments = 32
	cone.rings = 8
	cone.cap_bottom = false
	cone.cap_top = false

	var material := ShaderMaterial.new()
	material.shader = CRUISER_TORCH_SHADER
	material.set_shader_parameter("edge_color", Color(0.28, 0.70, 1.0))
	material.set_shader_parameter("brightness", brightness)
	material.set_shader_parameter("opacity", opacity)
	material.set_shader_parameter("white_mix", white_mix)
	material.set_shader_parameter("plume_length", length)

	var plume := MeshInstance3D.new()
	plume.name = layer_name
	plume.mesh = cone
	plume.material_override = material
	plume.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Cylinder +Y becomes local -Z. Its -Y/base end sits exactly behind the
	# authored patch while the narrow +Y tip extends away from the ship.
	plume.rotation = Vector3(deg_to_rad(-90.0), 0.0, 0.0)
	plume.position = center + Vector3(0.0, 0.0, -length * 0.5 - 0.12)
	parent.add_child(plume)
	return material


# Dedicated split for Snarkrans' ship. The four user-identified OBJ objects are
# assigned distinct booster materials, preserving them as independent Godot
# surfaces even though the supplied OBJ originally had no material library.
static func style_snarkrans_starship(model: Node3D) -> Array[ShaderMaterial]:
	var propulsion_materials: Array[ShaderMaterial] = []
	for mi in gather_mesh_instances(model):
		if mi.mesh == null:
			continue
		_prepare_legacy_obj(mi)
		for si in mi.mesh.get_surface_count():
			var orig := mi.get_active_material(si)
			var tag: String = mi.mesh.surface_get_name(si).to_lower()
			if orig != null:
				tag += " " + orig.resource_name.to_lower()
			if tag.contains("booster_tip") or tag.contains("booster_bottom") \
				or tag.contains("booster_upper_shell") or tag.contains("booster_lower_shell"):
				var propulsion := ShaderMaterial.new()
				propulsion.shader = CRUISER_PROPULSION_SHADER
				propulsion.set_shader_parameter("plasma_color", Color.WHITE)
				propulsion.set_shader_parameter("brightness", 4.0)
				mi.set_surface_override_material(si, propulsion)
				propulsion_materials.append(propulsion)
	return propulsion_materials


# Fill Snarkrans' three empty booster housings with a dense emissive plug, then
# attach the same fog-sheath + white-core torch used by the Class II cruiser.
# Socket coordinates come directly from the user-identified authored OBJ objects.
static func add_snarkrans_booster_plumes(model: Node3D) -> Array[ShaderMaterial]:
	var propulsion_materials: Array[ShaderMaterial] = []
	var plume_root := Node3D.new()
	plume_root.name = "SnarkransAuthoredBoosterPlumes"
	model.add_child(plume_root)

	for i in SNARKRANS_BOOSTER_SOCKETS.size():
		var socket: Dictionary = SNARKRANS_BOOSTER_SOCKETS[i]
		var center: Vector3 = socket.center
		var radius: float = float(socket.radius)
		# First close the visibly empty center with a thick white-hot emitter face.
		propulsion_materials.append(_add_dense_booster_plug(
			plume_root, "BoosterFill%02d" % (i + 1), center, radius))
		propulsion_materials.append(_add_torch_layer(
			plume_root, "BoosterFog%02d" % (i + 1), center, radius,
			radius * 5.4, 1.06, 0.18, 0.20, 0.40, 0.76))
		propulsion_materials.append(_add_torch_layer(
			plume_root, "BoosterCore%02d" % (i + 1), center, radius,
			radius * 4.0, 0.64, 0.06, 1.85, 0.94, 0.998))
	return propulsion_materials


static func _add_dense_booster_plug(parent: Node3D, plug_name: String,
		center: Vector3, radius: float) -> ShaderMaterial:
	var plug_depth := radius * 0.24
	var plug_mesh := CylinderMesh.new()
	plug_mesh.height = plug_depth
	plug_mesh.bottom_radius = radius
	plug_mesh.top_radius = radius * 0.98
	plug_mesh.radial_segments = 40
	plug_mesh.rings = 1
	plug_mesh.cap_bottom = true
	plug_mesh.cap_top = true

	var material := ShaderMaterial.new()
	material.shader = CRUISER_PROPULSION_SHADER
	material.set_shader_parameter("plasma_color", Color.WHITE)
	material.set_shader_parameter("brightness", 4.0)

	var plug := MeshInstance3D.new()
	plug.name = plug_name
	plug.mesh = plug_mesh
	plug.material_override = material
	plug.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	plug.rotation = Vector3(deg_to_rad(-90.0), 0.0, 0.0)
	# Seat the inner cap on the authored rear plane and put its bright outer face
	# slightly behind the housing so the housing can still occlude the edges.
	plug.position = center + Vector3(0.0, 0.0, -plug_depth * 0.5 - 0.015)
	parent.add_child(plug)
	return material


# Dingo57's eight named booster groups were assigned unique materials during ingest,
# preserving them as independent surfaces. Their geometry stays untouched; only the
# surface becomes an extremely HDR-hot, fog-edged light source.
static func style_dingo57_starship(model: Node3D) -> Array[ShaderMaterial]:
	var propulsion_materials: Array[ShaderMaterial] = []
	for mi in gather_mesh_instances(model):
		if mi.mesh == null:
			continue
		_prepare_legacy_obj(mi)
		for si in mi.mesh.get_surface_count():
			var orig := mi.get_active_material(si)
			var tag: String = mi.mesh.surface_get_name(si).to_lower()
			if orig != null:
				tag += " " + orig.resource_name.to_lower()
			if tag.contains("booster_group_"):
				var propulsion := ShaderMaterial.new()
				propulsion.shader = CRUISER_PROPULSION_SHADER
				propulsion.set_shader_parameter("plasma_color", Color.WHITE)
				propulsion.set_shader_parameter("brightness", 4.0)
				mi.set_surface_override_material(si, propulsion)
				propulsion_materials.append(propulsion)
	return propulsion_materials


# Apply the hangar colour to every authored surface except the exact propulsion
# shader surfaces. Shader identity is the exclusion boundary, so material names or
# import ordering cannot accidentally paint a booster. Class II's LED stays animated
# and receives a gentle tint through its own shader parameter.
static func color_authored_ship(model: Node3D, tint: Color, finish: String) -> int:
	var colored := 0
	for mi in gather_mesh_instances(model):
		if mi.mesh == null:
			continue
		for si in mi.mesh.get_surface_count():
			var active := mi.get_active_material(si)
			var surface_tag: String = mi.mesh.surface_get_name(si).to_lower()
			if active is ShaderMaterial:
				var shader_material := active as ShaderMaterial
				if shader_material.shader == CRUISER_PROPULSION_SHADER:
					continue
				if shader_material.shader == CRUISER_LED_SHADER:
					shader_material.set_shader_parameter("color_tint", tint)
					colored += 1
				continue

			var material: BaseMaterial3D
			if active is BaseMaterial3D:
				material = (active as BaseMaterial3D).duplicate() as BaseMaterial3D
			else:
				material = StandardMaterial3D.new()
			material.resource_name = "customized_hull"
			var authored_alpha := material.albedo_color.a
			var authored_glass := material.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED
			material.albedo_color = Color(tint.r, tint.g, tint.b,
				authored_alpha if authored_glass else 1.0)
			material.emission_enabled = false
			if finish == "glassy":
				material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				material.cull_mode = BaseMaterial3D.CULL_DISABLED
				material.albedo_color.a = 0.38
				material.metallic = 0.0
				material.metallic_specular = 1.0
				material.roughness = 0.03
				material.clearcoat_enabled = true
				material.clearcoat = 1.0
				material.clearcoat_roughness = 0.02
				material.rim_enabled = true
				material.rim = 0.6
				material.rim_tint = 0.2
			elif authored_glass:
				# Colour authored glass too, but do not turn a cockpit pane into metal.
				material.metallic = 0.0
				material.metallic_specular = 1.0
				material.roughness = 0.03
				material.rim_enabled = true
				material.rim = 0.52
			else:
				material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
				material.metallic = 0.58
				material.metallic_specular = 0.9
				material.roughness = 0.16
				material.clearcoat_enabled = false
				material.rim_enabled = true
				material.rim = 0.24
				material.rim_tint = 0.35
			# Dingo57 Group_107 and Group_068 are authored mirrored/thin-shell
			# pieces. External viewers show both sides, while Godot's default backface
			# culling made them read as holes. Only these preserved surfaces are two-sided.
			if surface_tag.contains("double_sided_group_107") \
				or surface_tag.contains("double_sided_group_068"):
				material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
				material.cull_mode = BaseMaterial3D.CULL_DISABLED
			mi.set_surface_override_material(si, material)
			colored += 1
	return colored


# Imported OBJ shadow meshes can contain geometry-only surfaces with null material
# RIDs. Duplicate per ship instance and remove that optional acceleration mesh before
# applying animated surface overrides; the visible source mesh remains unchanged.
static func _prepare_legacy_obj(mi: MeshInstance3D) -> void:
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if mi.mesh is ArrayMesh:
		var visual_mesh := mi.mesh.duplicate() as ArrayMesh
		visual_mesh.shadow_mesh = null
		mi.mesh = visual_mesh


# A small key + fill + core light rig parented to the hull (travels with the ship).
# The scene has no Light3D otherwise — these are what let the lit pink-crystal
# material (toon diffuse, rim aura, sharp low-poly highlights) actually show. Range
# is kept to a few hull-lengths so they light the ship, not the wider scene.
# `accent` tints the fill + core lights (HaniStar = pink). `energy` scales the whole
# rig — metallic hulls (Lyra) need it low or they blow out into a bloom blob.
static func add_hull_lights(parent: Node3D, box: AABB, accent := Color(1.0, 0.70, 0.84), energy := 1.0) -> void:
	var s := box.size
	var reach: float = maxf(s.length(), 0.3)
	# Key: warm near-white, up/front/right — carves the faceted highlights.
	var key := OmniLight3D.new()
	key.position = Vector3(reach * 0.9, reach * 1.1, reach * 0.9)
	key.light_color = Color(1.0, 0.90, 0.93)
	key.light_energy = 1.3 * energy
	key.omni_range = reach * 3.0
	key.shadow_enabled = false
	parent.add_child(key)
	# Fill: accent-tinted, down/back/left — lifts the shadow side.
	var fill := OmniLight3D.new()
	fill.position = Vector3(-reach * 0.9, -reach * 0.7, -reach * 0.9)
	fill.light_color = accent
	fill.light_energy = 0.8 * energy
	fill.omni_range = reach * 3.0
	fill.shadow_enabled = false
	parent.add_child(fill)
	# Core: a soft accent glow at the hull centre to fill recessed panels.
	var core := OmniLight3D.new()
	core.position = Vector3(0.0, reach * 0.05, 0.0)
	core.light_color = accent
	core.light_energy = 1.1 * energy
	core.omni_range = reach * 1.6
	core.shadow_enabled = false
	parent.add_child(core)
