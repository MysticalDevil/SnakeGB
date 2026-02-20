# SnakeGB - 复古 GameBoy 风格贪吃蛇游戏 (v1.3.1)

[English Version](README.md)

SnakeGB 是一款基于 **Qt 6** 和 **C++23** 构建的高品质、跨平台仿 GameBoy 贪吃蛇游戏。本项目在追求工业级工程标准的同时，通过极致的触感、音效和视觉微调，忠实还原并超越了经典复古掌机的感官体验。

> **注意**：本项目的所有代码、资源配置及文档均由 **Gemini CLI** (AI Agent) 自动生成并迭代优化。

## 核心特性 (v1.3.1)

- **艺术级 CRT 引擎 (v3.1)**：平衡的球面畸变、扫描线，以及由**真实陀螺仪驱动的动态反射**（Dynamic Glare）。
- **细腻触感反馈**：基于 Android `VibrationEffect` 实现的分级触感（按键 Tick、吞噬 Pop、撞击 Shock）。
- **沉浸式音效交互**：支持立体声平移、动态混响，以及具有空间感的**暂停低通滤波**（暂停时 BGM 变闷响）。
- **仪式感开机序列**：经典的 GameBoy 式 Logo 掉落动画与清脆的“叮-叮”自检音效。
- **动态脚本关卡**：支持使用 JavaScript 定义具有移动障碍物的动态地图。
- **Roguelite 随机元素**：提供穿墙（幽灵视觉）、减速、磁吸 Buff 的特殊果实。
- **全平台原生支持**：深度适配 Android (`org.devil`)，同时支持 Linux, Windows 和 WASM。

## 技术栈

- **语言**：C++23
- **框架**：Qt 6.5+ (Quick, JSEngine, Multimedia, Sensors, ShaderTools)
- **构建系统**：CMake + Ninja

## 快速开始

### 编译运行 (桌面版)
```bash
mkdir build && cd build
cmake -G Ninja ..
ninja
./SnakeGB
```

## 操控说明
- **方向键**：控制蛇移动
- **START (Enter / S)**：开始游戏 / 继续进度
- **SELECT (Shift)**：切换关卡 / (长按) 清除存档
- **UP (方向键上)**：打开勋章陈列室
- **DOWN (方向键下)**：观看最高分回放
- **B / X**：返回 / 退出 / 切换调色盘
- **M**：开启/关闭音乐 | **Esc**: 退出应用

## 许可证
本项目采用 [GNU GPL v3](LICENSE) 开源协议。
