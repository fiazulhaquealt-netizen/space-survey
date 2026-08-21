#!/usr/bin/env python3
"""Crop/resize fetched maps to 2048x1024 and drop them in assets/planets/.

Expects files in /tmp/planet-maps from fetch_planet_maps.py.
Writes Godot .import stubs so headless load() can find them.
"""
from __future__ import annotations

import hashlib
from pathlib import Path

from PIL import Image

SRC = Path("/tmp/planet-maps")
DST = Path(__file__).resolve().parents[1] / "assets" / "planets"

# source in /tmp/planet-maps -> assets/planets name
JOBS = {
    "europa_cyl.jpg": "europa_2k.jpg",
    "enceladus_map.jpg": "enceladus_2k.jpg",
    "titan_map.jpg": "titan_2k.jpg",
    "io_cyl.jpg": "io_2k.jpg",
    "sun_2k.jpg": "sun_2k.jpg",
    "saturn_ring_2k.png": "saturn_ring_2k.png",
    "mimas_map.jpg": "mimas_2k.jpg",
    "tethys_map.jpg": "tethys_2k.jpg",
    "dione_map.jpg": "dione_2k.jpg",
    "rhea_map.jpg": "rhea_2k.jpg",
    "iapetus_map.jpg": "iapetus_2k.jpg",
    "triton_map.jpg": "triton_2k.jpg",
    "pluto_map.jpg": "pluto_2k.jpg",
    "charon_map.jpg": "charon_2k.jpg",
    "phobos_viking.jpg": "phobos_2k.jpg",
    "callisto_voyager.jpg": "callisto_2k.jpg",
    "miranda_usgs.jpg": "miranda_2k.jpg",
    "ariel_usgs.jpg": "ariel_2k.jpg",
    "umbriel_usgs.jpg": "umbriel_2k.jpg",
    "titania_usgs.jpg": "titania_2k.jpg",
    "oberon_usgs.jpg": "oberon_2k.jpg",
    "ganymede_eq.jpg": "ganymede_2k.jpg",
}

# Prefer these over JOBS keys when present (color / cropped).
ALIASES = {
    "mimas_2k.jpg": ["mimas_color.jpg", "mimas_map.jpg"],
    "pluto_2k.jpg": ["pluto_color.jpg", "pluto_map.jpg"],
    "ganymede_2k.jpg": ["ganymede_eq.jpg", "ganymede_bjonsson.jpg"],
}


def to_equirect(im: Image.Image) -> Image.Image:
    w, h = im.size
    ar = w / h
    if abs(ar - 2.0) > 0.08:
        tw = int(h * 2)
        if tw <= w:
            x = (w - tw) // 2
            im = im.crop((x, 0, x + tw, h))
        else:
            th = w // 2
            y = max((h - th) // 2, 0)
            im = im.crop((0, y, w, min(y + th, h)))
    return im.resize((2048, 1024), Image.Resampling.LANCZOS)


def crop_usgs_sheet(im: Image.Image) -> Image.Image:
    """Pull the cylindrical panel off a USGS I-map sheet (globes on top, map below)."""
    w, h = im.size
    y0 = int(h * 0.48)
    pix = im.load()
    rows = []
    for y in range(y0, h):
        n = 0
        step = max(w // 200, 1)
        for x in range(0, w, step):
            r, g, b = pix[x, y][:3]
            if r < 245 or g < 245 or b < 245:
                n += 1
        rows.append((y, n / (w / step)))
    on = [y for y, f in rows if f > 0.55]
    if len(on) < 20:
        return im
    y1, y2 = on[0], on[-1] + 1
    cols = []
    step_y = max((y2 - y1) // 120, 1)
    for x in range(w):
        n = 0
        for y in range(y1, y2, step_y):
            r, g, b = pix[x, y][:3]
            if r < 245 or g < 245 or b < 245:
                n += 1
        cols.append((x, n / max((y2 - y1) / step_y, 1)))
    con = [x for x, f in cols if f > 0.35]
    if len(con) < 20:
        return im.crop((0, y1, w, y2))
    return im.crop((con[0], y1, con[-1] + 1, y2))


def write_import(name: str) -> None:
    template = (DST / "mars_2k.jpg.import").read_text()
    rel = f"res://assets/planets/{name}"
    h = hashlib.md5(rel.encode()).hexdigest()
    uid = "uid://" + hashlib.sha1(rel.encode()).hexdigest()[:13]
    imp = template.replace("mars_2k.jpg", name).replace("uid://bkcxlofl3sg2e", uid)
    imp = imp.replace("7a2d695a775d11f168cf6ae656cf47da", h)
    (DST / (name + ".import")).write_text(imp)


def find_src(dst_name: str, src_name: str) -> Path | None:
    for alias in ALIASES.get(dst_name, []):
        p = SRC / alias
        if p.exists():
            return p
    p = SRC / src_name
    if p.exists():
        return p
    return None


def main() -> None:
    Image.MAX_IMAGE_PIXELS = None
    DST.mkdir(parents=True, exist_ok=True)
    # Build ganymede equirect from the USGS sheet if needed.
    sheet = SRC / "ganymede_usgs.jpg"
    eq = SRC / "ganymede_eq.jpg"
    if sheet.exists() and not eq.exists():
        im = Image.open(sheet).convert("RGB")
        crop = crop_usgs_sheet(im)
        to_equirect(crop).save(eq, "JPEG", quality=88, optimize=True)
        print("crop ganymede sheet", eq.stat().st_size)
    for src_name, dst_name in JOBS.items():
        src = find_src(dst_name, src_name)
        if src is None:
            print("skip missing", src_name)
            continue
        dest = DST / dst_name
        keep = {
            "europa_2k.jpg", "enceladus_2k.jpg", "titan_2k.jpg",
            "io_2k.jpg", "sun_2k.jpg", "saturn_ring_2k.png",
        }
        if dest.exists() and dst_name in keep:
            print("keep", dst_name)
            continue
        if src.suffix.lower() == ".png" and dst_name.endswith(".png"):
            dest.write_bytes(src.read_bytes())
            print("copy", dst_name, dest.stat().st_size)
        else:
            im = Image.open(src).convert("RGB")
            out = to_equirect(im)
            out.save(dest, "JPEG", quality=88, optimize=True)
            print("write", dst_name, out.size, dest.stat().st_size)
        write_import(dst_name)
    print("done")


if __name__ == "__main__":
    main()
