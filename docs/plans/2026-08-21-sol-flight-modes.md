# Flight modes Implementation Plan

> Implementation plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Name LOCAL / CRUISE / AIR, drop cruise at Earth's 100 km air line, and show Mode on the tape.

**Architecture:** A tiny pure `FlightMode` module decides the word from zone + time_rate. Ship already kills time warp in air; it reports mode and fires a one-shot drop. HUD prints Mode and a short DROP flash. No new FTL. No volumetric air.

**Tech Stack:** Godot 4.6.2 GDScript. Headless tests: `godot --headless --path . --script res://tools/test_*.gd`.

## Global Constraints

- 1 scene unit = 1 km. Sol only for this slice.
- Earth air top = 100 km. Kill = 29 km. No landing.
- Cruise = existing Sol time warp (`time_rate > 1`) in SPACE, not arcade FTL.
- Drop cue is a HUD flash + DROP tag (~0.4 s), not a fullscreen white blink.
- Other star systems unchanged. Newton tests must still pass.
- Spec: `docs/specs/2026-08-21-sol-flight-modes-design.md`
- Speak the words LOCAL, CRUISE, AIR, DROP, SPACE. Do not invent new mode names.

## File map

- Create: `scripts/flight/flight_mode.gd` — pure of / can_cruise / must_drop
- Create: `tools/test_flight_mode.gd` — headless contract
- Modify: `scripts/flight/ship.gd` — `flight_mode`, `drop_flash` one-shot
- Modify: `scripts/ui/hud.gd` — Mode line, DROP tag, flash
- Modify: `CONTEXT.md` — Flight mode term
- Do not touch planet cook, sun LOD, or warp spool in other systems.

---

### Task 1: FlightMode words

**Files:**
- Create: `scripts/flight/flight_mode.gd`
- Create: `tools/test_flight_mode.gd`

**Interfaces:**
- Consumes: `Ephemeris.flight_zone` words already in use (`SPACE`, `AIR`, `SKIN`, `INSIDE`, `CENTER`)
- Produces:
  - `FlightMode.CRUISE`, `LOCAL`, `AIR` as String consts
  - `FlightMode.of(zone: String, time_rate: float) -> String`
  - `FlightMode.can_cruise(zone: String) -> bool`
  - `FlightMode.must_drop(zone: String, time_rate: float) -> bool`

- [ ] **Step 1: Write the failing test**

```gdscript
extends SceneTree
# Run: godot --headless --path . --script res://tools/test_flight_mode.gd

const M := preload("res://scripts/flight/flight_mode.gd")
const E := preload("res://scripts/autoload/ephemeris.gd")


func _initialize() -> void:
	var failed := 0
	failed += _check("geo_local", M.of("SPACE", 1.0) == M.LOCAL)
	failed += _check("geo_cruise", M.of("SPACE", 50.0) == M.CRUISE)
	failed += _check("air_kills_cruise", M.of("AIR", 50.0) == M.AIR)
	failed += _check("air_local_is_air", M.of("AIR", 1.0) == M.AIR)
	failed += _check("can_cruise_space", M.can_cruise("SPACE"))
	failed += _check("no_cruise_air", not M.can_cruise("AIR"))
	failed += _check("no_cruise_skin", not M.can_cruise("SKIN"))
	failed += _check("drop_from_cruise", M.must_drop("AIR", 50.0))
	failed += _check("no_drop_from_local", not M.must_drop("AIR", 1.0))
	failed += _check("no_drop_in_space", not M.must_drop("SPACE", 50.0))
	var eph := E.new()
	var geo := E.GEO_RADIUS_KM
	failed += _check("geo_zone_space", eph.flight_zone("Earth", geo) == "SPACE")
	failed += _check("fifty_km_air", eph.flight_zone("Earth", E.EARTH_RADIUS_KM + 50.0) == "AIR")
	eph.free()
	if failed == 0:
		print("flight_mode: OK")
		quit(0)
	else:
		print("flight_mode: FAIL %d" % failed)
		quit(1)


func _check(name: String, ok: bool) -> int:
	if not ok:
		print("flight_mode: FAIL %s" % name)
		return 1
	return 0
```

- [ ] **Step 2: Run test to verify it fails**

Run: `godot --headless --path . --script res://tools/test_flight_mode.gd`

Expected: parse error, `flight_mode.gd` missing.

- [ ] **Step 3: Write minimal implementation**

```gdscript
class_name FlightMode
extends RefCounted

const CRUISE := "CRUISE"
const LOCAL := "LOCAL"
const AIR := "AIR"


static func of(zone: String, time_rate: float) -> String:
	if zone == "AIR":
		return AIR
	if zone == "SPACE":
		return CRUISE if time_rate > 1.001 else LOCAL
	return zone


static func can_cruise(zone: String) -> bool:
	return zone == "SPACE"


static func must_drop(zone: String, time_rate: float) -> bool:
	return time_rate > 1.001 and not can_cruise(zone)
```

- [ ] **Step 4: Run test to verify it passes**

Run: `godot --headless --path . --script res://tools/test_flight_mode.gd`

Expected: `flight_mode: OK`

- [ ] **Step 5: Commit**

```bash
git add scripts/flight/flight_mode.gd scripts/flight/flight_mode.gd.uid tools/test_flight_mode.gd
git commit -m "feat: name LOCAL CRUISE AIR from zone and time warp"
```

---

### Task 2: Ship drop one-shot

**Files:**
- Modify: `scripts/flight/ship.gd` (near `_clamp_time_warp`, ~551)
- Test: `tools/test_flight_mode.gd` (extend with ship-free drop edge cases already in Task 1)

**Interfaces:**
- Consumes: `FlightMode.of`, `FlightMode.must_drop`, `Ephemeris.flight_zone`, existing `_clamp_time_warp`
- Produces:
  - `var flight_mode: String` on Ship (`LOCAL` at spawn)
  - `var drop_flash: float` seconds remaining (0 = idle)
  - `func refresh_flight_mode(zone: String) -> void` called each Newton step / from main
  - DROP_FLASH_SECS := 0.4

- [ ] **Step 1: Write the failing checks (extend test file)**

Add to `tools/test_flight_mode.gd` after the existing checks:

```gdscript
	failed += _check("skin_not_cruise", M.of("SKIN", 50.0) == "SKIN")
	failed += _check("drop_inside", M.must_drop("INSIDE", 10.0))
```

- [ ] **Step 2: Run — those two should already pass from Task 1. If not, fix FlightMode first.**

- [ ] **Step 3: Wire ship**

In `scripts/flight/ship.gd`:

```gdscript
const DROP_FLASH_SECS := 0.4
var flight_mode := "LOCAL"
var drop_flash := 0.0
```

After `_clamp_time_warp` zeros time_rate, call:

```gdscript
func refresh_flight_mode(zone: String) -> void:
	var was_cruise := time_rate > 1.001 or flight_mode == FlightMode.CRUISE
	if FlightMode.must_drop(zone, time_rate) or (was_cruise and zone == "AIR"):
		if flight_mode != FlightMode.AIR:
			drop_flash = DROP_FLASH_SECS
		time_rate = 1.0
		_time_idx = 0
	flight_mode = FlightMode.of(zone, time_rate)


func tick_drop_flash(delta: float) -> void:
	if drop_flash > 0.0:
		drop_flash = maxf(drop_flash - delta, 0.0)
```

Call `refresh_flight_mode` from `_newton_advance` using Earth zone when `newton` (nearest is Earth at spawn; main should pass nearest zone once HUD already knows it). Smallest wire: in `ship.gd` `_newton_advance` after `_clamp_time_warp` equivalent (inside the air check that already sets time_rate = 1):

```gdscript
		var zone := Ephemeris.flight_zone("Earth", true_pos.length())
		refresh_flight_mode(zone)
```

Call `tick_drop_flash(delta)` from `fly()`.

Keep `_clamp_time_warp` as the thing that zeros warp in air. `refresh_flight_mode` only names it and sets `drop_flash` on the falling edge.

- [ ] **Step 4: Run**

`godot --headless --path . --script res://tools/test_flight_mode.gd`
`godot --headless --path . --script res://tools/test_newton.gd`

Expected: both OK. Parse-check ship.gd by loading the project: `godot --headless --path . --quit` must not print Parser Error.

- [ ] **Step 5: Commit**

```bash
git add scripts/flight/ship.gd tools/test_flight_mode.gd
git commit -m "feat: drop cruise once at Earth air line"
```

---

### Task 3: Tape shows Mode and DROP

**Files:**
- Modify: `scripts/ui/hud.gd` (~1364–1401, speed + tape block)

**Interfaces:**
- Consumes: `ship.flight_mode`, `ship.drop_flash`, existing `zone`
- Produces: tape line `Mode    LOCAL|CRUISE|AIR` and speed tag `· DROP` while `drop_flash > 0`

- [ ] **Step 1: No new headless HUD test (HUD needs a tree). Keep FlightMode tests green. After the edit, grep-proof the strings exist.**

Add to `tools/test_flight_mode.gd`:

```gdscript
	var hud_src := FileAccess.get_file_as_string("res://scripts/ui/hud.gd")
	failed += _check("hud_mode_line", hud_src.find("Mode") >= 0)
	failed += _check("hud_drop_tag", hud_src.find("DROP") >= 0)
```

Run first: expect FAIL `hud_mode_line`.

- [ ] **Step 2: Confirm FAIL**

Run: `godot --headless --path . --script res://tools/test_flight_mode.gd`

Expected: `flight_mode: FAIL hud_mode_line`

- [ ] **Step 3: HUD**

In the Sol tape block, after Zone:

```gdscript
		var mode := str(ship.flight_mode)
		if ship.drop_flash > 0.0:
			tag += "  · DROP"
			mode = "DROP"
		else:
			tag += "  · %s" % mode
		extra += "\nMode    %s" % mode
```

Keep the existing `· AIR` / zone tag from `zone`. Mode is extra. Do not remove Zone.

Optional flash: if `drop_flash > 0`, modulate `_speed_label` alpha or self_modulate to Color(1.4, 1.4, 1.4) and restore after. Keep it under 0.4 s. No fullscreen ColorRect.

- [ ] **Step 4: Run tests**

`godot --headless --path . --script res://tools/test_flight_mode.gd`
`godot --headless --path . --script res://tools/test_newton.gd`

Expected: OK.

- [ ] **Step 5: Commit**

```bash
git add scripts/ui/hud.gd tools/test_flight_mode.gd
git commit -m "feat: tape Mode line and DROP cue"
```

---

### Task 4: Language

**Files:**
- Modify: `CONTEXT.md` Language section

**Interfaces:**
- Consumes: spec terms
- Produces: **Flight mode** paragraph

- [ ] **Step 1: Add this block under Flight zone**

```markdown
**Flight mode**:
LOCAL / CRUISE / AIR. Zone is where. Mode is how. Cruise is Sol time warp in SPACE. Air kills cruise. Crossing into air from cruise is DROP (short tape cue, not a white blink).
_Avoid_: Elite white flash as the trick, arcade FTL in Sol, cruise in air
```

- [ ] **Step 2: No test. Read the file. Confirm one paragraph, no leftover Elite copy-paste.**

- [ ] **Step 3: Commit**

```bash
git add CONTEXT.md docs/specs/2026-08-21-sol-flight-modes-design.md docs/plans/2026-08-21-sol-flight-modes.md
git commit -m "docs: flight modes LOCAL CRUISE AIR drop at 100 km"
```

---

## Play check (after Task 3)

- GEO, no period: tape Mode LOCAL, Zone SPACE.
- Period warp: Mode CRUISE, speed tag ×N.
- Fall into 100 km (F9 if needed): Mode DROP then AIR, time ×1, drag.
- Climb out: Mode LOCAL. Period warp works again.

Not this plan: sun vanish, horizon-not-marble, Titan air, new FTL.
