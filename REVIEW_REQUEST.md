# REVIEW_REQUEST — SB-006 首页目标看板

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-006-dashboard`（未merge、未push、无remote，合规）
任务卡：`docs/tasks/SB-006.md`
commit 待发：`feat(dashboard): 首页目标看板四区+聚合统计 [SB-006]`（3 源码含 home_page 1 处看板挂接编辑 + 3 测试 + 4 golden 基线图，共 10 文件；单文件 ≤278 行）

验收对照（任务卡 5 项）：
1. 首页四区：Hero 余额/支出主卡、今日笔数金额、类目分布 Top5、目标进度条（未设显示引导位） —— ✓ `ui/dashboard_cards.dart`（DashboardHero/TodayCard/Top5Card/GoalCard）+ `ui/home_page.dart` 挂接四区（原记录列表保留，SB-004 回归键 homeTotal/emptyHint 保留）。
2. 聚合来自 SB-004 存储；"其他"占比显式展示（>5% 故障提示样式） —— ✓ `logic/dashboard_stats.dart`（computeDashboard：今日自然日/滚动7天/自然月/Top5/旧名归一，故障口径复用 SB-005 CategorySummary）；Hero 显 `dashOtherShare` + `dashOtherFault/dashOtherHealthy`（故障态用暖金一处，健康态副文案）。
3. 冷启动到看板渲染 <1s（合成 1 万条） —— ✓ 单测 `1 万条聚合 <1s` 实测通过（纯 Dart 聚合，Stopwatch 断言 lessThan(1000)）；UI 层 StreamBuilder 直出无额外帧。
4. golden 四组：看板 Light/Dark × 空态/有数据 —— ✓ `test/golden_dashboard_test.dart` 4 组，基线 `golden/sb006/dashboard_{light,dark}_{data,empty}.png` 新建并比对通过；对比度闸门绿。
5. 四闸门全绿 + hygiene OK —— ✓ `tool/ci.sh`（format/analyze/test-smoke/build macOS+APK，ALL GREEN）+ `check-repo-hygiene.sh` OK；全量 `flutter test` 59/59 绿（含 SB-004/005 回归）；无依赖变更（pubspec 0 改动）、无 schema 变更（只读 watchAll，内存聚合）、无 docs 规范改动。

验证：
- `flutter analyze --fatal-infos --fatal-warnings app`：No issues
- 文件约束：10 文件（lib 新 2：dashboard_stats 167 行/dashboard_cards 278 行；lib 改 1：home_page 185 行；test 新 3；golden png 4），无依赖变更、无 schema 变更、无 docs 规范改动

偏差声明（请监工知悉）：
- D1：目标值未持久化（无 schema 变更授权，卡未要求存目标）：computeDashboard 支持 goalFen 入参，HomePage 当前传 null → 显示引导位（dashGoalEmpty）；目标设定/存储待后续卡（G3 钩子层）。
- D2：本周口径为滚动 7 天（含今），非自然周；如需自然周请打回，我改卡口径。
- D3：Top5 条形为 Container 比例条（复用现有能力，无图表新库，符合卡"禁图表新库"）；CustomPainter 精细图表待 G5 打磨。
- T1：widget/golden 页测沿用 SB-004/005 实测结论（watch 流 unmount 零时长 Timer → `_unmountAndFlush`，不调 `db.close`）。

请审计后结论写 `REVIEW.md`（PASS 或 REQUEST_CHANGES，本卡第 1 轮/上限 3 轮）。
