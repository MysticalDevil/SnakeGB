# SnakeGB Architecture Review (v1.4.0)

本报告基于当前代码（`main` 分支，v1.4.0）对项目架构目标达成度进行复核，并给出下一阶段可执行优化方案。

## 1. Target Fulfillment

### 1.1 God Object 风险（GameLogic 过载）
状态：已达成（阶段目标）

现状：
- `GameLogic` 仍是核心协调者，但已将音频实现控制权外移到应用层装配（`main.cpp`），逻辑层仅发领域事件。
- 对比早期版本，`ProfileManager`、`SoundManager`、FSM 已拆出，核心职责已收敛到“规则协调 + 状态驱动 + QML API”。

结论：
- 针对本阶段 ARCH_REVIEW 第一部分目标，已完成关键拆分；后续可继续细化为 `BuffSystem/LevelRuntime`。

### 1.2 FSM 解耦目标（Interface-based FSM）
状态：已达成（核心目标）

现状：
- 已有 `IGameEngine` 接口，状态类不直接依赖 `GameLogic` 具体实现中的大部分细节。
- `states.cpp` 的行为由接口驱动，状态切换和输入处理基本符合黑盒状态机思路。
- `GameState` 基类上下文已从 `GameLogic&` 切换为 `IGameEngine&`，完成类型层解耦。

剩余问题：
- 接口仍暴露大量可变引用（如 `direction()`, `inputQueue()`），封装性一般。

结论：
- 核心目标已闭环，下一步应聚焦接口收口（命令式 API 替代可变容器暴露）。

### 1.3 音频系统反应式（Reactive Audio）
状态：已达成（核心目标）

现状：
- 主要音效触发通过 signal/slot 机制已建立（`foodEaten`, `playerCrashed`, `uiInteractTriggered`）。
- `GameLogic` 不再持有 `SoundManager`，仅发送音频事件（`audioPlayBeep/audioStartMusic/audioSetPaused` 等）。
- 音频策略与具体播放器连接在 `main.cpp` 完成，实现逻辑层与设备/播放器层解耦。

结论：
- 已实现反应式音频链路，后续只需在事件域模型上继续细分语义。

### 1.4 数据与持久化分离（Profile Separation）
状态：已达成（主要目标）

现状：
- `ProfileManager` 独立管理 `QSettings`、进度、配置、统计、会话存档。
- `GameLogic` 通过 manager 读写而非直接操作 `QSettings`。

结论：
- 目标达成，结构健康。

## 2. Architecture Scorecard

- 模块边界清晰度：7/10
- 状态机可替换性：8/10
- 可测试性：7/10
- QML 与逻辑分层：6/10
- 演进弹性（新关卡/新 buff 扩展）：7/10

总体：`7.0/10`（已过“可维护”线，未到“高扩展框架”）

## 3. Key Risks Remaining

1. `GameLogic` API 表面积过大
- QML 可调用方法和状态字段多，回归面大。

2. FSM 接口粒度偏粗
- 暴露可变容器引用，状态层容易绕过业务约束。

3. Buff 机制扩展成本高
- buff 效果散落在多个函数分支中（碰撞/移动/计时/得分），新增效果需要多点修改。

4. 资源与回退路径耦合
- 关卡脚本、JSON 资源、C++ fallback 并存，长期维护需要统一优先级与校验策略。

## 4. Optimization Plan (Next)

### P1（建议立即执行）
状态（2026-02-20）：已完成

1. 将 `GameState` 上下文类型改为 `IGameEngine&`
标记：已完成
- 从类型层切断对 `GameLogic` 的直接依赖。
- 影响文件：`src/fsm/game_state.h`, `src/fsm/states.h/.cpp`, `src/game_logic.cpp`.

2. 收口 `IGameEngine` 可变引用接口
标记：已完成
- 用命令式方法替代容器直接暴露（如 `enqueueInput`, `consumeNextInput`, `recordInputFrame`）。
- 降低状态层越权风险。
- 已将状态层对 `direction()/inputQueue()/history` 的可变引用访问替换为命令式接口（消费输入、设置方向、按帧读取回放数据）。

3. 为关键规则补测试矩阵
标记：已完成（基线矩阵）
- 边界穿越、动态障碍脚本/回退、Buff 冲突组合、回放一致性。
- 已补齐上述关键规则的自动化基线测试；后续可继续扩展到更细粒度分模块用例。

### P2（中期）

1. 提取 `BuffSystem`
- 集中管理 buff 生命周期、效果应用点、冲突策略。
- 目标：删除 `GameLogic` 中分散的 `if (m_activeBuff == X)`。

2. 提取 `LevelRuntime`
- 统一处理 JSON level、脚本执行、fallback level。
- 提供单一接口给 `GameLogic`：`loadLevel(index)`, `updateObstacles(tick)`.

3. 音频完全反应式
- `GameLogic` 只发领域事件，不直接控制 `SoundManager` 实例。
- 由独立协调层连接状态变化和音频策略。

### P3（长期）

1. Headless Core
- 将纯逻辑核心抽离为无 QtQuick 依赖模块，用于:
  - 高速回放验证
  - AI 训练接口
  - 服务器侧防作弊复算

2. QML ViewModel 层
- 减少 QML 直接依赖 `GameLogic` 原始属性，降低 UI 改动回归风险。

## 5. Conclusion

相对 ARCH_REVIEW 初版目标，项目在 v1.4.0 已完成关键架构升级：
- FSM 接口化路径成立
- 持久化分离完成
- 音频反应式链路落地（逻辑层不再持有 SoundManager）

未完全达成的核心项是：
- `GameLogic` 仍偏重
- 接口封装粒度仍可收紧

建议按本报告 P1 -> P2 顺序推进。完成 P1 后，架构可稳定进入 `8/10` 可维护水平，并为后续功能增长（更多关卡/更多 buff/联网）提供更低风险的演进路径。

## 6. Next Initiative: GameLogic Core/Adapter Decoupling

目标日期：2026-02-21 起（新阶段）

### 6.1 Goal

将当前 `GameLogic` 拆分为两层：

1. `core`（纯规则核心）
- 负责状态推进、碰撞、得分、buff、关卡运行时、回放一致性。
- 不依赖 QML，不直接依赖 UI 交互语义。
- 尽量缩小 Qt 依赖（长期目标：可 headless）。

2. `adapter`（边界适配层）
- 负责 QML 暴露属性/信号、输入映射、资源装配、持久化对接。
- 将 UI/平台事件转换为 core 命令，再把 core 状态转换为 QML 可消费数据。

### 6.2 Non-goals (This Stage)

- 不重写现有玩法规则（snake 移动、buff 效果、关卡机制保持行为一致）。
- 不变更 UI 样式和交互视觉。
- 不在本阶段引入网络/多线程仿真。

### 6.3 Suggested Module Split

建议目录（可按编译条件微调）：
- `src/core/`
  - `game_session_core.*`
  - `state_snapshot.*`
  - `rules/`（collision, scoring, buff, replay）
- `src/adapter/`
  - `qml_game_adapter.*`（当前 `GameLogic` 的 QML-facing 职责迁移处）
  - `input_router_adapter.*`
  - `profile_adapter.*`（对 `ProfileManager` 的边界收口）

### 6.4 Refactor Phases

Phase A（结构落位）：
- 定义 `core` 的最小命令接口与状态快照接口。
- 在不改行为前提下，将“规则推进主循环”从 `GameLogic` 移到 `core`。

Phase B（适配分离）：
- `GameLogic` 改名/收敛为 adapter（或新增 adapter 并让 `GameLogic` 退役）。
- QML 只与 adapter 交互；adapter 不再直接持有分散规则分支。

Phase C（测试与稳定）：
- 新增 core 层单测（headless）。
- 保留并扩展现有 Wayland 输入语义矩阵，确保外部行为不回归。

### 6.5 Acceptance Criteria

满足以下条件视为完成：
- `GameLogic`（或其替代 adapter）不再包含核心规则实现细节（仅编排/映射）。
- 规则核心可在无 QML 环境下执行一局完整仿真（含 replay）。
- 现有输入语义矩阵、关键玩法回归用例全部通过。
- 对外 QML API 兼容（至少兼容主菜单/游戏/暂停/图鉴/成就/彩蛋路径）。

### 6.6 Risks and Mitigation

主要风险：
- 拆分期间信号时序变化导致 UI 状态抖动。
- 存档与回放数据结构迁移导致兼容性问题。

缓解策略：
- 每个 phase 进行原子提交，保证可回滚。
- 先“搬运不改逻辑”，后“清理重构”，避免一步到位大爆炸改动。
- 在每个 phase 末执行：编译 + 输入矩阵 + 关键场景手测。
