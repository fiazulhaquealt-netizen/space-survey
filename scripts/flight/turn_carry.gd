class_name TurnCarry
extends RefCounted
# Sol flight assist: a turn carries speed with the hull.


static func apply(vel: Vector3, old_b: Basis, new_b: Basis) -> Vector3:
	return new_b * (old_b.inverse() * vel)
