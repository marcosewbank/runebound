# Runebound

A 2D roguelike survivor game built with **Godot 4.4** — medieval fantasy setting, Vampire Survivors-style arena survival.

**Technical documentation:** [docs/README.md](docs/README.md) (architecture, combat, components, progression).

## Current Playable Build

The main scene (`scenes/main/main.tscn`) implements a survivor loop: move with WASD, auto sword attacks, collect XP, pick upgrades on level-up, survive escalating waves (orcs join at difficulty 6), and last up to 5 minutes. See the docs for what is implemented versus still planned below.

## Description (Design Vision)

Simple game created using Godot Engine.
Will be set in a mediavel fantasy world with three heros to play. Each hero will have it own pros/cons to diferentiate each one of them from the rest.
Only three types of enemies will be created to simplify the creation of the game.

## Reference

<img src="./runebound_excalidraw.jpeg" />

---

## Characteristics

- Godot Engine
- 2D
- Roguelike (Vampire Survivors)
- Aim and Shoot

## Environment/Game Set

- Fantasy
- Medieval

## Classes

- Knight (Square)
    - Tank
    - Melee
    - Stats
        - High HP
        - Low Mana
        - Medium Speed
        - Medium Damage

- Archer (Triangle)
    - Piercing
    - DPS
    - Stats
        - Medium HP
        - Low Mana
        - High Speed
        - Medium Damage

- Mage (Circle)
    - AoE
    - CC
    - DPS
    - Stats
        - Low HP
        - High Mana
        - Low Speed
        - High Damage

# Hability Controls

- Left Click:   Auto-Attack
- Right Click:  DPS
- Q:            DPS
- E:            Escape
- R:            Ultimate

## Enemy

- Melee
- Ranged
- Boss (Final)

## Creators

<div align="center" style="display:flex; align-items: center; justify-content: flex-start; gap: 1rem;">
  <img src="https://github.com/marcosewbank.png" alt="Centered Image" width="100" style="border-radius: 8px;">
  <a href="https://github.com/marcosewbank">marcosewbank</a>
</div>

<div align="center" style="display:flex; align-items: center; justify-content: flex-start; gap: 1rem;">
  <img src="https://github.com/proudynyu.png" alt="Centered Image" width="100" style="border-radius: 8px;">
  <a href="https://github.com/proudynyu">proudynyu</a>
</div>

