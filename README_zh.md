# SnakeGB - 复古 GameBoy 风格贪吃蛇游戏 (v1.2.0)

[English Version](README.md)

SnakeGB 是一款基于 **Qt 6** 和 **C++23** 构建的高品质、跨平台仿 GameBoy 贪吃蛇游戏。本项目在追求工业级工程标准的同时，忠实还原了经典复古掌机的视听体验。

> **注意**：本项目的所有代码、资源配置及文档均由 **Gemini CLI** (AI Agent) 自动生成并迭代优化。

## 核心特性

- **多平台与多架构支持**：标准化 CMake 配置，适配 Windows, macOS, Linux 及移动端。
- **自适应渲染**：自动选择最佳图形后端（Vulkan, Metal, DirectX 12 或 OpenGL）。
- **高级 LCD 模拟**：预编译 `.qsb` 着色器，实现像素网格、球面畸变及暗角效果。
- **稳健架构**：
  - **有限状态机 (FSM)**：解耦的开机动画、菜单、游戏及暂停状态管理。
  - **输入指令缓冲**：基于队列的输入逻辑，彻底根除快速掉头导致自杀的 Bug。
  - **SnakeModel**：增量更新机制，确保 QML 渲染丝滑零抖动。
- **8-bit 复音系统**：
  - 支持 BGM（背景音乐）与 SFX（音效）同时播放。
  - 采用 ADSR 包络优化的柔和 8-bit 方波。
- **完善机制**：JSON 关卡系统、幽灵回放（最高分残影）及全自动进度存档 (Savestate)。

## 技术栈

- **语言**：C++23
- **框架**：Qt 6.5+ (Quick, Multimedia, ShaderTools)
- **构建系统**：CMake + Ninja
- **质量保障**：QtTest, Clang-Tidy, Clang-Format, GitHub CI

## 快速开始

### 编译运行
```bash
mkdir build && cd build
cmake -G Ninja ..
ninja
./gameboy-snack
```

### 运行测试
```bash
ctest --output-on-failure
```

## 操控说明
- **方向键**：移动
- **Enter / S**：START (开始游戏)
- **Shift**：SELECT (菜单中切换关卡 / 恢复进度)
- **B / X**：返回主菜单 / 切换调色盘
- **M**：开启/关闭背景音乐
- **Ctrl**：切换机身颜色

## 许可证
本项目采用 [MIT License](LICENSE) 开源协议。
