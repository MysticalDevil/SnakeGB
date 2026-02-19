# SnakeGB - Retro GameBoy Style Snake Game (v1.3.0)

[中文版](README_zh-CN.md)

SnakeGB is a high-quality, cross-platform GameBoy-style Snake game built with **Qt 6** and **C++23**. It faithfully simulates the classic retro handheld experience while utilizing modern engineering standards and scriptable gameplay mechanics.

> **Note**: This project was entirely generated and optimized by **Gemini CLI** (AI Agent).

## Core Features (v1.3.0)

- **Artistic CRT Engine (v3.1)**: Balanced physical curvature, chromatic aberration, and dynamic scanlines.
- **Motion Ghosting**: Realistic LCD pixel persistence simulation.
- **Dynamic Tempo Synthesis**: BGM speed increases with player score for intense gameplay.
- **Scriptable Levels**: Create dynamic maps with moving obstacles using JavaScript.
- **Roguelite Power-ups**: Randomly spawning fruits providing Ghost, Slow, or Magnet buffs.
- **Achievement Room**: Persistent medal system with full collection display and unlock hints.
- **Full Match Replay**: Watch deterministic replays of your highest scores.
- **Multi-Platform**: Native support for Windows, Linux, macOS, Android (`org.devil`), and WASM.

## Advanced: Scriptable Levels

Levels in SnakeGB can be dynamic. Add a `script` field to a level in `src/levels/levels.json` using the following signature:

```javascript
// onTick is called every game frame.
// Returns an array of obstacle coordinates {x, y}.
function onTick(tick) {
    // Example: Create a moving vertical wall
    var x = Math.floor(Math.abs(Math.sin(tick * 0.1) * 15));
    return [
        {x: x, y: 5},
        {x: x, y: 6},
        {x: x, y: 7}
    ];
}
```

## Tech Stack

- **Language**: C++23
- **Framework**: Qt 6.5+ (Quick, JSEngine, Multimedia, ShaderTools)
- **Build System**: CMake + Ninja

## Getting Started

### Build and Run
```bash
mkdir build && cd build
cmake -G Ninja ..
ninja
./gameboy-snack
```

## Controls
- **Arrow Keys**: Move snake
- **START (Enter / S)**: Play / Continue from save
- **SELECT (Shift)**: Cycle levels
- **UP**: Open Medal Collection
- **DOWN**: Watch Best Replay
- **Hold SELECT (Shift)**: Delete save
- **B / X**: Back / Quit / Toggle Palette
- **M**: Toggle Music | **Esc**: Quit App

## License
Licensed under the [GNU GPL v3](LICENSE).
