#!/usr/bin/env python3
"""Fetch 2k evidence maps for the Sol cook.

Run from repo root:
  python3 tools/fetch_planet_maps.py

Writes images into /tmp/planet-maps. Then:
  python3 tools/ingest_planet_maps.py

Does not touch the Godot tree. Review, then ingest.

NASA Photojournal originals are preferred (images-assets, public domain).
Wikimedia Commons is a fallback for Voyager/USGS sheets that NASA does not
host as a simple cylindrical JPEG.
"""
from __future__ import annotations

import json
import urllib.parse
import urllib.request
from pathlib import Path

OUT = Path("/tmp/planet-maps")
UA = "AstryxMapBot/1.0 (educational; local game asset fetch)"

# NASA images-assets id -> local filename. These are 2:1 cylindrical maps.
NASA = {
    "mimas_map.jpg": "PIA18437",
    "tethys_map.jpg": "PIA18439",
    "dione_map.jpg": "PIA18434",
    "rhea_map.jpg": "PIA18438",
    "iapetus_map.jpg": "PIA18436",
    "triton_map.jpg": "PIA18668",
    "pluto_map.jpg": "PIA19956",
    "charon_map.jpg": "PIA19866",
}

# Commons FilePath names. NASA/USGS mosaics preferred.
COMMONS = {
    "sun_2k.jpg": "Solarsystemscope_texture_2k_sun.jpg",
    "saturn_ring_2k.png": "Solarsystemscope_texture_2k_saturn_ring_alpha.png",
    "europa_cyl.jpg": "Europa Voyager GalileoSSI global mosaic.jpg",
    "enceladus_map.jpg": "Enceladus Color Map.jpg",
    "titan_map.jpg": "Titan map october 2006.jpg",
    "io_cyl.jpg": "Io from Galileo and Voyager missions.jpg",
    "callisto_voyager.jpg": "Callisto map NASA JPL Voyager.jpg",
    "phobos_viking.jpg": "Phobos Viking Mosaic DLRcontrol 7200.jpg",
    "miranda_usgs.jpg": "Miranda map JPL USGS.jpg",
    "ariel_usgs.jpg": "Ariel map JPL USGS.jpg",
    "umbriel_usgs.jpg": "Umbriel map JPL USGS.jpg",
    "titania_usgs.jpg": "Titania map JPL USGS.jpg",
    "oberon_usgs.jpg": "Oberon map JPL USGS.jpg",
    "ganymede_usgs.jpg": "Ganymede USGS map.jpg",
}


def _req(url: str, timeout: int = 90) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return r.read()


def _looks_image(data: bytes) -> bool:
    if len(data) < 15000:
        return False
    head = data[:16].lstrip().lower()
    if head.startswith(b"<!doctype") or head.startswith(b"<html"):
        return False
    return data[:3] == b"\xff\xd8" or data[:8] == b"\x89PNG\r\n\x1a\n" or data[:2] == b"\xff\xd8"


def fetch_nasa(pid: str, dest: Path) -> bool:
    orig = f"https://images-assets.nasa.gov/image/{pid}/{pid}~orig.jpg"
    large = f"https://images-assets.nasa.gov/image/{pid}/{pid}~large.jpg"
    for url in (orig, large):
        try:
            data = _req(url)
        except Exception as exc:
            print("FAIL", dest.name, pid, exc)
            continue
        if not _looks_image(data):
            print("BAD", dest.name, pid, len(data))
            continue
        dest.write_bytes(data)
        print("OK", dest.name, pid, len(data))
        return True
    return False


def fetch_commons(filename: str, dest: Path) -> bool:
    # API thumb first (Wikimedia asks for listed thumb sizes, not orig FilePath).
    params = {
        "action": "query",
        "titles": "File:" + filename,
        "prop": "imageinfo",
        "iiprop": "url|size|mime",
        "iiurlwidth": "2048",
        "format": "json",
    }
    api = "https://commons.wikimedia.org/w/api.php?" + urllib.parse.urlencode(params)
    try:
        info = json.loads(_req(api, timeout=40).decode())
    except Exception as exc:
        print("FAIL api", dest.name, exc)
        info = {}
    thumb = ""
    orig = ""
    for page in (info.get("query") or {}).get("pages", {}).values():
        for item in page.get("imageinfo") or []:
            thumb = item.get("thumburl") or ""
            orig = item.get("url") or ""
    for url in (thumb, orig):
        if not url:
            continue
        try:
            data = _req(url)
        except Exception as exc:
            print("FAIL", dest.name, exc)
            continue
        if not _looks_image(data):
            print("BAD", dest.name, len(data))
            continue
        dest.write_bytes(data)
        print("OK", dest.name, len(data))
        return True
    return False


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    ok = 0
    total = 0
    for dest_name, pid in NASA.items():
        total += 1
        dest = OUT / dest_name
        if dest.exists() and dest.stat().st_size > 20000:
            print("have", dest_name, dest.stat().st_size)
            ok += 1
            continue
        if fetch_nasa(pid, dest):
            ok += 1
    for dest_name, commons in COMMONS.items():
        total += 1
        dest = OUT / dest_name
        if dest.exists() and dest.stat().st_size > 15000:
            print("have", dest_name, dest.stat().st_size)
            ok += 1
            continue
        if fetch_commons(commons, dest):
            ok += 1
    print("fetched", ok, "/", total)
    print("next: python3 tools/ingest_planet_maps.py")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
