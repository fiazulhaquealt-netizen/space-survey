# Flight modes — cruise, local, air

Zone is **where** the hull sits. Mode is **how** it flies. The tape already has ZONE. This slice names MODE and drops cruise at a body's **exclusion** — Elite's EZ, real size.

Same shells as `2026-08-20-sol-flight-layers-design.md`. No landing. Not Elite's tiny worlds.

## Exclusion (no-cruise bubble)

From the body's centre:

| Body | Exclusion | Why |
|---|---|---|
| Earth | radius + 100 km | Karman |
| Venus / Mars / Titan / giants | radius + real air column | See `ATMO_TOP_KM` |
| Airless world | radius + 10 km | Vacuum; dump before the skin |
| Star | radius + 2500 km | Chromosphere. Corona is look, not a wall |

Cruise never punches a world. Moon at 1 km alt is still ZONE SPACE, but **inside EZ** → LOCAL, not CRUISE.

## Flow

```
           period faster (outside EZ, SPACE only)
  LOCAL ────────────────────────────────────────► CRUISE
    ▲                                              │
    │ climb out of EZ                              │ hits any exclusion
    │                                              ▼
    │                                            DROP  (short cue, not a white screen)
    │                                              │
    ├──────── LOCAL (airless EZ / LEO) ◄───────────┤
    │                                              │
    └──────── AIR (Earth below 100 km) ◄───────────┘
                    │
                    ▼
                  SKIN = kill (already)
```

- **LOCAL** — not cruising. Newton. Orbit or fall. Spawn is this. Also: inside an airless EZ.
- **CRUISE** — SPACE, outside EZ, time ×N. Same Newton, clock faster. Not a new FTL.
- **AIR** — Earth 29–100 km. Drag + co-rotate. Plane. Time ×1.
- **DROP** — one-shot when time ×N hits any EZ. Cue, then LOCAL or AIR.

## Cue

Not Elite's white blink as the whole trick. That hides a tiny-planet LOD swap. Ours is 100 km thick.

Drop cue: speed line says `DROP` for ~0.4 s, a brief HUD flash. Stars/drag already change with the physics. No fullscreen wash.

Slow sink from LOCAL into AIR: no DROP. Drag ramps. Mode just becomes AIR.

## Speedo

Do not rebuild the meter. Tag it.

`Speed  80 m/s  · AIR`
`Speed  3.07 km/s  · LOCAL  · Earth`
`Speed  0.2 km/s  · CRUISE  ×50`

Tape keeps `Zone`. Add `Mode`. Zone SPACE + Mode CRUISE is legal. Zone AIR + Mode CRUISE is not.

## Contract

- `FlightMode.exclusion_from_center(radius, air_top, is_star) -> float`
- `FlightMode.can_cruise(zone, dist, exclusion) -> bool` — SPACE and dist > exclusion.
- `FlightMode.of(zone, time_rate, cruise_ok) -> String` is `CRUISE` | `LOCAL` | `AIR` | the zone word for SKIN/INSIDE/CENTER.
- `FlightMode.must_drop(zone, time_rate, dist, exclusion) -> bool` when time_rate > 1 and not can_cruise.
- Time warp already dies in Earth air. It must also die inside any EZ.
- Other star systems unchanged.

## This slice

1. Pure `FlightMode` + headless tests.
2. Ship reports mode; drop fires once at the air line.
3. HUD Mode line + DROP tag + short flash.
4. CONTEXT language: **Flight mode**.

## Not this slice

Sun vanish LOD. Horizon-not-marble. Volumetric air shell. Titan/Venus air. New FTL. Elite glide minigame. Landing. Speedo redesign.

## Check

- GEO, time ×1 → Zone SPACE, Mode LOCAL. Outside Earth EZ.
- GEO, period warp ×50 → Mode CRUISE.
- 50 km Earth alt → Mode AIR, time_rate 1, must_drop if it was cruising.
- Moon 1 km alt → Zone SPACE, inside EZ, can_cruise false, Mode LOCAL.
- Sun inside 1.2 R → can_cruise false.
- Newton tests still pass.
