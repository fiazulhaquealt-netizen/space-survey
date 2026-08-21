# Flight layers — center, skin, air, space

You fly around a body. The hull must always know which shell it is in.
Same rule for a planet, a moon, or a star. The Sun is a star, not a special object.

## Shells (from the centre out)

| Zone | Meaning | Sol Earth | Sol Sun | Airless moon |
|---|---|---|---|---|
| CENTER | Deep inside the radius (≤ 15% r) | — | — | — |
| INSIDE | Below the skin | r < 6371 km | r < 696,340 km | r < body |
| SKIN | Kill band above the skin | 0–29 km alt | 0–100 m alt | 0–100 m |
| AIR | Physical atmosphere | 29–100 km | none (corona is visual) | none |
| SPACE | Outside air, or outside skin if airless | > 100 km | outside photosphere | > 100 m |

Tape shows `Zone` + skin altitude. Speed line tags the same word (`SPACE` / `AIR` / …).

## This slice

- `Ephemeris.flight_zone(name, dist)` and `atmo_top_km(name)`.
- Earth air only (drag already uses 100 km). Titan/Venus air later.
- Star cook (kind 3) burns: granules, limb darkening, chromosphere rim. Sky disc uses the same shader. Circular corona card stays a far glare, not the star itself.

## Not this slice

Per-body air tables, corona as a physics shell, HUD map of layers, landing.

## Check

- GEO Earth → `SPACE`.
- 50 km Earth alt → `AIR`.
- 6000 km from Earth centre → `INSIDE`.
- Moon 1 km alt → `SPACE`.
- Sun from GEO → `SPACE`.
