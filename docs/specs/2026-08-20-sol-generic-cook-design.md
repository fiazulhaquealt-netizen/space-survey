# Generic Sol cook — evidence maps, lazy extras

One cook. Every Sol world is a recipe. Real maps when we have them. Invented look when we do not. You still do not land.

## Contract

- **Planet generator** is the cook. Same shader for Sun, planets, moons, invented exoplanets.
- **Recipe** is per-body data. `albedo` is the evidence slot. Kind / colors fill the gap.
- Sol bodies (Sun, planets, major moons) have a named recipe. Other stars cook from catalog spectral type. Exoplanets invent from radius/temp. No one mesh per world.
- Albedo binds at spawn so a far sky disc is still that world.
- Clouds, night, height, spec, normal bind when the player is close.
- Saturn rings use the SSS radial strip on the annulus.
- No landing.

## This slice

- Sun photosphere map + limb darkening (kind 3).
- Physical moons with real radii, Horizons ids, fallback parent+sma.
- Maps on disk for Sun, Saturn rings, Io, Europa, Titan, Enceladus (plus the earlier planet set).
- Follow-on mosaics in the same albedo slot: Ganymede, Callisto, Phobos, Cassini majors, Uranian majors, Triton, Pluto, Charon.
- Pending-map recipe for Deimos until a 2k mosaic lands in the same slot.

## Not this slice

USGS 8k mosaics, 3D terrain, landing, every small moon, Earth polish, unlabeled Ganymede swap.

## Check

- `recipe_for("Sun").kind == star` and the map exists.
- `recipe_for("Europa")` has a map. `recipe_for("Phobos")` has a map. `recipe_for("Deimos")` is named even if the file is missing.
- Earth extras stay off until `ensure_close_maps`.
- Newton tests still pass. Io has a real GM.
