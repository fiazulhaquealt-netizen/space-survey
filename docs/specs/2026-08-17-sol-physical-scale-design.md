# Sol Physical Scale (slice 1)

Destination is Kerbal-style 1:1 Newtonian physics. This slice is **Sol only**: real Sun, real Earth, real 1 AU gap. Speed, gravity, other planets, orbits, and time warp are out of scope.

## Constants

- 1 scene unit = 1 kilometre.
- `AU_TO_UNITS = 149_597_870.7`
- Earth radius = 6,371 km. Sun radius = 696,340 km.
- Earth–Sun centre distance = 1 AU (live JPL vector × `AU_TO_UNITS`).
- Spawn = geostationary: 42,157 km from Earth's centre, on the anti-Sun ray.
- Earth stays the geocentric origin. Pipeline unchanged: AU → scene units → `true_pos` → render at `(body - ship)`.

## This slice

- Spawn only Sun and Earth in Sol. Hide Mercury–Neptune, moons, Voyagers.
- `physical` bodies never use `VISUAL_SCALE` and never swap to a far sprite — the mesh is the correct angular size.
- Camera far plane past ~2.5 AU so the Sun and starfield stay visible from Earth.
- Starfield + galaxy sit on a ~2.5 AU shell (scale the existing 6,000-unit mesh; do not rebake).
- Sol dock and Finn park a few tens of km off GEO so F-dock still works.
- Sol wormhole gates sit ~80,000 km from Earth (outside the planet, findable).
- Sol speed-zones off. Do not retune thrust, warp, or `GRAV_G`.
- Old Sol saves inside Earth snap to GEO.

## Not this slice

Newton pull, real orbital speed, time warp, other planets, ship-in-metres, other star systems' layouts.
