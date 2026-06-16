# Runebound Documentation

Technical documentation for the **Runebound** Godot 4.4 project — a 2D roguelike survivor-style game inspired by Vampire Survivors.

## Quick Start

1. Open the project in **Godot 4.4** (`project.godot`).
2. Run the main scene: `res://scenes/main/main.tscn`.
3. Controls: **WASD** / arrow keys to move; abilities fire automatically.

## What Is Implemented Today

The playable loop is a single arena survival run:

- Move the player and survive enemy waves.
- Auto-attacks (sword) target the nearest enemy in range.
- Collect experience orbs dropped by defeated enemies to level up.
- On level-up, choose from two random upgrades (pause menu).
- Arena difficulty ramps every 5 seconds; orcs join the spawn pool at difficulty 6.
- The run ends in **defeat** when the player dies, or when the **5-minute** arena timer expires (end screen; victory text exists in the scene but is not wired to a win condition yet).

Planned features described in the root [README](../README.md) — three hero classes, aim-and-shoot weapons, ranged enemies, boss — are only partially scaffolded. See [Architecture](architecture.md#planned-vs-implemented) for details.

## Documentation Index

| Document | Contents |
|----------|----------|
| [Architecture](architecture.md) | Scene tree, managers, autoloads, physics layers, data flow |
| [Combat](combat.md) | Hitbox/hurtbox damage, abilities, enemy contact damage |
| [Components](components.md) | Reusable scene components (`HealthComponent`, `HitFlashComponent`, etc.) |
| [Progression](progression.md) | Experience, level-ups, upgrade pool, arena difficulty |

## Project Layout

```
runebound/
├── assets/sprites/          # Character, weapon, and tile sprites
├── docs/                    # This documentation
├── resources/
│   ├── upgrades/            # AbilityUpgrade and Ability resources (.tres)
│   └── tileset.tres
├── scenes/
│   ├── ability/             # Sword and axe ability scenes + controllers
│   ├── autoload/            # GameEvents singleton
│   ├── characters/          # Knight, ranger, mage scenes (not used in main run)
│   ├── components/          # Shared component scenes
│   ├── game_object/         # Player, enemies, camera, experience pickup
│   ├── main/                # Main game scene
│   ├── manager/             # Enemy, experience, upgrade, arena time managers
│   └── UI/                  # HUD, upgrade screen, end screen, floating text
└── scripts/
    ├── characters/          # BaseCharacter and class scripts
    └── weapons/             # Weapon base classes (partially integrated)
```

## Key Entry Points

| Path | Role |
|------|------|
| `project.godot` | Engine config, input map, physics layers, autoload |
| `scenes/main/main.tscn` | Root gameplay scene |
| `scenes/autoload/game_events.gd` | Global event bus |
| `scenes/game_object/player/player.tscn` | Active player prefab |
