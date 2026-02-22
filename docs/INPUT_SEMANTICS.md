# Input Semantics

This document defines the global input contract for SnakeGB and future mini-games.

## Core Principles

- `A` is the primary/confirm action.
- `B` is the secondary/back action.
- `START` is run control (start/resume).
- `SELECT` is utility action (menu level switch; long-press combos where supported).
- `BACK`/`Esc` is system back/quit.
- D-pad (`UP/DOWN/LEFT/RIGHT`) is directional navigation/movement.

## State Routing

Input is routed by layer in this order:

1. Global shortcuts (`F6`, shell color, music, escape)
2. Icon Lab layer (when active)
3. Overlay layer (`Paused`, `GameOver`, `Replaying`, `ChoiceSelection`)
4. Page layer (`Catalog`, `Achievements`)
5. Gameplay layer (`Playing`)
6. Shell/menu fallback layer (`StartMenu`)

## Per-State Behavior

### StartMenu

- `START` / `A`: start game (load save if present, else new run)
- `SELECT`: switch level
- `UP`: achievements
- `DOWN`: replay
- `LEFT`: catalog
- `RIGHT` or `B`: next palette
- `BACK` / `Esc`: quit application

### Playing

- D-pad: snake direction
- `START`: pause
- `B`: next palette
- `BACK`: no-op

### Paused / GameOver / Replaying / ChoiceSelection

- `START`: continue / state start action
- `Paused`: `SELECT` returns to main menu, `B` is reserved for hidden sequence input
- `GameOver`: `SELECT` returns to main menu (`START` restarts)
- `Replaying` / `ChoiceSelection`: `B` / `BACK` returns to main menu
- D-pad: state-specific navigation

### Catalog / Achievements

- D-pad `UP/DOWN`: list navigation
- `B` / `BACK`: return to main menu
- Mouse wheel / touch drag: list scroll

## Icon Lab (Easter)

- Entry sequence: Konami (`UP,UP,DOWN,DOWN,LEFT,RIGHT,LEFT,RIGHT,B,A`)
- Entry scope: only accepted in `Paused` (or while already inside Icon Lab)
- Exit: `B` from Icon Lab or `F6`
- While Icon Lab is active, D-pad controls icon selection and normal game/page input is blocked.

## Why Konami Is Limited To Paused

Restricting Konami detection to `Paused` avoids collisions with real gameplay/menu navigation:

- `UP` on menu must always open achievements
- D-pad in gameplay must always move snake
- `B` in gameplay must always toggle palette

This keeps hidden debug entry deterministic without stealing normal controls.
