# Planet generator — space paint + close-up paint

Same cook. Thicker recipe. Still a ball. You still do not land.

## Contract

- **One shader** paints every world. Real maps stay. Invented worlds no longer share one smear.
- Recipe grows: land amount, land/ocean colors, clouds, night, city amount. Features stay an empty list.
- Earth (and any world with a map) keeps its albedo. Clouds and night layer on when we have those maps; noise fills the gap.
- Day and night come from the real sun direction. Water shines. Land must read as land.
- Close-up: when you get near, the same shader adds hill/ground detail as paint and bump. No mesh displacement. No landing.

## This slice

1. **Space paint**
   - Invented rocky/ice: thresholded continents, deep ocean (not toy blue), ice caps, clouds.
   - Mapped worlds: albedo + optional cloud/night maps + contrast so continents pop.
   - Night cities on Earth from a night map. Other worlds stay dark at night.
   - Sun direction and a small specular glint on water.
2. **Close-up paint**
   - `detail` from altitude (full near the skin, off at GEO).
   - Extra noise + fake bump. Sphere stays a sphere. Ground clamp unchanged.

## Not this slice

3D hills, placed volcanoes, USGS mosaics, landing, a separate atmosphere mesh.

## Check

- Earth from GEO: continents obvious, ocean darker, clouds, night lights on the dark half.
- An invented world (Proxima b, K2-18b) is not a flat color ball. Land and ocean split.
- Approaching Earth, ground detail grows. You still bounce on the skin.
- Newton tests still pass.
