# Runebound — Design Target (MVP)

Target design for the next major pivot. This is **not** a description of the current playable build; see [README.md](README.md) for what runs today.

**Genre:** Top-down ARPG with a defendable base (day/night) — **roguelite** runs.  
**Pillar:** Playing the hero is the fun. Buildings support fights; they do not replace them.  
**Meta (MVP-light):** permanent **achievements** unlocked across runs. No skill tree / blueprint meta in MVP.

---

## Core loop

Player-triggered phases (no forced day timer):

```
DAY  →  gather outside, build/repair inside, swap weapon at Hearth
  ↓     (player sounds the horn)
DUSK → skip in first slice (optional polish later)
  ↓
NIGHT → defend the active door; weapon swap only at Hearth
  ↓     (wave cleared)
DAWN → loot summary, scarce nodes refill, loop to DAY
```

Player may **sound the horn anytime** (including with zero prep / Night 0).
**Run end (defeat):** Hearth destroyed.  
**Run “win”:** no fixed night cap in MVP — push as many nights as you can; the lasting progress is **achievements** unlocked (firsts, milestones, challenge flags). End screen shows nights survived + new achievements.

Hero death alone never ends the run (see below).

### Hero death

| When | What happens |
|------|----------------|
| **Night** | Hero goes down; the **raid continues** until all wave enemies are dead. If the Hearth is destroyed → **game over**. Clear without the hero still counts. Hero respawns at Hearth when the wave ends. |
| **Day** | Hero returns to the Hearth; short cutscene; **Night starts immediately**. Rest of that Day is lost (no further gather / build / prep). |

Day death = greed tax. Night death = panic tax (base must hold alone).

**Small UX:** while downed at Night, camera stays on the **Hearth**. Hero respawns at Hearth when the wave ends.

---

## Map

Reference sketch: [reference/map_layout_sketch.png](reference/map_layout_sketch.png)

- Fixed **square plain**, flat terrain only (no height layers in MVP).
- **Hearth** at the center — primary objective / lose condition.
- **Starter frames:** four **L-shaped corner segments** with **four large doors** (N/E/S/W). **Indestructible** — the silhouette of the base never collapses.
- **Player-built structures** (extra walls, traps, ballistae, etc.): **destructible**. Enemies can break them. Sealing doors shut is allowed in principle but **not affordable** under scarce resources, and broken seals reopen pressure.
- **Buildable zone:** inside the wall ring.
- **Outside:** wood/stone nodes refill each Day; light day enemies. Food (or a third gatherable) is post-MVP.
- **Camera:** always follows the hero. Zoom 1.0 in MVP.
- Exact tile counts tunable; layout shape is the contract.

### Night spawn (MVP)

Each **run** picks **one random door** (pillar/approach) as the night spawn side for that whole run. Waves come through that door only.

Post-MVP: multi-door pressure, shifting doors, etc.

### Enemy targeting (MVP rule)

Enemies prefer **what is closest** (hero or **destructible** structure in range). Indestructible starter frames are collision/cover, not HP targets.

- Player walls/traps/turrets soak and redirect attention.
- Hearth is vulnerable when nothing closer is in the way or the line is broken.
- Per-enemy weights (Breacher → walls) can come later; one shared nearest-target rule is enough for MVP.

---

## Weapons (no classes)

No hero classes. Identity = **one equipped weapon**. All three exist from run start and are **swappable at the Hearth** (including during Night if you reach it).

| Weapon | Role | Art (repo) |
|--------|------|------------|
| **Staff** | Long range — aim and launch **effect projectiles** (use existing effect/bullet sheets, not physical arrows) | `staff_.png` + `* Effect and Bullet 16x16.png` |
| **Axe** | Slash / cleave — multiple enemies in an arc | `axe_.png` |
| **Dagger** | High single-target burst (priority kills) | Stub from `sword_.png` or `weapons_.png` crop until a dedicated dagger exists |

**Rules:**

- Only **one** active at a time; no field hotbar swap.
- **No weapon upgrades in MVP.** Equipment / weapon upgrades / hero stat tweaks are post-MVP.
- Hero uses **default stats** for the whole MVP.

Attack: aim with mouse, attack on click (see Controls). Staff shots are projectiles from the effect sheets (pick one palette for MVP, e.g. purple or green).

---

## Controls (MVP)

| Input | Action |
|-------|--------|
| **WASD** | Move |
| **Mouse + click** | Aim and attack (equipped weapon) |
| **E** | Interact (instant gather, repair, Hearth weapon swap, sound horn, place confirm — context) |
| **Space** | Dash / roll (short cooldown, brief i-frames — tunable) |

---

## Economy & building

### Resources (MVP)

- **Wood** and **Stone** only.
- Nodes outside the walls; refill each Dawn to a scarce, **data-driven** cap.
- **Food** (sketch’s extra node color) — later, not MVP.

**Scarcity goal:** cannot afford every defense every day; full door-seals should be economically foolish.

### Mob loot & crafting

**Planned, not fully specified.** Mobs drop loot; crafting comes later.  

**MVP stub:** enemies can drop generic **scrap**. No recipes required until the craft pass — scrap is inventory fodder / future craft fuel.

### Achievements (MVP stub)

Saved between runs. Starting set:

- Survived night 1  
- Survived night 3  
- Survived night 5  
- Died during Day (forced Night)  
- Cleared a Night while the hero was down  

Expand later; this list is enough for an end-screen “new unlock” beat.

### Defenses (MVP short list)

| Build | Role |
|-------|------|
| Wooden / stone wall | Block and soak (destructible) |
| Floor trap | Chip + slow for hero cleave |
| Weak ballista | Chip only — must not clear a push alone |
| Banner / shrine (optional) | Buff **hero** in radius, not turrets |

Guardrail: a lone ballista should not kill a basic Swarmer before it reaches the fight line.

### Placement & repair

| Action | Day | Night |
|--------|-----|-------|
| **Place** new structures | Yes (inside walls) | **No** |
| **Repair** player structure | Yes — on the piece, spend resources | **Yes** |
| **Repair Hearth** | Yes — on Hearth, spend resources | **Yes** |

Starter frames: not repaired (indestructible). Repair is always per-structure.

---

## Enemy pool (MVP)

| Role | Behavior intent |
|------|-----------------|
| **Swarmer** | Fast, low HP — pressure the hero when close |
| **Breacher** | Slow, high HP — smash **player** buildings |
| **Artillery** | Ranged — pressure Hearth / backline |

**Day:** low count, easy to clear — annoyance and greed tax, not a second Night.  
**Night:** full wave through the **run’s single active door**; escalate count/composition across nights (tunable).

---

## Progression

| Layer | MVP | Later |
|-------|-----|--------|
| In-run hero power | Default stats + weapon choice + base layout | Equipment, weapon upgrades |
| In-run economy | Wood/stone, basic builds, stub loot | Full loot → craft graph, food |
| Between runs | **Achievements** saved | Richer meta if needed |
| Level-up draft | **Removed** (survivors leftover) | — |

---

## What we are not building in MVP

- Hero classes / mana / ability kits  
- Weapon or equipment upgrade trees  
- Food / third gather resource  
- Multi-door night pressure  
- Expanding land chunks  
- Multi-height terrain  
- Full crafting catalog (stub OK)  
- Random level-up draft  
- Fixed “survive N nights = victory” campaign (endless push + achievements instead)

---

## Relation to the current codebase

Reusable with rewiring:

- Component damage pipeline (`Hitbox` / `Hurtbox` / `Health`)
- `StatsComponent` + `EntityStats` resources
- `BaseAbilityController` + `Targeting` (pattern for weapons / ballista)
- `WeightedTable`, `GameEvents`, camera, VFX

Replace / retire for this design:

- Arena timer as win condition
- Random upgrade draft as core progression
- Enemies that only chase the player
- Auto-attack-only combat as the long-term model

---

## Smallest playable slice

1. Map + indestructible L-frames + Hearth HP + four doors (sketch).  
2. Day/Night + horn; one random active door per run.  
3. Wood/stone nodes; place + repair one wall type.  
4. Night wave through active door; nearest-target AI.  
5. WASD + click attack + E + Space dash; staff first (effect projectiles), then axe + dagger + Hearth swap.  
6. Hero death rules.  
7. Achievements stub (nights 1/3/5, day-death, clear while downed).  
8. Ballista / trap / scrap drops after the door fight feels good.

---

## Decisions log (locked)

| Topic | Decision |
|-------|----------|
| Run structure | Roguelite; Hearth death ends run; meta = achievements |
| Victory | No night cap — push nights; achievements are lasting progress |
| Weapons | All three available from start (staff / axe / dagger); swap at Hearth only |
| Weapon / hero upgrades | Post-MVP; default hero stats in MVP |
| Night spawn | One random door per **run** |
| Starter frames | Indestructible |
| Player buildings | Destructible; seal possible but scarce |
| Resources | Wood + stone; food later |
| Loot / craft | Exists in plan; table defined later |
| Day enemies | Low quantity, easy |
| Controls | WASD, click attack, E interact, Space dash |
| Night placement | Locked |
| Repair | Per-structure + Hearth, Day and Night |
| Achievements (MVP stub) | Survived night 1 / 3 / 5; died during Day; cleared a Night while hero was down |
| Horn | Callable anytime (including unprepared Night 0) |
| Gather | Instant pickup on E |
| Dash | Short cooldown + brief i-frames (tune in playtest) |
| Loot stub | Generic “scrap” drop until craft recipes are defined |
| Night downed camera | Follow Hearth |
| Dusk intel UI | Skip for first slice |
| Weapon swap | At placed **Weapon Stand** only (not Hearth) |
| Build UI | Panel toggled with **B**; select building then place |
| Hearth E | Repair if damaged; else sound horn (Day). No weapon cycle |

## Later (not MVP)

| Topic | Status |
|-------|--------|
| Full loot types + craft recipes | Deferred |
| Exact map size in tiles | Tunable playtest |
| Multi-door nights | Post-MVP |
| Equipment / weapon upgrades / food | Post-MVP |
| Dawn one-click repair QoL | Optional later |
| Richer achievement set | Expand after stub |
