# SnakeGB - Retro GameBoy Style Snake Game (v1.3.0)

[中文版](README_zh.md)

SnakeGB is a high-quality, cross-platform GameBoy-style Snake game built with **Qt 6** and **C++23**. It faithfully simulates the classic retro handheld experience while utilizing modern engineering standards and high-performance optimizations.

> **Note**: This project was entirely generated and optimized by **Gemini CLI** (AI Agent).

## Core Features (v1.3.0)

- **Artistic CRT Engine (v3.1)**: Balanced physical curvature, tight chromatic aberration, and dynamic scanlines for a stunning retro aesthetic.
- **High-Performance Architecture**: 
  - **Async Loading**: Eliminates startup and exit hiccups via background resource initialization and binary serialization.
  - **FSM Management**: Clean state-based logic for Splash, Menu, Play, and Pause.
- **Refined UX & Controls**:
  - **Smart Start**: Automatically resumes from the last session or starts fresh.
  - **OSD System**: On-Screen Display provides visual feedback for palette and shell changes.
  - **Save Management**: Hold SELECT to clear saved progress.
- **8-bit Polyphonic Audio**: Simultaneous BGM and SFX with softened ADSR envelopes.
- **Engineered Reliability**: 100% Clang-Tidy compliant, C++23 standard, and robust unit testing.

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
- **Arrow Keys**: Move snake
- **START (Enter / S)**: Begin game / Continue from save
- **SELECT (Shift)**: Cycle level in menu
- **Hold SELECT (Shift)**: Clear saved session (In Menu)
- **B / X**: Return to Menu / Toggle Palette (In Game) / Quit (In Menu)
- **M**: Toggle Background Music
- **Ctrl**: Toggle Shell Color
- **Esc / Q**: Quit Application

## License
Licensed under the [MIT License](LICENSE).
