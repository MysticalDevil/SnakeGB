# SnakeGB - Retro GameBoy Style Snake Game

[中文版](README_zh.md)

SnakeGB is a high-quality GameBoy-style Snake game built with **Qt 6** and **C++23**. This project simulates the classic retro handheld experience from low-level architecture to top-level visuals.

> **Note**: All code, resource configurations, and documentation for this project were automatically generated and iteratively optimized by **Gemini CLI** (AI Agent).

## Core Features

- **Modern C++23**: Full use of `std::ranges`, trailing return types, smart pointers, and strict `const` semantics.
- **High-Performance Rendering**:
  - RHI rendering based on the **Vulkan** backend.
  - **ShaderEffect**: Physical simulation of LCD pixel grids, barrel distortion, and vignetting.
  - **SnakeModel**: Incremental updates based on `QAbstractListModel` to ensure jitter-free QML rendering.
- **8-bit Audiovisual System**:
  - **Procedural Audio**: In-memory generation of square waves and noise, supporting multi-channel BGM and SFX mixing.
  - **ADSR Envelope**: Optimized volume attack and decay for a soft, pleasant sound.
- **Superior Interaction**:
  - **Input Queue**: Resolves rapid-turn conflicts for smooth, responsive controls.
  - **Dynamic Vibration**: Automatically adjusts screen shake intensity based on gameplay events.
- **Complete Game Mechanics**:
  - **Finite State Machine (FSM)**: Decoupled state management.
  - **Savestate**: Automatic persistence of progress, scores, and level settings.
  - **Ghost System**: Compete against the translucent phantom of your all-time high score.
  - **Level System**: Supports structured level loading via JSON.

## Tech Stack

- **Language**: C++23
- **Framework**: Qt 6.x (Quick/QML, Multimedia, ShaderTools)
- **Build System**: CMake + Ninja
- **Quality Assurance**: QtTest, Clang-Tidy, Clang-Format, GitHub Actions CI

## Getting Started

### Prerequisites
- Qt 6.5+ (including Multimedia and ShaderTools modules)
- Vulkan-capable drivers
- Doxygen (optional, for documentation generation)

### Build and Run
```bash
mkdir build && cd build
cmake -G Ninja ..
ninja
./gameboy-snack
```

### Run Tests
```bash
cd build
ctest --output-on-failure
```

## Controls
- **Arrow Keys**: Move
- **Enter / S**: START
- **Shift**: SELECT (Level selection / Resume save)
- **B / X**: Toggle palette / Return to menu
- **M**: Toggle music
- **Ctrl**: Toggle shell color

## License
This project is licensed under the [MIT License](LICENSE).
