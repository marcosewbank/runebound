# Runebound Documentation

Technical documentation for the **Runebound** Godot 4.4 project.

**Design target:** top-down ARPG with a defendable base (day/night). See [design.md](design.md).  
**Playable today:** still the survivors-style arena loop described below — the pivot is not implemented yet.

## Quick Start

1. Open the project in **Godot 4.4** (`project.godot`).
2. Run the main scene: `res://scenes/main/main.tscn`.
3. Controls: **WASD** / arrow keys to move; abilities fire automatically.

## What Is Implemented Today

The playable loop is a single arena survival run:

- Move the player and survive enemy waves.
- Auto-attacks (sword) target the nearest enemy in range.
- Collect experience orbs dropped by defeated enemies to level up.
- On level-up, choose from random upgrades (pause menu) — abilities and stat modifiers.
- Arena difficulty ramps every 5 seconds; orcs join the spawn pool at difficulty 6.
- The run ends in **defeat** when the player dies, or **victory** when the **5-minute** arena timer expires.

## Documentation Index

| Document | Contents |
|----------|----------|
| [Design](design.md) | **Target** MVP design — map, weapons, day/night, economy (not yet built) |
| [Implementation](implementation.md) | MVP slice checklist — use with `/implement-slice` |
| [Architecture](architecture.md) | Scene tree, managers, autoloads, physics layers, data flow |
| [Combat](combat.md) | Unified hitbox/hurtbox damage, abilities, teams |
| [Components](components.md) | Reusable scene components (`HealthComponent`, `StatsComponent`, etc.) |
| [Progression](progression.md) | Experience, level-ups, stat upgrades, arena difficulty |

## Project Layout

```
runebound/
├── assets/sprites/          # Character, weapon, and tile sprites
├── docs/                    # This documentation
├── resources/
│   ├── stats/               # EntityStats definitions (.tres)
│   ├── upgrades/            # AbilityUpgrade / Ability / StatUpgrade resources
│   └── tileset.tres
├── scenes/
│   ├── ability/             # Sword and axe ability scenes + controllers
│   ├── autoload/            # GameEvents singleton
│   ├── components/          # Shared component scenes
│   ├── game_object/         # Player, enemies, camera, experience pickup
│   ├── main/                # Main game scene
│   ├── manager/             # Enemy, experience, upgrade, arena time, run managers
│   └── UI/                  # HUD, upgrade screen, end screen, floating text
└── scripts/
    ├── constants/           # Groups, Layers, Stats StringName constants
    ├── entities/            # BaseEnemy
    ├── systems/             # Targeting, BaseAbilityController
    └── weighted_table.gd
```

## Key Entry Points

| Path | Role |
|------|------|
| `project.godot` | Engine config, input map, physics layers, autoload |
| `scenes/main/main.tscn` | Root gameplay scene |
| `scenes/autoload/game_events.gd` | Global event bus |
| `scenes/manager/run_manager.gd` | Run lifecycle (victory / defeat) |
| `scenes/game_object/player/player.tscn` | Active player prefab |
| `resources/stats/*.tres` | Data-driven entity base stats |
