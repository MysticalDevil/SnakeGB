# SnakeGB 长期演进蓝图 (Roadmap)

## 🎮 冒险与深度 (Adventure Update)
- [ ] **Boss 战机制**
  - 设计特殊的 Boss 关卡（如像素巨蛛），引入血条系统与阶段性攻击模式。
- [ ] **解谜挑战模式 (Puzzle Mode)**
  - 利用现有脚本系统，设定固定身体长度与限时步数限制，完成特定吞噬逻辑。
- [ ] **局外成长系统 (RPG Elements)**
  - 引入苹果货币商店，购买永久性 Buff（如增加初始生命值、减慢最高时速）。

## 🌐 联网与社区 (Online Update)
- [ ] **全球排行榜 (Global Leaderboard)**
  - 对接后端 API，实现分数与 `ghost.dat` 录像的自动化上传。
- [ ] **录像验证防作弊 (Anti-Cheat)**
  - 在服务器端运行 Headless 逻辑重跑录像，验证分数有效性。
- [ ] **每日挑战 (Daily Run)**
  - 全球玩家同步使用每日固定随机种子进行竞赛。

## 🤖 极客与 AI (AI & Tech Experiment)
- [ ] **AI 训练接口 (Gym Interface)**
  - 暴露 Socket 或共享内存接口，支持 PyTorch 等外部框架获取状态并控制输入。
- [ ] **自动化测试机器人**
  - 开发超倍速运行的测试脚本，用于自动验证关卡的可通行性。

## 🛠 创意工坊 (UGC Update)
- [ ] **内置关卡编辑器**
  - 实现可视化拖拽放置墙壁，并内置简易的 JavaScript 脚本编辑器。
- [ ] **关卡分享短码**
  - 将关卡 JSON 压缩为易于分享的 Base64 短码或二维码。

## 💎 细节打磨 (Polish & Hardware)
- [ ] **手柄震动反馈 (Haptics)**
  - 接入 `QtGamepad`，适配撞墙与吃果子时的触感反馈。
- [ ] **跨平台增强适配**
  - 针对 Steam Deck (Deck UI) 及 iOS (Taptic Engine) 进行专项优化。

---
*注：本文件已纳入 Git 仓库，作为后续迭代的指导准则。*
