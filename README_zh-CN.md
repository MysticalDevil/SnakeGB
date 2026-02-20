# SnakeGB - 复古 GameBoy 风格贪吃蛇 (v1.4.0)

[English](README.md)

SnakeGB 是一款基于 **Qt 6** 和 **C++23** 构建的高质量、跨平台 GameBoy 风格贪吃蛇游戏。它以现代工程标准忠实还原了经典复古掌机的操作体验，并提供顶级的触觉与音频反馈。

> **注**：本项目完全由 **Gemini CLI** (AI Agent) 生成并持续优化。

## 核心特性 (v1.4.0)

- **GB 风格开机链路**：Logo 下落弹跳、开机提示音、进入主界面后延迟播放 BGM。
- **主界面导航扩展**：隐藏图鉴（`LEFT`）、成就页（`UP`）、高分回放（`DOWN`）、`SELECT` 切关。
- **按键行为修复**：`B` 在不同状态下恢复正确语义（游戏内切配色、菜单退出、页面回退等）。
- **动态关卡扩展**：`Classic`、`The Cage`、`Dynamic Pulse`、`Tunnel Run`、`Crossfire`、`Shifting Box`。
- **Roguelike 特殊果实**：9 种能力全部区分，`Magnet` 已实现吸引果实效果，`Portal` 改为穿越障碍墙。
- **幽灵回放**：记录输入与能力选择历史，稳定回放最高分过程。
- **移动端陀螺仪光泽**：基于 `QtSensors` 的屏幕反光偏移（桌面端有回退动画）。
- **Android 运行链路**：完善 arm64 构建部署与 logcat 崩溃排查流程。

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
- **LEFT**: 打开隐藏果实图鉴
- **B / X**:
  - 游戏中：切换屏幕配色
  - 主界面：退出应用
  - 暂停 / GameOver / 回放 / 图鉴 / 成就：返回主界面
  - Roguelike 选择界面：切换屏幕配色
- **Y / C / 点击 Logo**: 切换掌机外壳颜色
- **M**: 开关音乐 | **Esc**: 退出应用

## 授权
本项目采用 [GNU GPL v3](LICENSE) 协议授权。
