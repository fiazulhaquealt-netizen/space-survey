class_name SurfacePatch
extends Node3D
# Local bird-view ground just above the kill line. Hills, water, trees.
# Still a paint. You still do not land.

const SHOW_BELOW_KM := 140.0
const PATCH_KM := 36.0
const SEGS := 48
const TREE_MAX := 220
const MOVE_REBUILD_KM := 1.2

var _ground: MeshInstance3D
var _water: MeshInstance3D
var _trees: MultiMeshInstance3D
var _himg: Image
var _simg: Image
var _aimg: Image
var _anchor := Vector3.ZERO
var _body := ""
var _ready_maps := false


func _ready() -> void:
	_ground = MeshInstance3D.new()
	_ground.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_ground)
	_water = MeshInstance3D.new()
	_water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_water)
	_trees = MultiMeshInstance3D.new()
	_trees.multimesh = _make_tree_multimesh()
	add_child(_trees)
	visible = false
	_load_maps()


func _load_maps() -> void:
	var ht := load("res://assets/planets/earth_height.jpg") as Texture2D
	var st := load("res://assets/planets/earth_spec_2k.png") as Texture2D
	var at := load("res://assets/planets/earth_2k.jpg") as Texture2D
	if ht:
		_himg = ht.get_image()
		if _himg and _himg.is_compressed():
			_himg.decompress()
	if st:
		_simg = st.get_image()
		if _simg and _simg.is_compressed():
			_simg.decompress()
	if at:
		_aimg = at.get_image()
		if _aimg and _aimg.is_compressed():
			_aimg.decompress()
	_ready_maps = _himg != null and _simg != null


func hush() -> void:
	visible = false


func update_for(ship_pos: Vector3, body: String, radius: float, alt: float) -> void:
	var kill := Ephemeris.surface_kill_km(body)
	var show := body == "Earth" and _ready_maps and alt > kill and alt < SHOW_BELOW_KM
	if not show:
		visible = false
		return
	visible = true
	var hit: Vector3 = ship_pos.normalized() * radius
	if _body != body or hit.distance_to(_anchor) > MOVE_REBUILD_KM:
		_rebuild(hit, radius)
		_anchor = hit
		_body = body


func _rebuild(hit: Vector3, radius: float) -> void:
	var up := hit.normalized()
	var east := up.cross(Vector3.UP)
	if east.length_squared() < 0.0001:
		east = up.cross(Vector3.RIGHT)
	east = east.normalized()
	var north := east.cross(up).normalized()
	var half := PATCH_KM * 0.5
	var land_st := SurfaceTool.new()
	var wat_st := SurfaceTool.new()
	land_st.begin(Mesh.PRIMITIVE_TRIANGLES)
	wat_st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var tree_xforms: Array[Transform3D] = []
	for j in SEGS:
		for i in SEGS:
			var u0 := float(i) / float(SEGS)
			var v0 := float(j) / float(SEGS)
			var u1 := float(i + 1) / float(SEGS)
			var v1 := float(j + 1) / float(SEGS)
			var p00 := _vert(hit, up, east, north, half, u0, v0, radius)
			var p10 := _vert(hit, up, east, north, half, u1, v0, radius)
			var p01 := _vert(hit, up, east, north, half, u0, v1, radius)
			var p11 := _vert(hit, up, east, north, half, u1, v1, radius)
			var wet: float = (float(p00.w) + float(p10.w) + float(p01.w) + float(p11.w)) * 0.25
			var st: SurfaceTool = wat_st if wet > 0.55 else land_st
			var n: Vector3 = (p10.p - p00.p).cross(p01.p - p00.p)
			if n.length_squared() < 1e-10:
				n = up
			else:
				n = n.normalized()
			_tri(st, p00, p10, p11, n)
			_tri(st, p00, p11, p01, n)
			if wet < 0.35 and p00.h > 0.06 and p00.h < 0.55 and tree_xforms.size() < TREE_MAX:
				var seedn := _hash(Vector2(float(i), float(j)))
				if seedn > 0.82:
					var t := Transform3D()
					var s := 0.012 + seedn * 0.028
					t.basis = Basis(east, n, north).orthonormalized().scaled(Vector3(s, s * (1.6 + seedn), s))
					t.origin = p00.p + n * s * 0.9
					tree_xforms.append(t)
	_ground.mesh = land_st.commit()
	_ground.material_override = _mat(false)
	_water.mesh = wat_st.commit()
	_water.material_override = _mat(true)
	_place_trees(tree_xforms)


func _vert(hit: Vector3, up: Vector3, east: Vector3, north: Vector3, half: float, u: float, v: float, radius: float) -> Dictionary:
	var off: Vector3 = east * ((u - 0.5) * 2.0 * half) + north * ((v - 0.5) * 2.0 * half)
	var dir: Vector3 = (hit + off).normalized()
	var uv := _dir_uv(dir)
	var h := _sample(_himg, uv).r
	var w := _sample(_simg, uv).r
	var land := 1.0 - w
	# Real hills, lifted so a 101 m pass reads relief. Water stays on the skin.
	var lift := maxf(h - 0.05, 0.0) * land * 3.2
	var p: Vector3 = dir * (radius + lift)
	var col := _sample(_aimg, uv)
	return { "p": p, "h": h, "w": w, "c": col, "uv": uv }


func _tri(st: SurfaceTool, a: Dictionary, b: Dictionary, c: Dictionary, n: Vector3) -> void:
	st.set_normal(n)
	st.set_color(a.c)
	st.set_uv(a.uv)
	st.add_vertex(a.p)
	st.set_normal(n)
	st.set_color(b.c)
	st.set_uv(b.uv)
	st.add_vertex(b.p)
	st.set_normal(n)
	st.set_color(c.c)
	st.set_uv(c.uv)
	st.add_vertex(c.p)


func _dir_uv(dir: Vector3) -> Vector2:
	var lon := atan2(dir.z, dir.x)
	var lat := asin(clampf(dir.y, -1.0, 1.0))
	return Vector2(lon / TAU + 0.5, 0.5 - lat / PI)


func _sample(img: Image, uv: Vector2) -> Color:
	if img == null:
		return Color(0.2, 0.25, 0.15)
	var x := int(floor(fposmod(uv.x, 1.0) * float(img.get_width())))
	var y := int(floor(clampf(uv.y, 0.0, 0.999) * float(img.get_height())))
	return img.get_pixel(x, y)


func _hash(p: Vector2) -> float:
	return fposmod(sin(p.dot(Vector2(127.1, 311.7))) * 43758.5453, 1.0)


func _mat(water: bool) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.vertex_color_use_as_albedo = true
	m.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	m.roughness = 0.22 if water else 0.92
	m.metallic = 0.05 if water else 0.0
	if water:
		m.albedo_color = Color(0.06, 0.22, 0.32)
		m.emission_enabled = true
		m.emission = Color(0.02, 0.08, 0.12)
		m.emission_energy_multiplier = 0.25
	else:
		m.albedo_color = Color(1, 1, 1)
	return m


func _make_tree_multimesh() -> MultiMesh:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = _tree_mesh()
	mm.instance_count = TREE_MAX
	return mm


func _tree_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var brown := Color(0.28, 0.18, 0.08)
	var green := Color(0.12, 0.32, 0.10)
	_box(st, Vector3(0, 0.35, 0), Vector3(0.12, 0.7, 0.12), brown)
	_cone(st, Vector3(0, 1.35, 0), 0.55, 1.4, green)
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.roughness = 0.9
	st.set_material(mat)
	return st.commit()


func _box(st: SurfaceTool, mid: Vector3, size: Vector3, col: Color) -> void:
	var h := size * 0.5
	var p := [
		mid + Vector3(-h.x, -h.y, -h.z), mid + Vector3(h.x, -h.y, -h.z),
		mid + Vector3(h.x, h.y, -h.z), mid + Vector3(-h.x, h.y, -h.z),
		mid + Vector3(-h.x, -h.y, h.z), mid + Vector3(h.x, -h.y, h.z),
		mid + Vector3(h.x, h.y, h.z), mid + Vector3(-h.x, h.y, h.z),
	]
	var faces := [[0,1,2,3], [5,4,7,6], [4,0,3,7], [1,5,6,2], [3,2,6,7], [4,5,1,0]]
	for f in faces:
		var n: Vector3 = (p[f[1]] - p[f[0]]).cross(p[f[2]] - p[f[0]]).normalized()
		st.set_normal(n); st.set_color(col); st.add_vertex(p[f[0]])
		st.set_normal(n); st.set_color(col); st.add_vertex(p[f[1]])
		st.set_normal(n); st.set_color(col); st.add_vertex(p[f[2]])
		st.set_normal(n); st.set_color(col); st.add_vertex(p[f[0]])
		st.set_normal(n); st.set_color(col); st.add_vertex(p[f[2]])
		st.set_normal(n); st.set_color(col); st.add_vertex(p[f[3]])


func _cone(st: SurfaceTool, tip: Vector3, rad: float, ht: float, col: Color) -> void:
	var base := tip - Vector3(0, ht, 0)
	var nseg := 6
	for i in nseg:
		var a0 := TAU * float(i) / float(nseg)
		var a1 := TAU * float(i + 1) / float(nseg)
		var p0 := base + Vector3(cos(a0) * rad, 0, sin(a0) * rad)
		var p1 := base + Vector3(cos(a1) * rad, 0, sin(a1) * rad)
		var n: Vector3 = (p0 - tip).cross(p1 - tip)
		if n.length_squared() < 1e-8:
			n = Vector3.UP
		else:
			n = n.normalized()
		st.set_normal(n); st.set_color(col); st.add_vertex(tip)
		st.set_normal(n); st.set_color(col); st.add_vertex(p0)
		st.set_normal(n); st.set_color(col); st.add_vertex(p1)


func _place_trees(xforms: Array[Transform3D]) -> void:
	var mm := _trees.multimesh
	mm.instance_count = TREE_MAX
	var n := mini(xforms.size(), TREE_MAX)
	mm.visible_instance_count = n
	for i in n:
		mm.set_instance_transform(i, xforms[i])
