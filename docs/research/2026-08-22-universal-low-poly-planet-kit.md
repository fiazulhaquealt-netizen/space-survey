# Universal low-poly planet kit: asset research

Checked 2026-08-22. This is an asset-selection note, not legal advice. Only official creator/platform pages and the license publisher are cited. No assets were downloaded during this review.

## Recommended source packs

Use a small, curated CC0 library rather than choosing hundreds of unrelated Poly Pizza models:

1. **Primary surface library — [KayKit Forest Nature Pack](https://kaylousberg.itch.io/kaykit-forest).** The free tier has 100+ trees, rocks, bushes, and grass. The paid Extra tier adds modular terrain and eight color variants. Its 1,588 total variants use one 1024×1024 gradient atlas, which the creator says can be reduced to 128×128 and is suitable for mobile. That shared-atlas design is the best fit found for large amounts of instanced procedural dressing. Formats: FBX, glTF, OBJ; optional paid Blender source. License: CC0, commercial use and recoloring allowed, no attribution required. The creator asks users not to resell unmodified copies or claim authorship.
2. **Broader nature variation — [Quaternius Stylized Nature MegaKit](https://quaternius.com/packs/stylizednaturemegakit.html).** 116 models: 40 trees, 35 plants/flowers, 27 rocks, grass, and bushes; leaf textures can be swapped among seven variants. The free download contains 60–70% of the pack; paid tiers add the remainder and a Godot 4.3 project/source shaders. Formats: FBX, OBJ, glTF; Blender source in the source tier. License: CC0; the author explicitly permits personal, educational, and commercial projects.
3. **Completely free fallback — [Kenney Nature Kit](https://kenney.nl/assets/nature-kit).** 330 3D files tagged trees, rocks, and foliage, all CC0. Kenney's current 3D workflow distributes OBJ, FBX, and GLB, and [recommends GLB for Godot](https://kenney.nl/knowledge-base/game-assets-3d/importing-3d-models-into-game-engines). Kenney confirms that all asset-page game assets may be used commercially and that attribution is optional in its [official support FAQ](https://kenney.nl/support).
4. **Cloud geometry — [Quaternius Modular Platformer Pack](https://quaternius.com/packs/modularplatformer.html).** This is the clearest verified CC0 source for actual low-poly cloud meshes. It has 53 models including clouds and simple trees, in FBX, OBJ, and Blend. Commercial use is explicitly allowed. Use a few cloud silhouettes with recipe-selected scale, tint, opacity, altitude, and wind rather than unique geometry per planet.
5. **Alien/space accents — [Quaternius Ultimate Space Kit](https://quaternius.com/packs/ultimatespacekit.html).** 92 CC0 models including vegetation and planets, in FBX, OBJ, glTF, and Blend. This supplies a small pool of unusual silhouettes for barren/exotic recipes without needing planet-specific asset packs.
6. **Ore/crystal stand-ins — [KayKit Resource Bits](https://kaylousberg.itch.io/resource-bits).** The free tier has 75+ mobile-oriented models for stone, iron, copper, silver, gold, fuel, and other resources. Gems are in the $4.99 Extra tier. It uses a single reducible gradient atlas and ships OBJ, FBX, and glTF; optional Blender source is $7.49. The page marks every tier CC0 and says commercial use needs no attribution. Recolor and emissive materials can turn a few gem/ore silhouettes into ice, salt, crystal, sulfur, or alien mineral recipes.
7. **Poly Pizza CC0 gap-fill — [Crystal Pack by iPoly3D](https://poly.pizza/bundle/Crystal-Pack-AywAG7aywi).** 28 low-poly crystals, all labeled CC0, downloadable as FBX or glTF. This is a better ice/crystal pool than relying on the paid KayKit gems alone.

## Reusable morphology selection

Select a neutral silhouette family from environment physics first; let the recipe control material, scale, density, and effects. A cold result must not be only a blue recolor of a hot result.

| Morphology | Best verified neutral source | Material-override suitability | Physically grounded recipe gate |
|---|---|---|---|
| Rock / boulder | [KayKit Forest](https://kaylousberg.itch.io/kaykit-forest), [Kenney Nature](https://kenney.nl/assets/nature-kit), or [Poly Pizza: Rocks](https://poly.pizza/m/e1rgb5i2kF) | **Excellent.** Geometry is composition-neutral; override albedo, roughness, normal intensity, dust/frost cover, and optional emissive cracks. | Choose from geology/weathering and surface gravity. Temperature and atmospheric pressure/composition control frost, oxidation/weathering, rounding, and dust cover—not whether “rocks” exist. |
| Crystal / ice | [Poly Pizza: Crystal Pack](https://poly.pizza/bundle/Crystal-Pack-AywAG7aywi), [Crystal tagged Ice](https://poly.pizza/m/Ftu5CcnxFZ), [Ice Block](https://poly.pizza/m/dEY0gPZNzG), and [KayKit Resource Bits](https://kaylousberg.itch.io/resource-bits) | **Excellent for faceted solids.** Override transmission, index-like fresnel response, roughness, color, subsurface/fake-depth, and emission. | Use water-ice visuals only where local temperature/pressure make exposed ice plausible. Else map the same facets to salt, sulfur, silicate, metal ore, or other recipe-supported minerals. Volatile composition determines ice type; temperature controls brittleness/melt gloss and sublimation effects. |
| Vegetation / coral-like growth | [KayKit Forest](https://kaylousberg.itch.io/kaykit-forest), [Quaternius Stylized Nature](https://quaternius.com/packs/stylizednaturemegakit.html), [Pretty Park](https://poly.pizza/bundle/Pretty-park-set-G2WINPAG9S), with exotic accents from [Ultimate Space Kit](https://quaternius.com/packs/ultimatespacekit.html) | **Moderate.** Rocks and simple branching plants are reusable; obvious Earth trees/flowers are not environmentally neutral. Palette swaps alone will look arbitrary. | Spawn recognizable plants only when the recipe supports a biosphere, solvent/nutrient cycle, usable pressure range, and energy source. Branching “coral” forms can also represent mineral/vent deposits, but must use mineral materials and non-biological placement rules. Temperature and atmospheric chemistry select pigmentation, leaf cover, height, and wind response. |
| Vent / volcanic / cryovolcanic | Reuse the neutral rock pools above as rims, chimneys, and ejecta; generate fissures/plumes procedurally | **Excellent for rock geometry; no special downloaded vent is required.** Add a project-owned fissure decal/mesh, plume particles, and recipe material. | Gate on geological activity and volatile inventory. Hot silicate volcanism uses dark fresh rock, emissive cracks, lava material, ash/gas matched to atmospheric chemistry, and heat distortion. Cold cryovolcanism uses pale ice/mineral rims, non-emissive fractures, and condensation/ice plumes. Never recolor lava blue to represent cold vents. |
| Cloud / haze | [Quaternius Modular Platformer](https://quaternius.com/packs/modularplatformer.html) or [Poly Pizza: Cloud](https://poly.pizza/m/F6DzCxDz6I) | **Good at aircraft range.** Reuse a few silhouettes/cards; override tint, opacity, vertical thickness, soft-edge noise, and lighting. | Spawn only when atmospheric composition, pressure, and temperature permit condensation/aerosols. Condensate species controls color/absorption; pressure and convection control thickness/altitude; wind field controls movement. Use these meshes locally, not as the orbital cloud system. |
| Terrain / liquid surface | Generated terrain tile and project-owned plane/shore mesh; optional KayKit Forest Extra modular terrain for prototypes | **Best kept procedural.** Do not spend the asset budget on many water/lava props. | Liquid species must be stable at local temperature/pressure. Water, hydrocarbon liquids, and molten rock need distinct viscosity, reflectance, wave, fog, and emission behavior. Atmosphere affects wave/wind response and horizon haze. |

Recommended recipe output is a morphology ID plus physical material/effect parameters, for example `crystal_faceted + material=water_ice + sublimation=0.3`, rather than an art label such as `blue_crystal_planet`. This keeps the same small mesh library believable across many worlds.

## License and distribution matrix

| Source | Verified license | Attribution | Modify/recolor | Commercial shipped game | Raw-asset redistribution policy |
|---|---|---:|---:|---:|---|
| KayKit packs above | CC0 1.0 | No | Yes | Yes | CC0 permits copying and distribution, but the creator asks users not to resell unmodified copies or claim them as their own. Ship imported/processed game resources; do not publish a competing raw-asset bundle. |
| Quaternius packs above | CC0 | No | Yes | Yes | CC0 permits it. Still ship only the curated/imported game resources and retain a source/license ledger. |
| Kenney Nature Kit | CC0 | No; “Kenney” optional | Yes | Yes | CC0 permits it. Kenney reserves its logo for official Kenney projects, so do not use the logo as credit or endorsement. |
| Verified Poly Pizza CC0 models listed below | CC0 1.0 | No | Yes | Yes | CC0 permits it. Preserve the page/license snapshot because Poly Pizza's terms make the license displayed at download controlling. |
| Other Poly Pizza user models | Per-model Creative Commons license | Often yes | Depends on the exact model license | Depends on the exact model license | Do not assume a site-wide asset license. Preserve the exact license and attribution with every accepted model. |

[CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/) allows copying, modification, and distribution, including commercial use, without permission. It does not clear trademarks, patents, privacy/publicity rights, or imply creator endorsement. That is why these generic nature forms are safer than recognizable brands, people, or franchise-like objects.

## Poly Pizza assessment

[Poly Pizza](https://poly.pizza/explore) is a useful manual search catalogue: the site advertises OBJ, FBX, and glTF models usable in Godot. It has several good CC0 candidates, but is **not** the recommended foundation for the universal kit because the license is per model:

- [Poly Pizza's terms](https://poly.pizza/docs/tos) say user content remains owned by uploaders and the Creative Commons license applying at download controls use. The terms also prohibit scraping, so assets should not be harvested automatically for procedural generation.
- Poly Pizza's [generated credits page](https://poly.pizza/l/nB5Qfff9f5/credits) demonstrates that its catalogue currently mixes CC0 1.0 and CC BY 3.0. [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/) permits commercial sharing and adaptation but requires appropriate credit, a license link, and an indication of changes.
- License and author must therefore be checked per model. For example, [Tree Assets by Ben Desai](https://poly.pizza/m/eLqmfpqu_Ig) and [Trees by Poly by Google](https://poly.pizza/m/dTy_L-TMS2z) are labeled only “Creative Commons Attribution” on their model pages, so they create a credit obligation unlike CC0 packs. Their displayed pages do not identify the CC BY version; archive the downloaded license before approving either one.
- Use Poly Pizza only to fill a specific silhouette gap after searching the CC0 packs. Require a manifest entry containing model URL, creator, exact downloaded license/version, download date, format, local modifications, and the credit string. Reject entries whose exact license cannot be archived.

### Verified Poly Pizza CC0 shortlist

These pages currently state “Public Domain (CC0)” and provide FBX/glTF downloads:

| Role | Direct official page | Notes |
|---|---|---|
| Rocks | [Rocks by Quaternius](https://poly.pizza/m/e1rgb5i2kF) | Generic boulder/stone pool. |
| Trees | [Trees by Quaternius](https://poly.pizza/m/etFGNvsiFv) | Generic vegetation silhouettes. |
| Park vegetation | [Pretty Park set by Isa Lousberg](https://poly.pizza/bundle/Pretty-park-set-G2WINPAG9S) | 28 listed models; trees, bushes, hedges, grass, flowers, and ground slices; shared gradient atlas; page explicitly allows commercial use without attribution and also lists OBJ. |
| Crystals | [Crystal Pack by iPoly3D](https://poly.pizza/bundle/Crystal-Pack-AywAG7aywi) | 28 CC0 crystal variants. |
| Ice/crystal | [Crystal by iPoly3D](https://poly.pizza/m/Ftu5CcnxFZ) | Tagged both crystal and ice; recolor/translucency can create many recipes. |
| Ice | [Ice Block by Quaternius](https://poly.pizza/m/dEY0gPZNzG) | Simple reusable ice form. |
| Cloud | [Cloud by Quaternius](https://poly.pizza/m/F6DzCxDz6I) | Reusable near-cloud silhouette. |

## Runtime mapping for a billion planets

The asset count should stay small; recipes vary presentation, not geometry ownership.

| Reusable geometry pool | Recipe-controlled properties | Example outcomes |
|---|---|---|
| 12–20 rock meshes | scale/aspect, composition material, weathering/frost/dust, density, slope limit, clustering | angular airless ejecta, wind-worn desert rock, fresh basalt, ice-coated boulders |
| 8–12 trees + 12–20 shrubs/grass | morphology eligibility, pigment palette, leaf swap, wind, density, snow/dust mask | only recipes with supported biospheres; mineral branching uses a different material/spawn rule |
| 4–8 ore/gem meshes | mineral/ice identity, transmission, roughness, emission, size, rarity, sublimation/melt effects | water ice, salts, sulfur, metallic ore, supported alien minerals |
| 3–6 cloud meshes/cards | condensate/aerosol species, tint, opacity, vertical scale, altitude layers, wind, coverage | water/ice cloud, dust/aerosol layer, sulfuric haze, methane cloud where conditions permit |
| Generated terrain tile + liquid plane | temperature/pressure-stable phase, height/noise, shoreline, viscosity, reflectance, emission/flow | water, hydrocarbons, molten rock, or a dry/frozen basin—not arbitrary color swaps |

Water and lava should be recipe-driven Godot materials on generated local meshes, not dozens of downloaded props. That gives shorelines and animation while keeping one geometry path. Near clouds can reuse the Quaternius silhouettes; orbital cloud cover should remain a separate procedural shell/texture.

Prefer glTF/GLB in the ingestion pipeline. [Godot's stable 4.x documentation](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html) recommends glTF 2.0; OBJ is supported but loses features such as pivots, skeletons, animation, UV2, and PBR materials.

## Procurement rules

- Start with the free KayKit Forest, Kenney Nature, Quaternius Modular Platformer, and Quaternius Ultimate Space downloads. Add paid KayKit terrain/gems or the Quaternius source tier only after the art direction is proven.
- Keep the original archive, license file, source URL, creator, and acquisition date outside the runtime asset folder. Export normalized GLB scenes into the game.
- Build one project-owned palette/gradient atlas and remap approved CC0 meshes to it. Generate collisions and LODs in the ingestion step; use MultiMesh/instancing at runtime.
- Do not bundle raw source archives with the game, do not imply endorsement, and do not use scraping/API collection workflows on Poly Pizza.
- Before release, re-check every non-CC0 model and generate the credits page directly from the asset manifest.

## Decision

Adopt **KayKit Forest + Quaternius clouds/space accents + Kenney Nature** as the first universal surface kit. Keep all approved runtime meshes CC0. Treat Poly Pizza as a gap-filling catalogue only, with per-model legal review and attribution; do not make it a generator dependency.
