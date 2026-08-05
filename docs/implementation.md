# Runebound MVP — Implementation Plan

Tracks build progress toward [design.md](design.md).  
Invoke coding with **`/implement-slice`** (one slice at a time).

**Weapons (locked):** staff (effect projectiles) · axe (cleave) · dagger (burst). No bow.

---

## Status

| Slice | Name | Status |
|-------|------|--------|
| 0 | Prep / scene strategy | Done |
| 1 | Map & Hearth | Done |
| 2 | Day / Night + horn | Done |
| 3 | Gather + place/repair wall | Done |
| 4 | Night wave (one door) + nearest-target AI | Done |
| 5 | Hero controls + staff, then axe/dagger + swap | Done |
| 5b | Combat VFX + build menu / Weapon Stand | Done |
| 6 | Hero death rules | Done |
| 7 | Achievements stub + end screen | Done |
| 8 | Ballista / trap / scrap | Done |

---

## Slice 0 — Prep / scene strategy

**Goal:** Decide how the new loop lives next to the old survivors arena without a big-bang rewrite.

**Build**

- [x] Choose approach (recommended: **new main scene** e.g. `scenes/main/base_defense.tscn`, keep old `main.tscn` runnable until feature-parity feels OK).
- [x] Point `project.godot` `run/main_scene` at the new scene only when Slice 1 is walkable.
- [x] Add input actions: `attack` (mouse), `interact` (E), `dash` (Space) — keep existing walk actions.
- [x] Pick one biome tileset for MVP (recommend **forest** or **taiga**) and stick to it.

**Done means:** Empty (or stub) scene runs; inputs exist; old game still openable if kept.

**Reuse:** `Groups`, `Layers`, camera script patterns, `GameEvents` (extend signals rather than replace).

**Notes (playtest / follow-ups):**
- Approach locked: `scenes/main/base_defense.tscn` is the new loop; `main.tscn` stays openable via F6.
- Biome locked: **forest** (`resources/tileset.tres` + `assets/sprites/scenario/forest_/`). Taiga assets stay unused for MVP.
- Slice 1 switched `run/main_scene` to `base_defense.tscn`.

---

## Slice 1 — Map & Hearth

**Goal:** Sketch becomes a playable space.

**Build**

- [x] Fixed square TileMap: ground + **indestructible** L-corner frames + four door gaps (N/E/S/W).
- [x] **Hearth** at center with `HealthComponent` (placeholder art OK: fountain / marker).
- [x] Player spawns inside the ring; camera follows hero.
- [x] Collision: starter frames block movement; doors walkable.

**Done means:** Walk the interior and out the four doors; Hearth exists as a damageable node (even if nothing hits it yet).

**Playtest:** Does 640×360 + zoom 1.0 feel too tight/loose? Tune map size here.

**Notes (playtest / follow-ups):**
- F5 now runs `base_defense.tscn`. Old arena: open `scenes/main/main.tscn` and F6.
- Map built at runtime from exports on `BaseDefense` (`map_size_tiles=48`, `courtyard_radius_tiles=8`, `door_width_tiles=3`). Frames are `StaticBody2D` + brown `Polygon2D` placeholders (Terrain layer); fence tiles later.
- Hearth: fountain atlas crop + `HealthComponent` max 100. No hurtbox yet (nothing hits it until Slice 4).
- Survivors sword controller is stripped on spawn in this scene so walking isn’t auto-attack spam.
- Tune feel via the three map exports if the courtyard feels tight/loose at zoom 1.0.

---

## Slice 2 — Day / Night + horn

**Goal:** Phase state machine without combat depth.

**Build**

- [x] States: `DAY` → (horn) → `NIGHT` → (wave clear stub) → `DAWN` → `DAY`.
- [x] Skip Dusk UI.
- [x] Horn via **E** on Hearth (or dedicated interactable); callable anytime.
- [x] On run start: pick **one random active door** for the whole run; store on a run/phase manager.
- [x] Simple phase label in HUD (text OK).

**Done means:** Sound horn → Night flag flips → stub “clear wave” (timer or empty) → Dawn → Day. Active door debug-visible (color marker).

**Reuse:** Pattern from `RunManager` / new `PhaseManager` — prefer one clear owner for phase + run end.

**Notes (playtest / follow-ups):**
- Owner: `PhaseManager` under `base_defense` (not the survivors `RunManager`).
- Horn: stand near Hearth, press **E** during DAY only (unprepared Night 0 OK). Night/Dawn ignores horn.
- Night clear is a stub timer (`night_stub_seconds=3`, then `dawn_stub_seconds=1.5`) until Slice 4 wires enemy count.
- Active door: magenta `DOOR X` marker at the gap; side stored for the whole run.
- `GameEvents.phase_changed` emitted for listeners.

---

## Slice 3 — Gather + place/repair wall

**Goal:** Scarce wood/stone and one destructible wall type.

**Build**

- [x] Resource nodes outside walls; instant gather on **E**; Dawn refill (data-driven amounts).
- [x] Inventory: wood, stone (HUD counts).
- [x] Place wooden wall on grid **inside** buildable zone (Day only).
- [x] Repair on **E** on damaged player wall / Hearth (Day + Night); costs resources.
- [x] Night: **no new placement**.

**Done means:** Gather → place a wall → damage it somehow (debug key OK) → repair. Cannot place at Night.

**Notes (playtest / follow-ups):**
- Costs/caps: `resources/economy/build_economy.tres` (wood place=2, wall repair wood=1, hearth repair stone=1).
- Controls: **E** gather / repair / horn (priority order); **LMB** place wall in Day (green/red ghost); **F** debug-damage nearest wall (or Hearth).
- 6 outside nodes (wood/stone placeholders). Dawn refills via `PhaseManager` → `BuildManager`.
- Slice 5 will reclaim LMB for attack — place UX may move to ghost+E then.

---

## Slice 4 — Night wave + nearest-target AI

**Goal:** Enemies come through the active door and hit closest valid targets.

**Build**

- [x] Night spawner at active door; wave composition table (start slime-only; escalate later).
- [x] Enemy AI: move toward / attack **nearest** hero or **destructible** structure (not indestructible frames).
- [x] Hearth take damage → run over when HP hits 0 (wire end screen stub).
- [x] Wave clear when enemy count hits 0 → Dawn.

**Done means:** Horn → pack enters one door → can kill or watch them chew a placed wall / Hearth. Day packs optional (low count) or deferred to end of this slice.

**Reuse:** `BaseEnemy`, `EnemyManager` ideas, `WeightedTable`, hitbox/hurtbox pipeline. Retarget `accelerate_to_player` → nearest-target helper.

**Notes (playtest / follow-ups):**
- `NightWaveManager` + `resources/waves/wave_table.tres` (4 slimes +2/night). Spawns outside active door.
- `PhaseManager.auto_clear_night=false` — Night ends only when wave enemies die.
- AI: `Targeting.get_nearest_attack_target` (player / player_wall / hearth). Frames ignored.
- Hearth + player walls have PLAYER-team hurtboxes so enemy hitboxes chew them.
- No hero weapons yet — **K** debug-kills the wave. Watch-chew or K to clear.
- Hearth HP 0 → pause + end screen (restart → `base_defense.tscn`).
- Day packs deferred.

---

## Slice 5 — Combat: staff → full weapon set

**Goal:** Aimed ARPG attacks; staff first because art exists.

**Build**

- [x] Click aim + attack; **Space** dash (cooldown + brief i-frames).
- [x] **Staff:** projectile using an effect/bullet sheet (e.g. purple); no arrows.
- [x] **Axe:** melee cleave arc.
- [x] **Dagger:** high single-target melee burst (placeholder sprite OK).
- [x] Hearth interact: swap among three weapons (one equipped).

**Done means:** Clear a Night with staff; swap to axe/dagger at Hearth and feel the role difference.

**Reuse:** Hitbox damage flow; do **not** resurrect the deleted `scripts/weapons` tree as a parallel architecture — thin weapon controllers under player/abilities is enough.

**Notes (playtest / follow-ups):**
- `PlayerCombat` under player: LMB aims/attacks, Space dashes (i-frames via hurtbox).
- Staff = purple bolt; Axe = wide slash; Dagger = high-damage short stab (sword stub art).
- Hearth: **tap E** = cycle weapon; **hold E** (~0.4s) in Day = horn. Repair still wins if damaged.
- Wall place moved to **E** when ghost is valid (LMB freed for attack).
- Debug **K** still clears waves if needed.

---

## Slice 5b — Combat VFX + build menu / Weapon Stand

**Goal:** Attacks are readable and deal damage; building is a deliberate menu; weapon swap is not on the Hearth (so Night isn’t started by accident).

**Build**

- [x] Visible equipped weapon on the hero + readable attack VFX (staff bolt / axe arc / dagger stab).
- [x] Confirm hitboxes deal damage to enemies (fix atlas / layers / parenting as needed).
- [x] **Build panel** (toggle **B**): list of placeable buildings with cost; select one, then place in Day (ghost + **E**).
- [x] Starter catalog: **Wooden Wall**, **Weapon Stand** (more later in Slice 8).
- [x] **Weapon Stand:** placeable; **E** cycles Staff/Axe/Dagger. No stand → no swap.
- [x] **Hearth:** repair when damaged; **tap E** sounds horn in Day only. No weapon swap / no hold-E.

**Done means:** See and feel each weapon; place a Weapon Stand from the build list; swap there; horn only from Hearth without swapping.

**Notes:** Accidental Night from Hearth hold/tap-swap is a known Slice 5 footgun — this slice removes it.
- Player hitboxes actively scan enemy hurtboxes (short-lived VFX were missing overlaps before).
- Build catalog: `resources/buildings/*.tres`.

---

## Slice 6 — Hero death rules

**Goal:** Design death table in code.

**Build**

- [x] Night down: hero disabled; camera on Hearth; raid continues; respawn on wave clear.
- [x] Day death: teleport/cutscene stub → force Night immediately; skip remaining Day actions.
- [x] Hero death never ends run by itself.

**Done means:** Die in Day → Night starts unprepared. Die in Night → base can still win/lose without you.

**Notes (playtest / follow-ups):**
- `HeroDeathManager` owns the flow. Hearth HP 0 still ends the run.
- Night down: hero hidden/disabled; camera on Hearth; `wave_cleared` respawns at Hearth. Sets `cleared_while_hero_down` for Slice 7.
- Day death: short stub text → snap to Hearth → revive → `sound_horn()` (unprepared Night). Increments `day_deaths`.
- `HealthComponent.revive()` / `is_dead` so died only fires once until revived.

---

## Slice 7 — Achievements stub

**Build**

- [x] Persist flags: night 1 / 3 / 5 survived; day-death; clear while hero down.
- [x] End screen lists nights survived + newly unlocked achievements.
- [x] Scrap drop stub optional here or with Slice 8.

**Done means:** Two runs can show a newly unlocked achievement.

**Notes:**
- Autoload `AchievementStore` → `user://runebound_achievements.cfg`.
- Unlocks on wave clear / day death; end screen shows nights + **new** unlocks for that run.
- Scrap deferred to Slice 8.

---

## Slice 8 — Ballista / trap / scrap

**Build**

- [x] Weak ballista (chip only — tune so it does not solo Swarmers).
- [x] Floor trap (chip + slow).
- [x] Enemies drop **scrap** (no recipes yet).
- [x] Banner/shrine optional — skip if timeboxed.

**Done means:** Place ballista + trap; scrap appears in inventory; night still needs the hero.

**Notes (playtest / follow-ups):**
- Ballista: 1 dmg / 1.4s, range 120 — slime HP 10 so it chips only; in `BUILDING` group (enemies can chew it).
- Floor trap: Area2D chip + `VelocityComponent.apply_slow`; not a soak target.
- Scrap: +1 to inventory on enemy death; HUD shows Scrap (no spend recipes yet).
- Build catalog: Wall / Stand / Ballista (4W 2S) / Trap (1W 1S). Banner/shrine skipped.

---

## Suggested cadence

1. Finish **0 → 1 → 2** before worrying about weapons.  
2. **3 → 4** unlocks the core fantasy (gather / build / hold a door).  
3. **5 → 6** make it an ARPG.  
4. **7 → 8** meta stub + support buildings.

After each slice: play 5 minutes in Godot, then `/implement-slice` for the next.

---

## Out of scope until called out

Food, multi-door nights, craft recipes, equipment, weapon upgrades, Dusk intel UI, audio pack, dedicated dagger art, second biome.
