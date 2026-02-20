# SnakeGB - Retro GameBoy Style Snake Game (v1.3.2)

[中文版](README_zh-CN.md)

SnakeGB is a high-quality, cross-platform GameBoy-style Snake game built with **Qt 6** and **C++23**. It faithfully simulates the classic retro handheld experience with modern engineering standards and premium haptic/audio feedback.

> **Note**: This project was entirely generated and optimized by **Gemini CLI** (AI Agent).

## Core Features (v1.3.1)

- **Artistic CRT Engine (v3.1)**: Balanced curvature, scanlines, and **Dynamic Gyro Glare** (physical reflection).
- **Premium Haptics**: Nuanced tactile feedback using Android `VibrationEffect` (Tick/Pop/Shock).
- **Immersive Audio**: Stereo panning, dynamic reverb, and **Paused LPF Filter** (muffled BGM when paused).
- **Deterministic Replay System**: 100% accurate high-score replication using logic-tick synchronization and sample-based RNG seeding.
- **Ceremonial Boot**: Classic GameBoy-style animated boot sequence and hardware power-cycle visuals.
- **Scriptable Levels**: Create dynamic maps with moving obstacles using JavaScript.
- **Roguelite Power-ups**: Special fruits providing Ghost, Slow, or Magnet buffs with visual transparency.
- **Achievement Room**: Persistent medal system with full collection display and unlock hints.
- **Optimized for Android**: Single-ABI (arm64-v8a) builds with LTO, MinSizeRel optimization, and symbol stripping for a minimal footprint.

## Tech Stack

- **Language**: C++23 (std::ranges, std::unique_ptr, Coroutines-ready)
- **Framework**: Qt 6.7+ (Quick, JSEngine, Multimedia, Sensors, ShaderTools)
- **Build System**: CMake + Ninja

## Getting Started

### Build and Run (Desktop)
```bash
mkdir build && cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release ..
ninja
./SnakeGB
```

## Controls
- **Arrow Keys**: Move snake
- **START (Enter / S)**: Play / Continue from save
- **SELECT (Shift)**: Cycle levels / (Hold) Delete save
- **UP**: Open Medal Collection
- **DOWN**: Watch Best High-Score Replay
- **B / X**: Back / Cycle Color Palettes
- **Y / C / Tap Logo**: Cycle Console Shell Colors
- **M**: Toggle Music | **Esc**: Quit App

## License
Licensed under the [GNU GPL v3](LICENSE).
