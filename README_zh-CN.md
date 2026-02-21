# SnakeGB - 复古 GameBoy 风格贪吃蛇 (v1.4.0)

[English](README.md)

SnakeGB 是一款基于 **Qt 6** 和 **C++23** 构建的高质量、跨平台 GameBoy 风格贪吃蛇游戏。它以现代工程标准忠实还原了经典复古掌机的操作体验，并提供触觉与音频反馈。

## 核心特性 (v1.4.0)

- **GB 风格开机链路**：Logo 下落弹跳、开机提示音、进入主界面后延迟播放 BGM。
- **主界面导航扩展**：隐藏图鉴（`LEFT`）、成就页（`UP`）、高分回放（`DOWN`）、`SELECT` 切关。
- **按键行为修复**：`B` 在不同状态下恢复正确语义（游戏内切配色、菜单退出、页面回退等）。
- **动态关卡扩展**：`Classic`、`The Cage`、`Dynamic Pulse`、`Tunnel Run`、`Crossfire`、`Shifting Box`。
- **Roguelike 特殊果实**：9 种能力全部区分，`Magnet` 已实现吸引果实效果，`Portal` 改为穿越障碍墙。
- **幽灵回放**：记录输入与能力选择历史，稳定回放最高分过程。
- **移动端陀螺仪光泽**：基于 `QtSensors` 的屏幕反光偏移（桌面端有回退动画）。
- **Android 运行链路**：完善 arm64 构建部署与 logcat 崩溃排查流程。

## 玩法说明

- **核心循环**：吃果实、变长、提速，在不断增压下存活更久并冲击高分。
- **穿屏规则**：蛇头越过边界会从对侧出现（关卡障碍仍可造成碰撞风险）。
- **关卡差异**：
  - `Classic`：纯净无障碍基础模式。
  - `The Cage`：静态障碍布局。
  - `Dynamic Pulse` / `Crossfire` / `Shifting Box`：脚本驱动动态障碍。
  - `Tunnel Run`：双柱隧道压迫地形。
- **Roguelike 选择**：分数推进过程中会触发能力三选一，每局成长路径不同。
- **特殊果实系统**：9 种能力包含瞬时与持续效果，影响得分、碰撞与机动性。
- **幽灵回放**：回放最高分运行轨迹（输入+能力选择），便于复盘与练习路线。

## 技术栈

- **语言**: C++23 (std::ranges, unique_ptr, 异步就绪)
- **框架**: Qt 6.7+ (Quick, JSEngine, Multimedia, Sensors, ShaderTools)
- **构建系统**: CMake + Ninja

## 快速开始

### 编译并运行 (桌面端)
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

- `Debug`: 保留完整运行日志。
- `Release` / `MinSizeRel` / `RelWithDebInfo`: 编译期关闭 `qDebug/qInfo/qWarning` 日志（桌面端与 Android 一致）。

### Android 构建与部署
```bash
# Debug 构建（有日志）
CMAKE_BUILD_TYPE=Debug ./scripts/android_deploy.sh

# Release 构建（无日志）
CMAKE_BUILD_TYPE=Release ./scripts/android_deploy.sh
```

## 操作控制
- **方向键**: 移动蛇身
- **START (Enter / S)**: 开始游戏 / 从存档继续
- **SELECT (Shift)**: 切换关卡 / (长按) 删除存档
- **UP**: 打开勋章馆
- **DOWN**: 观看最高分录像回放
- **LEFT**: 打开隐藏果实图鉴
- **B / X**:
  - 游戏中 / Roguelike 选择：切换屏幕配色
  - 主界面：切换屏幕配色
  - 暂停 / GameOver / 回放 / 图鉴 / 成就：返回主界面
- **Y / C / 点击 Logo**: 切换掌机外壳颜色
- **M**: 开关音乐
- **Back / Esc**: 退出应用

## 输入架构说明
- 按键语义统一与迁移方案：`docs/INPUT_SEMANTICS.md`
- 运行时自动化注入：建议使用 `SNAKEGB_INPUT_FILE=/tmp/snakegb-input.queue`（或 `SNAKEGB_INPUT_PIPE=/tmp/snakegb-input.pipe`），并用 `scripts/inject_input.sh` 发送按键 token

## 授权
本项目采用 [GNU GPL v3](LICENSE) 协议授权。
