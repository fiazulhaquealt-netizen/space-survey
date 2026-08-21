# Sol first pass — session dump (2026-08-17 → 2026-08-18)

This is the pickup note. **Nothing here is finished.** Every feature is a first cut. Come back and perfect each one.

Public game repo stays `Fiazul/Astryx` at v0.11.5 (`b591548`). This work was parked on a **new private repo** so we can keep going without dumping a half-done Sol onto `main`.

## Standing rule

First pass now. Perfection later. Do not treat any Sol feature as done.

Needs a later pass: naked sky, Newton pull, Earth air, speedo, engines, time warp, Sol worlds / sky discs, labels, flight feel, leftover arcade.

## Destination

Kerbal-style 1:1 Sol. Honest look. Honest pull. Honest speed. You will **not** land. Later a planet generator paints close-to-real ground. Still no landing.

Other star systems stay authored arcade arenas.

## What landed (first cut)

### Sky
- Naked-eye HYG bake, mag ≤ 7, ~15,598 stars, honest B−V colour.
- Default quality `naked`. Asset: `assets/starfield_naked.res`.
- Tycho-2 missed first-magnitude stars, so the naked sky is HYG, not Tycho.
- Painted Milky Way mesh is **hidden**. From Sol you would not see an outside-in spiral. The HYG field is the band.

### Units and camera
- 1 scene unit = 1 kilometre.
- Pipeline unchanged: JPL AU → units → `true_pos` → render at `(body − ship)`.
- Earth radius 6,371 km. Sun 696,340 km. GEO spawn 42,157 km, sunlit, **parked** (no circular speed).
- Camera far 520,000 km so the Moon is a real cook ball from GEO. Sky shell 160,000 km (stars, no depth test). Chase cam is hull-lengths (~80 m ship), not kilometres.
- Sun sky impostor ~0.53° so the real Sun (1 AU, past the far plane) is still a disc.

### Newton
- Inverse-square `GM / r²` for Sun, Moon, Mercury–Neptune, Earth.
- Arcade idle-release, outward fade, vacuum damping, near-body settle: **off** in Sol.
- Ground clamp on Earth’s skin. No fall-through. No landing.
- Time-warp substeps recompute live GM so a long coast stays stable.

### Atmosphere
- Physical only: 100 km top, scale height 8.5 km, drag `a = 500 × 0.005 × ρ × v²`.
- Blue shell **removed**. It looked ugly. Drag stays.

### Speed and engines (Sol only)
- Speedo: m/s below 1 km/s, else km/s. Tags: `air`, `in` / `out`, `×N` time warp.
- Test tape: altitude, circular speed at this height, escape speed.
- Engines: 2 g forward, 1 g strafe, boost ×3. No Sol FTL spool. No 550 cap.
- Arcade thrust / warp stay in other systems.

### Time warp
- `.` / `]` faster, `,` / `[` slower.
- Rates: 1, 5, 10, 50, 100, 1000, 10000, 100000.
- Snaps to 1× in air or when you burn.

### Worlds
- Mercury–Neptune + Moon at real radii, live JPL when the net is up.
- Past the far plane: sky disc at real angular size + AU/km label.
- Fake visual orbits off for physical bodies.
- Voyagers and extra moons (Phobos, Titan, …) not in this pass.
- Painted-ball generator: one cook, unique recipe. Sol uses 2k maps + Earth clouds/night. Earth has a thin air limb in the shader (blue marble, not a fat shell). Other worlds get invented land/ocean. Close-up hill paint on the same ball. No landing.

### Debug (Sol only)
- **F6** — circularize at current height (kills leftover arcade speed).
- **F7** — park at sunlit GEO, velocity zero.
- **F9** — toggle DEV engines (×10000). Burn-warp stays on. Dies in air. GEO→skin in tens of seconds. F8 is the editor stop key.
- **F10** — point the nose at Earth. Q is roll only; it does not face you at Earth.
- Tape in the top-left nav box.

## Known sharp edges (why we will come back)

- Nose-at-Earth ≠ flying at Earth. Huge leftover velocity made range climb; `in`/`out` + F6/F7 exist because of that.
- 2 g cannot kill 100+ km/s in a few seconds. That is honest. It feels broken without the tape.
- Time warp dies on any burn, so circularizing by hand is slow. A small “burn warp” is a later test aid, not shipped.
- World labels used to say hundreds of AU for kilometre ranges. Fixed in `_fmt_nav_dist`. Watch for other 0.01-AU leftovers.
- Camera far vs AU worlds: impostors are a first cut. Depth, disc quality, Moon from GEO all need a look.
- Earth GLB / other planets are placeholders. Generator later.
- Flip leap no longer slams arcade speed in Sol. Other arcade leftovers may still hide.

## Later (do not build until asked)

- Placed features (volcanoes). Space paint + close-up paint are in.
- Vacuum RCS / empty-space spin
- Other moons
- Flight feel / units cleanup
- Perfection pass on every first-cut feature above

## How to pick this up

```
git clone git@github.com:Fiazul/space-survey.git
# or pull remote `lab` if this working tree is already linked
```

Play: spawn, watch the tape, F7 if cursed, F6 to test a circle (~3.07 km/s at GEO). Period to skip the fall. Tab the planets.

Language and the standing rule live in `CONTEXT.md`.

## Tests

```
godot --headless --path . --script res://tools/test_newton.gd
godot --headless --path . --script res://tools/test_galaxy_backdrop.gd
```
