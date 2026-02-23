# Input Semantics

This document defines the global input contract for SnakeGB and future mini-games.

## Core Principles

- `A` is the primary/confirm action.
- `B` is the secondary action. In gameplay/menu it cycles palette; in page/overlay it is routed per state.
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

- `START`: start game (load save if present, else new run)
- `A`: no-op (reserved, except explicit confirmation prompts such as save-clear confirm)
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
- `A`: no-op (reserved for future game-specific action)
- `BACK`: no-op

### Paused / GameOver / Replaying / ChoiceSelection

- `START`: continue / state start action
- `SELECT`: return to main menu (all overlay states)
- `B`: no-op for gameplay/menu transitions (reserved for paused Konami sequence token)
- `GameOver`: `START` restarts
- `A`: no-op on overlays (except Konami `A` token while paused)
- D-pad: state-specific navigation

### Catalog / Achievements

- D-pad `UP/DOWN`: list navigation
- `B` / `BACK`: return to main menu
- `A` / `START` / `SELECT`: no-op
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

## Debug Injection Tokens

For automation or manual debug through `inputInjector`, these direct tokens are supported:

- `DBG_MENU`: jump to main menu
- `DBG_PLAY`: jump to playing state
- `DBG_PAUSE`: jump to paused overlay
- `DBG_GAMEOVER`: jump to game-over overlay
- `DBG_REPLAY`: jump to replay state
- `DBG_CHOICE`: jump to roguelike choice overlay
- `DBG_CATALOG`: jump to catalog page
- `DBG_ACHIEVEMENTS`: jump to achievements page
- `DBG_ICONS`: enter Icon Lab directly

These tokens are debug-only shortcuts. They do not change the runtime semantics of physical buttons.
