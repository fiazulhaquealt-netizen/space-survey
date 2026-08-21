# Planet cook

One system paints every world. Catalog row → true position → **recipe** → ball.
You do not land. A billion stars stay sky points until you are there.

## Contract

- **Planet generator** is the cook. Same shader for Sun, planet, moon, invented exoplanet.
- **Recipe** is per-body data. Real map path when we have evidence. Kind, colors, heat when we do not.
- Sky is HYG points. Cook a ball only when the player is in that system.
- No unique mesh per world. A small **kit** (rock / ice / tree / lava) is for bird-eye props, not a GLB per planet.
- Sol maps stay in the albedo slot. Swap later for gridless USGS / NASA / ESA.

## Draw path (LOD)

| Where | What you see |
|---|---|
| Far (past the far plane) | Sky disc, real angular size, same recipe |
| **EZ** (exclusion) | Cook **mesh**. High bird-eye: curve, continents, weather, craters. Not a 36 km stamp. |
| Skin (last few km; Earth dies at 29 km) | Local ground patch + kit props on airless worlds. Still no landing. |

The mesh cut is the **near face**, not the centre. A star bigger than the far plane still becomes a ball when you close in.

EZ is the no-cruise bubble (Earth 100 km air, airless +10 km, star chromosphere). That is where bird-eye must read as a real world, not a sticker.

## The three visual bugs

Named so we do not “fix the wrong thing”:

1. **Pacman balls** — Voyager / incomplete mosaics paint unmapped limbs as **black void**. Wrapped on a sphere that is a bite taken out of the world. The cook fills near-black texels with invented crust of the recipe colors. Stars skip this (dark sunspots stay).
2. **Sheet text** — some albedo files still carry USGS grid / labels (Ganymede named). Same slot; swap the file, do not special-case the mesh.
3. **Black boxes** — 101 m tree placeholders were shaded boxes in a dark scene. Unshaded kit primitives until real props land. Missing GLB textures are the other source; craft keep models, worlds do not.

## Render log

Tape, Sol only:

```
Cook    31  · mesh 2  · sky 29
Look    Earth  mesh  ready-map  rocky
```

`Look` is the nearest body: draw path, recipe source, kind. Every cooked world has a recipe with name, kind, source, evidence.

## Scale

Far: one point. Arrive: one cook from the recipe. EZ: the same ball, close maps bind. Unique planet GLBs cannot reach a billion.

## Not this slice

Landing. 50 unique planet models. Volumetric air. Gridless mosaic downloads. Rich tree kits.
