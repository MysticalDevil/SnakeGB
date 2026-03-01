# Level Authoring Guide

This document defines the current level authoring contract for SnakeGB.

It covers:

- level JSON structure
- static wall layout format
- dynamic script level format
- board and safety constraints

For gameplay/runtime architecture, see [ARCHITECTURE_REFACTOR_PLAN.md](/home/omega/ai-workspace/gameboy-snack/docs/ARCHITECTURE_REFACTOR_PLAN.md).

## File Locations

Built-in levels live in:

- [src/levels/levels.json](/home/omega/ai-workspace/gameboy-snack/src/levels/levels.json)

Runtime loading and fallback logic live in:

- [src/services/level/repository.h](/home/omega/ai-workspace/gameboy-snack/src/services/level/repository.h)
- [src/core/level/runtime.cpp](/home/omega/ai-workspace/gameboy-snack/src/core/level/runtime.cpp)
- [src/adapter/level/loader.cpp](/home/omega/ai-workspace/gameboy-snack/src/adapter/level/loader.cpp)
- [src/adapter/level/script_runtime.cpp](/home/omega/ai-workspace/gameboy-snack/src/adapter/level/script_runtime.cpp)

## Board Size

The gameplay board is currently fixed at:

- width: `20`
- height: `18`

See:

- [engine_adapter.h](/home/omega/ai-workspace/gameboy-snack/src/adapter/engine_adapter.h)

Coordinates are zero-based grid coordinates:

- top-left is `(0, 0)`
- bottom-right is `(19, 17)`

## Top-Level JSON Shape

`levels.json` must contain:

```json
{
  "levels": []
}
```

Each entry in `levels` is one level object.

## Required Level Fields

Every level should provide:

- `name`

And then either:

- `walls`

or:

- `script`

Examples:

```json
{
  "name": "Classic",
  "walls": []
}
```

```json
{
  "name": "Dynamic Pulse",
  "script": "function onTick(tick) { ... }"
}
```

## Static Levels

Static levels use a `walls` array.

Wall entry format:

```json
{ "x": 5, "y": 12 }
```

Example:

```json
{
  "name": "The Cage",
  "walls": [
    { "x": 5, "y": 5 },
    { "x": 6, "y": 5 }
  ]
}
```

Rules:

- `x` and `y` should stay inside the board
- duplicates should be avoided
- static walls are applied exactly as written

## Dynamic Levels

Dynamic levels use a `script` string instead of static `walls`.

The script must currently define:

```js
function onTick(tick) {
  return [{x: 1, y: 2}, {x: 3, y: 4}]
}
```

Contract:

- input: `tick` integer
- output: array of objects with numeric `x` and `y`
- returned objects become the current obstacle layout for that frame

Examples from current built-ins:

- `Dynamic Pulse`
- `Crossfire`
- `Shifting Box`

All three use discrete phase arrays and integer tick buckets.

## Recommended Dynamic Pattern Style

Prefer:

- discrete phases
- predictable dwell time
- symmetric movement
- obvious safe windows

Avoid:

- continuous per-frame jitter
- phase changes that are too fast to read
- patterns that close directly on the player without warning

Current built-in cadence examples:

- `Dynamic Pulse`: `12` ticks per phase
- `Crossfire`: `10` ticks per phase
- `Shifting Box`: `14` ticks per phase

## Naming Guidance

Level names should be stable because they are currently used by:

- UI display
- fallback logic
- dynamic obstacle runtime helpers

If you rename a built-in dynamic level, update:

- [src/levels/levels.json](/home/omega/ai-workspace/gameboy-snack/src/levels/levels.json)
- [src/core/level/runtime.cpp](/home/omega/ai-workspace/gameboy-snack/src/core/level/runtime.cpp)

## Safety Guidelines

- Keep spawnable free space available.
- Do not completely fill the board.
- Avoid placing static walls in a way that blocks all valid initial snake body placements.
- For dynamic levels, ensure multiple consecutive ticks remain readable and survivable.
- If a level depends on script motion, keep its initial script frame coherent with expected difficulty.

## Fallback Behavior

The runtime also contains built-in fallback definitions in:

- [src/core/level/runtime.cpp](/home/omega/ai-workspace/gameboy-snack/src/core/level/runtime.cpp)

If you change the shipped JSON definitions for built-in levels, keep fallback definitions aligned.

This matters for:

- resource load failures
- tests
- deterministic behavior during bootstrap/refactor work

## Validation Workflow

For level edits:

```bash
clang-format -i src/core/level/runtime.cpp tests/test_core_rules.cpp tests/test_engine_adapter.cpp
./scripts/dev.sh clang-tidy build/dev src/core/level/runtime.cpp tests/test_core_rules.cpp tests/test_engine_adapter.cpp
cmake --build build/dev --parallel
cd build/dev && ctest --output-on-failure
```

Useful manual checks:

```bash
./build/dev/SnakeGB
./scripts/ui.sh nav-debug game
./scripts/ui.sh nav-capture dbg-static-game /tmp/level_preview.png
```

## Current Limits

- Dynamic scripts are embedded as single-line strings in JSON.
- Only `onTick(tick)` is currently supported as the script contract.
- There is no standalone level linter yet.
- There is no editor UI yet for authoring or previewing level scripts.
