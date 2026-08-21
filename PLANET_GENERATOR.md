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

## Plane band (later — possible, not this slice)

**Yes.** A Google-Earth-*feel* from a plane is possible on every planet, moon, and (with a different kit) a star’s skin — without Google, without a mesh per world, without killing the frame rate.

Google Earth 3D tiles are **not** allowed. We do not stream their photogrammetry. The cook already has the legal path: NASA / USGS height where we have it, invented height from the recipe seed where we do not.

### What it is

You drop at EZ. Speed is forced down (safety). Inside the air / the last tens of km you fly at **m/s**, like a plane. The cook globe stays the horizon. Under the hull, one **local tile** rebuilds: hills from height, water from the mask, low-poly kit (rock, ice, tree, lava). Leave the band, the tile dies. You still do not land.

Same system for every body. Recipe picks the kit. Earth: real DEM + water. Mars: rock + ice caps. Europa: ice. Titan: haze + methane lakes as a paint. Invented exoplanet: fbm from seed. Stars: no air, no trees — only if we ever want a chromosphere kit.

### Why it does not hurt performance

- Only the **nearest** body, only while you are in its EZ / air.
- One tile (tens of km, not a planet). Rebuild when you move a few km, not every frame.
- Low-poly kit instances (hundreds, not millions). No unique GLB per world.
- Far systems stay HYG points. A billion worlds never all exist as mesh.
- “Prerender” here means **bake the tile on entry** (height mesh + prop list), then draw it cheap. Not a video, not a planet-sized cache.

### Speed

Cruise dies at EZ (already). Then a **safety cap** so you cannot F9 through the tile: EZ dump to local, air / last-km band in m/s. Sol already has unused approach speed-zones; they stay off until this band is real. Fat engines stay a debug key, not the plane pass.

### Honest limits

- Earth kill is **29 km**. A true plane pass wants ~0.5–8 km. That kill line has to move, or Earth never sees hills as objects. Airless worlds already allow 100 m, so they get the band first.
- This is a **survey flyover**, not a landing game. Skin still kills if you go below the floor.
- It will look like a low-poly aerial, not photogrammetry. That is the point: readable water and relief at m/s, 60 fps on a potato.

### Do not build yet

Keep EZ as the cook globe (the 36 km black stamp at 100 km was the wrong layer). Plane-band tile + kit + safety cap is the next visual slice after the globe reads at EZ.

## Not this slice

Landing. 50 unique planet models. Volumetric air. Gridless mosaic downloads. Rich tree kits. Google Earth tiles. Plane-band tile (see above).
