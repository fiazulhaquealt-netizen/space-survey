# Sol Newtonian gravity + Earth atmosphere

Parked GEO spawn. Real inverse-square pull from Earth and the Sun. Honest air: thin limb when Earth is large, blue disc from far, drag only inside the skin.

## Units

- 1 scene unit = 1 km. Time is seconds.
- `GM_EARTH = 398600.4418` km³/s². `GM_SUN = 1.32712440018e11` km³/s².
- Accel = `GM / r²` toward the body. No range cutoff, no arcade cap.

## Gravity

- Sol only. Earth and Sun. Other systems keep the old arcade wells.
- Spawn stays parked (no circular speed). You fall. Earth grows slowly; the air is about four hours away if you never burn.
- Arcade idle-release, outward fade, vacuum damping, and near-body settle are off in Sol. Those would cancel the fall.
- Empty-space rotation is still later. Speedo + Sol engines: see sol-speed-end-goal.
- Hit Earth's skin: stop there. Kill only the inward speed. Do not fall through.

## Atmosphere

- Physical top: 100 km. Scale height 8.5 km. Sea-level density 1.225 kg/m³.
- Drag: `a = 500 * ballistic * ρ * v²` km/s², `ballistic = 0.005` m²/kg. Zero above 100 km.
- Visual: none. Blue shell removed. Drag still applies below 100 km.

## Out of scope

Other planets, time warp, orbital spawn, flight retune, HUD speed tape, vacuum RCS.
