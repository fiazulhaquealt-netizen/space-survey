# No landing — skin kill

Core mechanic. These hulls are strong. They cannot land.

## Rule

Closer than the kill altitude to any physical surface: 2.5 s cutscene, then the hull is dead and you are thrown home.

## Number

- Floor is **100 m** (`0.1` km). Never go below this, including tests.
- The live value is `Ephemeris.surface_kill_km(body)`. Start at the floor.
- Later this function may **raise** the line per body (gravity). It must never return below the floor.

## This slice

- Sol physical bodies only (Earth, Moon, planets, Sun).
- Freeze, 2.5 s, flash, then emergency home with a wrecked hull.
- Ground clamp no longer saves you.

## 101 m view (same pass, first cut)

From just above the line the painted ball is a wall. A local ground patch (hills from NASA height, water from the spec mask, simple trees) sits under the ship. Still no landing mesh.

## Not this slice

Google Maps 3D, real photogrammetry, walking on the ground, per-planet gravity raise (hook only).
