# REVIEW — 2026-10-10 SB-006（G2）· 第 1 轮 · 卡 SB-006

结论: PASS

检查项:
- [6/6] 独立复验全部通过（监工本机重跑，非采信开发自述）
  - flutter analyze --fatal-infos --fatal-warnings：No issues（1.8s）
  - flutter test 全量：59/59 绿（含 SB-004/005 回归键 homeTotal/emptyHint 未破坏）
  - check-repo-hygiene.sh：OK
  - diff 范围：仅 lib/logic、lib/ui、test、golden 新目录 sb006 + docs 流程文件；pubspec 0 改动（依赖合规）、无 schema 变更（只读 watchAll 内存聚合，符合卡"只加查询不加 schema"授权）
  - 文件数：app 面 10 文件 ≤ 卡上限；单文件最大 dashboard_cards.dart 278 行 ≤ 闸门
  - 真实数据红线：全 diff + 测试扫描无真实账目内容，均为合成数据与"示例数据"标签
- [x] 验收 1 四区：DashboardHero/TodayCard/Top5Card/GoalCard 挂接 home_page，目标未设显示引导位（dashGoalEmpty）✓
- [x] 验收 2 聚合供数：computeDashboard 复用 SB-005 CategorySummary 故障口径，其他占比>5% 暖金故障提示（dashOtherFault）✓；旧名归一 canonicalCategory ✓
- [x] 验收 3 性能：1 万条聚合 <1s 单测通过（Stopwatch 断言）✓
- [x] 验收 4 golden：Light/Dark × 空态/有数据 4 组新基线，测试比对通过，对比度闸门绿 ✓
- [x] 验收 5 四闸门+hygiene：监工复验全绿 ✓

偏差裁决:
1. D1 目标未持久化：接受。卡未授权 schema 变更，引导位行为符合验收 1；GoalCard 已留 goalFen 入参，目标存储归 G3 钩子层排卡时落实。
2. D2 滚动 7 天口径：接受，但 UI 文案"本周"与实际口径有轻微误导。裁决为口径变更，监工直接在本卡审计结论留痕（产品文案 G5 打磨统一为"近7天"或改自然周，届时按规范先改 docs）。不动代码。
3. D3 Top5 Container 比例条：接受，符合卡"禁图表新库/可复用现有能力"。CustomPainter 归 G5。
4. DAO 层未新增查询：接受，watchAll 已覆盖，聚合放 logic 层反而符合"logic 纯 Dart"约束。

问题列表:
（无阻塞问题）

模拟器冒烟: PASS（2026-10-10 15:41，main@bf156ec）——runway_api36 冷启 boot=1（4×3s）；adb install -r app-debug.apk Success；am start -n com.zangou.runway.runway/.MainActivity → ActivityTaskManager Displayed +5s593ms；30s 后 pid=3744 存活；crash 缓冲与主日志 FATAL EXCEPTION=0；模拟器已关闭（emulator/qemu 清理）。

下一步: 按 R5 授权 squash 合入 main → 冒烟 → 回填卡状态行归档。SB-006 完成即 G2 达成；下批待办为 SB-007/SB-008（G3 前置）。
