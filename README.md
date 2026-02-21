# SnakeGB - Retro GameBoy Style Snake Game (v1.4.0)

[中文版](README_zh-CN.md)

SnakeGB is a high-quality, cross-platform GameBoy-style Snake game built with **Qt 6** and **C++23**. It faithfully simulates the classic retro handheld experience with modern engineering standards and premium haptic/audio feedback.

> **Note**: This project was entirely generated and optimized by **Gemini CLI** (AI Agent).

## Core Features (v1.4.0)

- **GameBoy Boot Flow**: Boot bounce animation + boot beep + delayed BGM handoff to menu.
- **Expanded Navigation**: Hidden fruit library (`LEFT`), achievements room (`UP`), replay (`DOWN`), level switch (`SELECT`).
- **Refined Input Rules**: Context-sensitive `B` behavior restored across menu/game/pause/game-over/roguelike/library/medal.
- **Dynamic Levels**: `Classic`, `The Cage`, `Dynamic Pulse`, `Tunnel Run`, `Crossfire`, `Shifting Box`.
- **Roguelike Power-up Suite**: 9 distinct effects including working **Magnet** fruit attraction and unique portal wall-phasing.
- **Ghost Replay**: Deterministic replay with recorded input and choice playback.
- **Mobile Sensor Glare**: `QtSensors` accelerometer-powered screen reflection movement (with desktop fallback motion).
- **Android Ready**: arm64 deployment pipeline and runtime logcat-driven crash triage workflow.

## Tech Stack

- **Language**: C++23 (std::ranges, std::unique_ptr, Coroutines-ready)
- **Framework**: Qt 6.7+ (Quick, JSEngine, Multimedia, Sensors, ShaderTools)
- **Build System**: CMake + Ninja

## Getting Started

### Build and Run (Desktop)
```bash
cmake -S . -B build-debug -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build-debug --parallel
./build-debug/SnakeGB
```

```bash
cmake -S . -B build-release -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build-release --parallel
./build-release/SnakeGB
```

- `Debug`: full runtime logs enabled.
- `Release` / `MinSizeRel` / `RelWithDebInfo`: `qDebug/qInfo/qWarning` logs are compiled out (desktop + Android).

### Build and Deploy (Android)
```bash
# Debug build (logs enabled)
CMAKE_BUILD_TYPE=Debug ./scripts/android_deploy.sh

# Release build (logs disabled)
CMAKE_BUILD_TYPE=Release ./scripts/android_deploy.sh
```

## Controls
- **Arrow Keys**: Move snake
- **START (Enter / S)**: Play / Continue from save
- **SELECT (Shift)**: Cycle levels / (Hold) Delete save
- **UP**: Open Medal Collection
- **DOWN**: Watch Best High-Score Replay
- **LEFT**: Open hidden Fruit Library
- **B / X**:
  - In game: switch display palette
  - In menu: quit app
  - In pause/game over/replay/library/medal: back to menu
  - In roguelike choice: switch display palette
- **Y / C / Tap Logo**: Cycle Console Shell Colors
- **M**: Toggle Music | **Esc**: Quit App

## License
Licensed under the [GNU GPL v3](LICENSE).
