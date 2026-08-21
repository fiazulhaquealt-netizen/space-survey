class_name FlightMode
extends RefCounted
# Zone is where. Mode is how. Exclusion is the no-cruise bubble (Elite EZ, real size).

const CRUISE := "CRUISE"
const LOCAL := "LOCAL"
const AIR := "AIR"


const STAR_CHROMOSPHERE_KM := 2500.0   # real chromosphere; corona is visual, not a cruise wall
const AIRLESS_EZ_KM := 10.0            # dump before the skin; vacuum has no 25% fake air


static func exclusion_from_center(radius: float, air_top: float, is_star: bool) -> float:
	if is_star:
		return radius + STAR_CHROMOSPHERE_KM
	if air_top > 0.0:
		return radius + air_top
	return radius + AIRLESS_EZ_KM


static func can_cruise(zone: String, dist: float, exclusion: float) -> bool:
	if zone != "SPACE":
		return false
	return dist > exclusion


static func of(zone: String, time_rate: float, cruise_ok: bool) -> String:
	if zone == "AIR":
		return AIR
	if zone == "SPACE":
		if time_rate > 1.001 and cruise_ok:
			return CRUISE
		return LOCAL
	return zone


static func must_drop(zone: String, time_rate: float, dist: float, exclusion: float) -> bool:
	return time_rate > 1.001 and not can_cruise(zone, dist, exclusion)


# If a step starts outside EZ and would enter or punch through, sit on the shell
# and dump speed. Already inside: leave it (air drag / skin kill own that).
static func break_at_exclusion(pos: Vector3, vel: Vector3, dt: float, center: Vector3, ez: float) -> Dictionary:
	var miss := { "pos": pos, "vel": vel, "dropped": false }
	if dt <= 0.0 or ez <= 0.0:
		return miss
	var w: Vector3 = pos - center
	var r0 := w.length()
	if r0 <= ez:
		return miss
	var a := vel.length_squared()
	if a < 1.0e-16:
		return miss
	var b := 2.0 * vel.dot(w)
	var c := r0 * r0 - ez * ez
	var disc := b * b - 4.0 * a * c
	var t := -1.0
	if disc >= 0.0:
		t = (-b - sqrt(disc)) / (2.0 * a)
	var end: Vector3 = pos + vel * dt
	var ends_inside := (end - center).length() <= ez
	if t <= 0.0 or t > dt:
		if not ends_inside:
			return miss
		t = clampf((-b) / (2.0 * a), 0.00001, dt)
	var hit: Vector3 = pos + vel * t
	var n: Vector3 = hit - center
	if n.length_squared() < 1.0e-12:
		n = w
	n = n.normalized()
	return { "pos": center + n * ez, "vel": Vector3.ZERO, "dropped": true }
