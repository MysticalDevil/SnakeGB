# SnakeGB - 复古 GameBoy 风格贪吃蛇 (v1.3.2)

[English](README.md)

SnakeGB 是一款基于 **Qt 6** 和 **C++23** 构建的高质量、跨平台 GameBoy 风格贪吃蛇游戏。它以现代工程标准忠实还原了经典复古掌机的操作体验，并提供顶级的触觉与音频反馈。

> **注**：本项目完全由 **Gemini CLI** (AI Agent) 生成并持续优化。

## 核心特性 (v1.3.1)

- **艺术级 CRT 引擎 (v3.1)**：平衡的屏幕弧度、扫描线，以及支持 **动态陀螺仪光泽**（物理反光效果）。
- **顶级触感反馈**：利用 Android `VibrationEffect` 接口实现细腻的触感（Tick/Pop/Shock）。
- **沉浸式音频**：支持立体声平移、动态混响，以及 **暂停 LPF 滤镜**（暂停时 BGM 自动变闷）。
- **确定性回放系统**：通过逻辑帧同步和采样随机数种子，实现 100% 精确的高分过程复现。
- **仪式感开机**：经典的 GameBoy 式动画开机序列和硬件上电视觉效果。
- **可脚本化关卡**：使用 JavaScript 即可创建包含移动障碍物的动态地图。
- **Roguelite 增益**：提供幽灵模式、减速、磁铁等多种特殊果子，伴有视觉半透明特效。
- **成就陈列室**：持久化勋章系统，包含完整的展示柜和解锁提示。
- **Android 深度优化**：针对 arm64-v8a 单架构优化，启用 LTO、MinSizeRel 指令和符号剥离，极小安装包体积。

## 技术栈

- **语言**: C++23 (std::ranges, unique_ptr, 异步就绪)
- **框架**: Qt 6.7+ (Quick, JSEngine, Multimedia, Sensors, ShaderTools)
- **构建系统**: CMake + Ninja

## 快速开始

### 编译并运行 (桌面端)
```bash
mkdir build && cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release ..
ninja
./SnakeGB
```

## 操作控制
- **方向键**: 移动蛇身
- **START (Enter / S)**: 开始游戏 / 从存档继续
- **SELECT (Shift)**: 切换关卡 / (长按) 删除存档
- **UP**: 打开勋章馆
- **DOWN**: 观看最高分录像回放
- **B / X**: 返回 / 切换屏幕调色盘
- **Y / C / 点击 Logo**: 切换掌机外壳颜色
- **M**: 开关音乐 | **Esc**: 退出应用

## 授权
本项目采用 [GNU GPL v3](LICENSE) 协议授权。
