# Planet generator — painted-ball first pass

One cook. Each world has its own recipe. This slice paints a ball. You still do not land.

## Contract

- **Planet generator** is the cook. Same code for every world.
- **Recipe** is per-body data. Real map path when we have one. Kind / colors / heat when we do not.
- Sol recipes carry a map. Other systems get an invented recipe from type, mass, and color.
- Map path is the swap slot. Today: ready 2k maps. Later: USGS / NASA / ESA mosaics in the same field.
- No landing. No close terrain. No 3D volcanoes. Features stay an empty list on the recipe.

## This slice

- Sol planets + Moon: painted sphere from a 2k albedo map.
- Sun / stars / craft: keep the existing model path.
- Unmapped worlds (Proxima b, TRAPPIST, K2-18, arcade moons): thin cook shader from the invented recipe.
- Physical far discs can wear the same albedo so a distant Mars is still Mars.
- Ground clamp and Newton stay as they are.

## Not this slice

Close ground, hills, placed volcanoes, USGS mosaics, other moons as physical bodies, landing, RCS.

## Check

Earth from GEO shows continents. Mars is red with real markings. An unmapped world is not a flat color ball. Newton tests still pass.
