# SnakeGB - 复古 GameBoy 风格贪吃蛇游戏 (v1.3.0)

[English Version](README.md)

SnakeGB 是一款基于 **Qt 6** 和 **C++23** 构建的高品质、跨平台仿 GameBoy 贪吃蛇游戏。本项目在追求工业级工程标准的同时，忠实还原了经典复古掌机的视听体验，并引入了可脚本化的动态关卡机制。

> **注意**：本项目的所有代码、资源配置及文档均由 **Gemini CLI** (AI Agent) 自动生成并迭代优化。

## 核心特性 (v1.3.0)

- **艺术级 CRT 引擎 (v3.1)**：平衡的物理球面畸变、色差边缘以及动态扫描线。
- **物理残影效果**：高度仿真的 LCD 像素延迟（Motion Ghosting）模拟。
- **动态音乐合成**：BGM 播放速度随分数增加自动提速，增强游戏紧迫感。
- **动态脚本关卡**：支持使用 JavaScript 编写具有移动障碍物的动态地图。
- **Roguelite 随机元素**：随机生成的特殊果实，提供穿墙、减速、磁吸 Buff。
- **成就勋章系统**：持久化的勋章陈列室，支持查看解锁进度与提示。
- **全量比赛回放**：基于确定性随机种子的最高分操作序列重放。
- **多平台原生支持**：适配 Windows, Linux, macOS, Android (`org.devil`) 及 WASM 网页端。

## 进阶：编写脚本关卡

您可以自定义动态关卡。只需在 `src/levels/levels.json` 中为关卡添加 `script` 字段，示例如下：

```javascript
// onTick 在游戏每一帧被调用
// 返回一个包含障碍物坐标 {x, y} 的数组
function onTick(tick) {
    // 示例：创建一个左右移动的垂直墙壁
    var x = Math.floor(Math.abs(Math.sin(tick * 0.1) * 15));
    return [
        {x: x, y: 5},
        {x: x, y: 6},
        {x: x, y: 7}
    ];
}
```

## 技术栈

- **语言**：C++23
- **框架**：Qt 6.5+ (Quick, JSEngine, Multimedia, ShaderTools)
- **构建系统**：CMake + Ninja

## 快速开始

### 编译运行
```bash
mkdir build && cd build
cmake -G Ninja ..
ninja
./gameboy-snack
```

### Android 编译与部署（环境变量方式）
仓库内提供了 `scripts/android_deploy.sh`，通过环境变量配置路径（使用时无需在命令里硬编码本地目录）。

必需：
```bash
export QT_ANDROID_PREFIX="$HOME/dev/build-qt-android/build-android-arm64/qt-android-install"
```

推荐：
```bash
export QT_HOST_PATH="$HOME/dev/build-qt-android/build-android-arm64/qtbase"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
export ANDROID_NDK_ROOT="$HOME/Android/Sdk/ndk/29.0.14206865"
export JAVA_HOME="/opt/openjdk-bin-21"
```

执行：
```bash
./scripts/android_deploy.sh
```

常用可选变量：
- `BUILD_DIR`（默认：`build-android-local`）
- `ANDROID_ABI`（默认：`arm64-v8a`）
- `ANDROID_PLATFORM`（默认：`28`）
- `INSTALL_TO_DEVICE=0`（仅构建/签名，不安装）
- `LAUNCH_AFTER_INSTALL=0`（仅安装，不自动启动）

## 操控说明
- **方向键**：控制蛇移动
- **START (Enter / S)**：开始游戏 / 继续进度
- **SELECT (Shift)**：在菜单中切换关卡
- **UP (方向键上)**：打开勋章陈列室
- **DOWN (方向键下)**：观看最高分回放
- **长按 SELECT (Shift)**：在菜单中清除存档
- **B / X**：返回 / 退出 / 切换调色盘
- **M**：开启/关闭音乐 | **Esc**: 退出应用
- **Android 触控**：`SND` 按键可切换 BGM（适配无键盘设备）

## 许可证
本项目采用 [GNU GPL v3](LICENSE) 开源协议。
