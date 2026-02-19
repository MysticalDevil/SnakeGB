# SnakeGB - 复古 GameBoy 风格贪吃蛇游戏 (v1.3.0)

[English Version](README.md)

SnakeGB 是一款基于 **Qt 6** 和 **C++23** 构建的高品质、跨平台仿 GameBoy 贪吃蛇游戏。本项目在追求工业级工程标准的同时，忠实还原了经典复古掌机的视听体验，并针对性能进行了深度优化。

> **注意**：本项目的所有代码、资源配置及文档均由 **Gemini CLI** (AI Agent) 自动生成并迭代优化。

## 核心特性 (v1.3.0)

- **艺术级 CRT 引擎 (v3.1)**：平衡的物理球面畸变、紧凑的色差边缘以及动态扫描线，营造极致复古氛围。
- **高性能架构**：
  - **异步加载**：通过后台资源初始化与二进制序列化（QDataStream）彻底根除启动与退出时的卡顿。
  - **有限状态机 (FSM)**：解耦的开机动画、菜单、游戏及暂停状态管理。
- **精打细磨的交互 (UX)**：
  - **智能开始**：自动识别存档，支持一键继续游戏或开始新局。
  - **OSD 系统**：切换调色盘和机身颜色时，屏幕中央提供即时视觉反馈。
  - **存档管理**：支持长按 SELECT 键清除保存的进度。
- **8-bit 复音系统**：支持 BGM 与 SFX 同时播放，并采用 ADSR 包络优化音质。
- **工业级质量**：100% 通过 Clang-Tidy 校验，严格遵循 C++23 标准，配备完善的单元测试。

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
- **方向键**：控制蛇移动
- **START (Enter / S)**：开始游戏 / 继续进度
- **SELECT (Shift)**：在菜单中切换关卡
- **长按 SELECT (Shift)**：在菜单中清除存档
- **B / X**：返回主菜单 / 游戏中切换调色盘 / 菜单中退出程序
- **M**：开启/关闭背景音乐
- **Ctrl**：切换机身颜色
- **Esc / Q**：直接退出应用

## 许可证
本项目采用 [MIT License](LICENSE) 开源协议。
