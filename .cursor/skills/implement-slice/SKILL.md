---
name: implement-slice
description: >-
  Implements the next MVP playable slice for Runebound against docs/design.md and
  docs/implementation.md. Use when the user asks to implement, build, code the
  next slice, or continue MVP development. Does exactly one slice, then stops.
disable-model-invocation: true
---

# Implement Slice (Runebound MVP)

Implement **one** slice from `docs/implementation.md`, then stop. Do not start the next slice unless the user explicitly asks.

## Before coding

1. Read `docs/design.md` (target) and `docs/implementation.md` (checklist + current slice).
2. Mark which slice is in progress (first unchecked **Build** item, or the one the user named).
3. Skim only the existing code you will touch — prefer reusing components (`HealthComponent`, `StatsComponent`, `Hitbox`/`Hurtbox`, `GameEvents`, `VelocityComponent`) over new parallel systems.
4. If the slice conflicts with `docs/design.md`, stop and ask — do not silently redesign.

## Hard rules

- **One slice per invocation.** Ship a playable/testable increment, update the checklist, stop.
- **No survivors creep.** Do not reintroduce random upgrade drafts, arena-timer victory, or auto-attack-only as the long-term combat model unless the slice says to delete/retire them.
- **Weapons:** staff (effect projectiles), axe (cleave), dagger (single burst). No bow.
- **Placeholders OK** — colored rects, fountain-as-Hearth, fence tiles as walls — until a later polish slice.
- **Data over magic numbers** — costs, spawns, refill amounts as exports or `.tres`.
- **Do not expand scope** into loot recipes, food, multi-door nights, equipment, or audio unless that is the named slice.

## After coding

1. Check off completed items in `docs/implementation.md`.
2. Note any playtest risks or follow-ups under that slice’s “Done means” notes if needed.
3. Summarize for the user: what changed, how to test in Godot, what the **next** slice is (do not start it).

## Slice order (source of truth)

Follow the numbered order in `docs/implementation.md`. Default start: **Slice 1 — Map & Hearth**.
