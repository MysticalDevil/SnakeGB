# SnakeGB - Retro GameBoy Style Snake Game (v1.2.0)

[中文版](README_zh.md)

SnakeGB is a high-quality, cross-platform GameBoy-style Snake game built with **Qt 6** and **C++23**. It faithfully simulates the classic retro handheld experience while utilizing modern engineering standards.

> **Note**: This project was entirely generated and optimized by **Gemini CLI** (AI Agent).

## Core Features

- **Multi-Platform & Architecture**: Standardized CMake configuration for Windows, macOS, Linux, and Mobile.
- **Adaptive Rendering**: Automatic RHI backend selection (Vulkan, Metal, DirectX 12, or OpenGL).
- **Advanced LCD Simulation**: Pre-compiled `.qsb` shaders providing pixel grids, barrel distortion, and vignetting.
- **Robust Architecture**: 
  - **FSM (Finite State Machine)**: Clean state management for Splash, Menu, Play, and Pause.
  - **Input Buffering**: Queue-based input logic to eliminate rapid-turn collisions.
  - **SnakeModel**: Jitter-free incremental QML rendering.
- **8-bit Polyphonic Audio**:
  - Simultaneous BGM and SFX playback.
  - Softened 8-bit pulse waves with ADSR envelopes.
- **Game Features**: Level system (JSON-based), Ghost system (high score replay), and automatic Savestate persistence.

## Tech Stack

- **Language**: C++23
- **Framework**: Qt 6.5+ (Quick, Multimedia, ShaderTools)
- **Build System**: CMake + Ninja
- **QA**: QtTest, Clang-Tidy, Clang-Format, GitHub CI

## Getting Started

### Build and Run
```bash
mkdir build && cd build
cmake -G Ninja ..
ninja
./gameboy-snack
```

### Run Tests
```bash
ctest --output-on-failure
```

## Controls
- **Arrow Keys**: Move
- **Enter / S**: START (Begin game)
- **Shift**: SELECT (Cycle level in menu / Resume save)
- **B / X**: Return to Menu / Toggle Palette
- **M**: Toggle Background Music
- **Ctrl**: Toggle Shell Color

## License
Licensed under the [MIT License](LICENSE).
