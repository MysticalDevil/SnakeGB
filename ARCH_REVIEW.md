# SnakeGB 架构审查与解耦建议报告 (v1.3.1)

本报告基于 `clang-tidy` 静态扫描构思及对 C++23 代码库的深度分析，评估了项目的工程质量与模块耦合度。

## 🔍 1. 架构耦合度诊断 (Coupling Analysis)

### 🚨 A. "上帝对象" 风险 (The God Object Property)
**位置**：`GameLogic` 类 (`src/game_logic.h`)
- **问题**：`GameLogic` 目前承担了游戏引擎、资源管理器（音效/调色盘）、存档系统、成就跟踪、甚至硬件传感器桥接的多重职责。
- **后果**：违反了单职责原则 (SRP)。修改音效逻辑或增加成就类型时，必须重新编译核心游戏逻辑，增加了回归风险。

### 🚨 B. FSM 双向耦合 (Circular State Dependency)
**位置**：`GameState` 与 `GameLogic` 的交互 (`src/fsm/states.cpp`)
- **问题**：`PlayingState` 等状态类通过 `m_context` 引用直接读写 `GameLogic` 的私有成员。
- **后果**：形成了强依赖循环。状态机无法在脱离 `GameLogic` 实现的情况下进行单元测试，代码复用性差。

### 🚨 C. 音频子系统的被动性
**位置**：`GameLogic` 主动调用 `m_soundManager`。
- **问题**：音频模块应该是“反应式”的。目前 `GameLogic` 必须维护一个 `SoundManager` 的句柄并了解其所有接口。

## 🛠️ 2. 改进路线图 (Refactoring Roadmap)

### ✅ 第一阶段：反应式音频 (Reactive Audio)
- **目标**：彻底解除 `GameLogic` 对 `SoundManager` 的包含依赖。
- **方案**：
  - `SoundManager` 订阅 `GameLogic` 的信号（如 `foodEaten`, `playerDied`）。
  - `GameLogic` 移除所有 `m_soundManager->playXXX()` 调用。
  - **收益**：音频系统的增删不再影响游戏核心。

### ✅ 第二阶段：元数据分离 (Profile Separation)
- **目标**：将持久化数据从运行逻辑中剥离。
- **方案**：
  - 提取 `ProfileManager` 类，专门负责 `QSettings` 读写、成就持久化和玩家偏好。
  - `GameLogic` 只向 `ProfileManager` 请求当前配置。

### ✅ 第三阶段：接口化状态机 (Interface-based FSM)
- **目标**：实现“黑盒”状态切换。
- **方案**：
  - 定义 `GameEngineInterface` 虚基类，仅暴露 `moveHead()`, `spawnFood()` 等受控操作。
  - `GameState` 仅持有接口引用，不再能访问 `GameLogic` 的原始私有成员。

## 📈 3. 代码质量总结 (Static Analysis Observation)

- **C++23 表现**：完美应用了 `std::ranges`, `std::unique_ptr` 和 `trailing return types`，符合现代工程审美。
- **QML 兼容性**：100% 遵守了 Qt 6 零分号规范，彻底解决了 Android 加载组件失败的历史隐患。
- **健壮性**：`QRandomGenerator` 的实例管理和 `QStandardPaths` 的跨平台路径处理已经达到了发布级标准。

---
*注：本报告旨在为后续从“个人项目”向“大型可扩展框架”演进提供指导。*
