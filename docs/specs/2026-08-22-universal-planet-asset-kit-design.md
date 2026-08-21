# Universal Planet Asset Kit Design

## Goal

Build one small, reusable low-poly asset library for close planetary flyovers. A
physical planet recipe selects, colors, scales, and distributes the library so
that a billion possible worlds do not require a billion unique models.

## Acquisition scope

Import the free CC0 material from these approved sources:

- KayKit Forest Nature Pack
- Quaternius Stylized Nature MegaKit free edition
- Kenney Nature Kit
- Quaternius Modular Platformer Pack cloud forms
- Quaternius Ultimate Space Kit vegetation and unusual natural forms
- KayKit Resource Bits free edition
- Poly Pizza iPoly3D Crystal Pack
- The individually verified Poly Pizza CC0 rocks, trees, ice, and cloud models

Paid tiers are excluded. Poly Pizza models whose exact license cannot be archived
are excluded. The game must not depend on a marketplace or network connection at
runtime.

## Asset layout and provenance

Downloaded source archives and license evidence stay separate from runtime files.
Each accepted source gets a ledger entry containing its official URL, creator,
license, acquisition date, downloaded archive name, and any local modifications.
`CREDITS.md` summarizes those records for players and distributors.

Runtime models live under `assets/planet_kit/`, grouped by morphology rather than
by planet: `rocks`, `plants`, `crystals`, `clouds`, and `exotic`. Prefer glTF/GLB
for Godot. The shipped game uses curated imported resources, not whole raw asset
archives.

## Recipe boundary

The catalog and physical evidence produce a recipe containing world kind,
temperature, pressure, atmospheric composition, liquids, ice, geology, weather,
and biosphere likelihood. The recipe then emits morphology and material choices.

Examples:

- A rock mesh can become lunar ejecta, oxidized Martian stone, fresh basalt, or a
  frost-covered boulder.
- A faceted mesh can represent water ice, salt, sulfur, silicate, or an ore only
  when local chemistry and temperature support it.
- Recognizable vegetation requires a supported biosphere. Branching geometry may
  represent mineral deposits when it uses mineral materials and placement rules.
- Cloud geometry requires a plausible atmosphere and condensate or aerosol.

Color alone must not turn a hot phenomenon into a cold one. Lava and
cryovolcanism use distinct materials and effects.

## Runtime design

Only the nearest body's local-detail tile owns surface instances. Recipes choose
from a deliberately small pool: roughly 12–20 rocks, 8–12 trees, 12–20 smaller
plants, 4–8 crystal forms, and 3–6 cloud forms. Godot MultiMesh instances vary
transform and material parameters cheaply. The tile and its instances are freed
when the player leaves the detail band.

Terrain, shorelines, water, hydrocarbons, lava, vents, fissures, plumes, dust,
and orbital cloud cover remain project-generated. Downloaded models provide
silhouettes, not planetary simulation.

## Failure handling

- Skip any source whose license or download provenance cannot be archived.
- Keep optional packs isolated so one failed download does not block the base kit.
- Reject broken imports, extreme polygon counts, missing materials, and unusable
  pivots during ingestion rather than compensating at runtime.
- Preserve original archives and license files outside runtime export paths so an
  asset can be audited or replaced later.

## Verification

- Confirm every imported source is CC0 and represented in the provenance ledger
  and `CREDITS.md`.
- Open or headlessly import all selected glTF/GLB files in Godot without parser or
  missing-resource errors.
- Measure model counts and repository size after curation.
- Render one neutral test tile with instanced rocks, crystals, vegetation, and
  clouds to verify material overrides without building the complete plane band.

## Out of scope

Paid asset tiers, unclear licenses, Google Earth/Maps data, photogrammetry,
planet-specific model sets, rich volumetric clouds, and runtime marketplace
downloads.
