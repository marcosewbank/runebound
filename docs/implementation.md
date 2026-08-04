# Runebound MVP — Implementation Plan

Tracks build progress toward [design.md](design.md).  
Invoke coding with **`/implement-slice`** (one slice at a time).

**Weapons (locked):** staff (effect projectiles) · axe (cleave) · dagger (burst). No bow.

---

## Status

| Slice | Name | Status |
|-------|------|--------|
| 0 | Prep / scene strategy | Not started |
| 1 | Map & Hearth | Not started |
| 2 | Day / Night + horn | Not started |
| 3 | Gather + place/repair wall | Not started |
| 4 | Night wave (one door) + nearest-target AI | Not started |
| 5 | Hero controls + staff, then axe/dagger + swap | Not started |
| 6 | Hero death rules | Not started |
| 7 | Achievements stub + end screen | Not started |
| 8 | Ballista / trap / scrap | Not started |

---

## Slice 0 — Prep / scene strategy

**Goal:** Decide how the new loop lives next to the old survivors arena without a big-bang rewrite.

**Build**

- [ ] Choose approach (recommended: **new main scene** e.g. `scenes/main/base_defense.tscn`, keep old `main.tscn` runnable until feature-parity feels OK).
- [ ] Point `project.godot` `run/main_scene` at the new scene only when Slice 1 is walkable.
- [ ] Add input actions: `attack` (mouse), `interact` (E), `dash` (Space) — keep existing walk actions.
- [ ] Pick one biome tileset for MVP (recommend **forest** or **taiga**) and stick to it.

**Done means:** Empty (or stub) scene runs; inputs exist; old game still openable if kept.

**Reuse:** `Groups`, `Layers`, camera script patterns, `GameEvents` (extend signals rather than replace).

---

## Slice 1 — Map & Hearth

**Goal:** Sketch becomes a playable space.

**Build**

- [ ] Fixed square TileMap: ground + **indestructible** L-corner frames + four door gaps (N/E/S/W).
- [ ] **Hearth** at center with `HealthComponent` (placeholder art OK: fountain / marker).
- [ ] Player spawns inside the ring; camera follows hero.
- [ ] Collision: starter frames block movement; doors walkable.

**Done means:** Walk the interior and out the four doors; Hearth exists as a damageable node (even if nothing hits it yet).

**Playtest:** Does 640×360 + zoom 1.0 feel too tight/loose? Tune map size here.

---

## Slice 2 — Day / Night + horn

**Goal:** Phase state machine without combat depth.

**Build**

- [ ] States: `DAY` → (horn) → `NIGHT` → (wave clear stub) → `DAWN` → `DAY`.
- [ ] Skip Dusk UI.
- [ ] Horn via **E** on Hearth (or dedicated interactable); callable anytime.
- [ ] On run start: pick **one random active door** for the whole run; store on a run/phase manager.
- [ ] Simple phase label in HUD (text OK).

**Done means:** Sound horn → Night flag flips → stub “clear wave” (timer or empty) → Dawn → Day. Active door debug-visible (color marker).

**Reuse:** Pattern from `RunManager` / new `PhaseManager` — prefer one clear owner for phase + run end.

---

## Slice 3 — Gather + place/repair wall

**Goal:** Scarce wood/stone and one destructible wall type.

**Build**

- [ ] Resource nodes outside walls; instant gather on **E**; Dawn refill (data-driven amounts).
- [ ] Inventory: wood, stone (HUD counts).
- [ ] Place wooden wall on grid **inside** buildable zone (Day only).
- [ ] Repair on **E** on damaged player wall / Hearth (Day + Night); costs resources.
- [ ] Night: **no new placement**.

**Done means:** Gather → place a wall → damage it somehow (debug key OK) → repair. Cannot place at Night.

---

## Slice 4 — Night wave + nearest-target AI

**Goal:** Enemies come through the active door and hit closest valid targets.

**Build**

- [ ] Night spawner at active door; wave composition table (start slime-only; escalate later).
- [ ] Enemy AI: move toward / attack **nearest** hero or **destructible** structure (not indestructible frames).
- [ ] Hearth take damage → run over when HP hits 0 (wire end screen stub).
- [ ] Wave clear when enemy count hits 0 → Dawn.

**Done means:** Horn → pack enters one door → can kill or watch them chew a placed wall / Hearth. Day packs optional (low count) or deferred to end of this slice.

**Reuse:** `BaseEnemy`, `EnemyManager` ideas, `WeightedTable`, hitbox/hurtbox pipeline. Retarget `accelerate_to_player` → nearest-target helper.

---

## Slice 5 — Combat: staff → full weapon set

**Goal:** Aimed ARPG attacks; staff first because art exists.

**Build**

- [ ] Click aim + attack; **Space** dash (cooldown + brief i-frames).
- [ ] **Staff:** projectile using an effect/bullet sheet (e.g. purple); no arrows.
- [ ] **Axe:** melee cleave arc.
- [ ] **Dagger:** high single-target melee burst (placeholder sprite OK).
- [ ] Hearth interact: swap among three weapons (one equipped).

**Done means:** Clear a Night with staff; swap to axe/dagger at Hearth and feel the role difference.

**Reuse:** Hitbox damage flow; do **not** resurrect the deleted `scripts/weapons` tree as a parallel architecture — thin weapon controllers under player/abilities is enough.

---

## Slice 6 — Hero death rules

**Goal:** Design death table in code.

**Build**

- [ ] Night down: hero disabled; camera on Hearth; raid continues; respawn on wave clear.
- [ ] Day death: teleport/cutscene stub → force Night immediately; skip remaining Day actions.
- [ ] Hero death never ends run by itself.

**Done means:** Die in Day → Night starts unprepared. Die in Night → base can still win/lose without you.

---

## Slice 7 — Achievements stub

**Build**

- [ ] Persist flags: night 1 / 3 / 5 survived; day-death; clear while hero down.
- [ ] End screen lists nights survived + newly unlocked achievements.
- [ ] Scrap drop stub optional here or with Slice 8.

**Done means:** Two runs can show a newly unlocked achievement.

---

## Slice 8 — Ballista / trap / scrap

**Build**

- [ ] Weak ballista (chip only — tune so it does not solo Swarmers).
- [ ] Floor trap (chip + slow).
- [ ] Enemies drop **scrap** (no recipes yet).
- [ ] Banner/shrine optional — skip if timeboxed.

**Done means:** Place ballista + trap; scrap appears in inventory; night still needs the hero.

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
