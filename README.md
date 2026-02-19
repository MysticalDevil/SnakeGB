# SnakeGB - Retro GameBoy Style Snake Game

SnakeGB 是一款基于 **Qt 6** 和 **C++23** 构建的高品质仿 GameBoy 贪吃蛇游戏。本项目从底层架构到顶层视觉均模拟了经典的复古掌机体验。

> **注意**：本项目的所有代码、资源配置及文档均由 **Gemini CLI** (AI Agent) 自动生成并迭代优化。

## 核心特性

- **现代 C++23**：全面应用 `std::ranges`、尾置返回、智能指针及严格的 `const` 语义。
- **高性能渲染**：
  - 基于 **Vulkan** 后端的 RHI 渲染。
  - **ShaderEffect**：物理模拟 LCD 像素网格、球面畸变及暗角。
  - **SnakeModel**：基于 `QAbstractListModel` 的增量刷新，确保 QML 渲染零抖动。
- **8-bit 视听系统**：
  - **Procedural Audio**：内存生成方波与噪声，支持多通道 BGM 与 SFX 混音。
  - **ADSR 包络**：优化的音量渐入渐出，听感柔和。
- **极致交互**：
  - **输入缓冲 (Input Queue)**：解决快速转向冲突，手感丝滑。
  - **动态震动反馈**：根据游戏强度自动调整屏幕抖动。
- **完整游戏机制**：
  - **有限状态机 (FSM)**：解耦的状态管理。
  - **Savestate**：自动保存进度、分数及关卡设置。
  - **幽灵回放 (Ghost System)**：与历史最高分的残影同台竞技。
  - **关卡系统**：支持 JSON 结构化关卡加载。

## 技术栈

- **语言**：C++23
- **框架**：Qt 6.x (Quick/QML, Multimedia, ShaderTools)
- **构建系统**：CMake + Ninja
- **质量保障**：QtTest, Clang-Tidy, Clang-Format, GitHub Actions CI

## 快速开始

### 依赖要求
- Qt 6.5+ (包含 Multimedia, ShaderTools 模块)
- 支持 Vulkan 的驱动
- Doxygen (可选，用于生成文档)

### 编译运行
```bash
mkdir build && cd build
cmake -G Ninja ..
ninja
./gameboy-snack
```

### 运行测试
```bash
cd build
ctest --output-on-failure
```

## 操控说明
- **方向键**：移动
- **Enter / S**：开始 (START)
- **Shift**：选择关卡 / 恢复存档 (SELECT)
- **B / X**：切换调色盘 / 返回主页
- **M**：开启/关闭音乐
- **Ctrl**：切换机身颜色

## 许可证
本项目采用 [MIT License](LICENSE) 开源协议。
