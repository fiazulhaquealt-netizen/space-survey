# Earth GEO wow — blue marble

Hero shot: Earth from GEO. LinkedIn still. Still a ball. You still do not land.

## Decision

Thin air limb **in the cook shader**, Earth only. Not a second shell. Not the fat blue bubble we already killed.

## Why this

From GEO, Earth is already big enough. The missing wow is the ISS look: a thin blue limb, a soft terminator, clouds sitting on the ocean. Resolution is not the hole. The hole is air.

## This slice

- Recipe flag `air_amount`. Earth = 1. Everyone else = 0.
- Fresnel limb (blue, day-bright, night-thin).
- Soft blue terminator. Clouds darken the ground under them. Ocean glint stays.
- Same cook on Earth’s sky disc so a far Earth is still a marble.
- Keep the 2k map unless a NASA Blue Marble lands in the same albedo slot.

## Close-up (same cook)

At 1 km the limb was a blue wall. Air now fades with `detail`. Earth uses NASA/GEBCO height + Solar System Scope water mask/normal. Close-up: waves on ocean, hills displaced on land. Still a ball. Still no landing. Google Maps / Earth 3D tiles are not used.

## Check

From GEO, Earth has a thin blue rim and readable continents. No soap-bubble shell. Newton still passes.
