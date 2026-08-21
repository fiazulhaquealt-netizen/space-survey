# Recipe-driven planet nights

## Problem

The shared planet shader renders every non-star night side as `col * 0.04`.
Large nearby bodies therefore look like featureless black circles while still
correctly occluding the background starfield. The behavior is shared by Earth,
moons, gas giants, and generated exoplanets, even though their atmospheres,
temperatures, albedos, and internal emission differ.

## Goal

Keep solid worlds opaque, but make their night appearance come from the same
recipe that drives their day appearance. A player should recognize a body and
its limb without seeing background stars through it.

## Design

`PlanetGenerator` will derive a compact night profile for every recipe:

- `night_ambient`: low indirect illumination from starlight, body-shine, and
  atmospheric scattering. Airless rocks remain darkest; atmospheres, gas
  giants, and reflective ice receive progressively more readable fill.
- `thermal_emission`: visible self-emission derived from equilibrium
  temperature when catalog evidence provides it, with a recipe override for
  exceptional worlds.
- `thermal_color`: warm emission tint, also overridable by the recipe.

Named recipes can override those values. Invented exoplanet recipes retain the
catalog equilibrium temperature so the same derivation works across the
billion-target generator rather than requiring hand-authored exceptions.

The shader will combine textured/procedural albedo, the derived indirect term,
night maps/city lights, and thermal emission. Existing atmospheric limb color
will also receive a small night contribution based on `air_amount`. Direct
stellar lighting and the day/night terminator remain unchanged.

Stars remain a separate emissive shader branch. Planet meshes continue to
write depth, so the starfield never shows through a solid body.

## Scope

This change touches the recipe derivation/material binding and the shared
planet shader. It does not add multiple scattering, ray tracing, volumetric
clouds, landing, or per-world meshes.

## Verification

Implementation is gated by a deterministic GPU smoke scene, not only source
assertions. The scene renders four night-facing bodies through the production
`PlanetGenerator` and production shader:

- Earth-like atmosphere with a night map;
- cold airless moon;
- internally warm gas giant;
- hot generated rocky world.

All four render against an intentionally dense star backdrop, with known bright
markers placed behind the planet discs. The smoke run saves one comparison PNG
and checks representative pixels. It fails unless:

- each night disc is distinguishable from the black sky;
- the four recipes do not collapse to one universal brightness;
- the cold airless moon remains the darkest case;
- the hot world and gas giant retain recipe-appropriate emission/fill;
- bright markers behind each solid disc remain occluded;
- background markers immediately outside each limb remain visible.

Focused automated tests will additionally establish that:

- every generated non-star recipe receives a bounded night profile;
- atmospheric, gas, ice, airless, and hot recipes produce distinct values;
- catalog equilibrium temperature reaches the recipe;
- the material binds the derived profile;
- the shader no longer contains the universal `col * 0.04` night rule.

The original gameplay frame is the final manual smoke check. Before/after
captures use the same body, distance, camera direction, and exposure. The night
side must become recognizable, its curved limb must remain intact, and stars
must remain hidden behind it while remaining visible outside it. If the
comparison image does not make the improvement obvious, the change does not
ship even when unit tests pass.
