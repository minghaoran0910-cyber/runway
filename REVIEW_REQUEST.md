# REVIEW_REQUEST — SB-012 打磨冻结首轮（验收7 接线＋perf 脚本＋CHANGELOG＋golden）

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-012-g5-freeze`（未 merge、未 push、无 remote，合规）
任务卡：`docs/tasks/SB-012.md`（前置 SB-014~020＋SB-022 均已合入，main@c581f7d＋冒烟回填闭环；SB-021 已摘出 v0.2 不在前置）
基座：`main@4cac480`（零差异起步，`git checkout -b` 直切）
提交：`829c1d7 feat(home)`（1 lib 改＋2 test 新＋1 sh 新＋1 基线 txt＋CHANGELOG 新＋golden 6 图）

施工改动（业务文件 5≤10，单文件最大 237 行；golden png／CHANGELOG 按 DEV §2.2 不计）：
- `app/lib/ui/home_page.dart`（改，+5 行）：import budget_card＋实验区之后插入 `BudgetZone(db, rows)`（验收7；周报页 `BudgetZone` 保留，双宿主，`suggestBudget`／弹性过滤／禁词／换算零触碰）。
- `app/test/golden_home_budget_test.dart`（新）：首页含预算区 widget（滚到 budgetTitle，标题/基线/进度三键）＋sb012 首页预算区 golden Light/Dark。
- `app/test/perf_budget_test.dart`（新）：合成 1 万条聚合 <1.5s＋"其他"占比 <5%（2% 数据集，SB-005 口径复用）。
- `tool/perf_check.sh`（新，卡内授权，＋x）：perf 单测＋debug 包体 vs 基线＋20%＋`--release` 预估口径；`tool/perf_baseline.txt`＝173631103B（本轮新建）。
- `CHANGELOG.md`（新，Keep-a-Changelog）：G1→SB-022 全补＋已知偏差节（含 SB-022 G1/G2 灰区默认接受、SB-021 摘出 v0.2）。
- `golden/sb006/` 四图重生成（首页同区连带，SB-017/018 先例口径）＋`golden/sb012/` 两图新建。

验收对照（卡 SB-012）：
1. 六类动效走查：未做（监工真机执行，双端，超出 builder 权限）——待监工。
2. 性能预算：CI 可测部分全绿（聚合实测 <1s／上限 1.5s；其他占比合成 2%<5%；debug 包体基线已建 173631103B）；冷启动真机＋滚动 trace（`golden/perf/`）＋release 预估（`--release`）——待监工真机轮。
3. "其他"占比 <5%：单测锁（合成集）✓；生产数据无，全量合成 fixtures。
4. golden 全量：除下述既有红外全绿；`tool/ci.sh` ALL GREEN（format／analyze／smoke／双构建 ✓Built）。
5. CHANGELOG ✓已补；tag v0.1.0 未打（须验收9 先过，监工执行）。
6. 隐藏入口清算（代码实证，供走查清单）：`grep LongPress app/lib`＝0——SB-006 Hero（`DashboardHero`）无任何手势，SB-007 系**可见点击**入口（`GestureDetector onTap→GoalPage`，home_page 162 行），所谓"长按"两条在现代码中不存在；目标卡已设态无文字提示，建议走查定夺是否补一行可发现性文案（不阻塞本轮，v0.1.0 前可一并销项）。
7. 预算卡上首页 ✓（口径零改，仅换宿主；widget＋golden 双锁；周报页回归绿）。
8. 多平台三端：未做（iOS 模拟器＋Mac 原生＋Android 由监工三端冒烟；Windows 环境不允许记 CHANGELOG 不阻塞——本轮未记，监工轮定）。
9. 真人体验 7 天：未启动（浩然本人＋后验 tag，天然跨轮；本轮仅把代码闸门做到绿）。

测试：`flutter test` 全量 **413/414**（409 继承＋新增 5：home widget1＋golden2＋perf2；实测约 15s）；`dart format` 0 改动；`flutter analyze` No issues；`tool/ci.sh` ALL GREEN＋`hygiene` OK；`tool/perf_check.sh` PERF GREEN。

偏差声明：①双宿主而非迁宿主——周报页 `BudgetZone` 保留（迁走会破 SB-015 golden／验收），卡文"仅换宿主位"按"复用同一 Zone 零改口径"执行，监工可一票否决改迁走。②全量唯一红 `golden_grain_test·SB-014 周报页 light 有数`（6.57% diff）**非本轮损伤**：diff 文件全在 weekly／grain 侧，本轮 diff 仅 home（`git diff --stat` 实证零交集）；种子 `weekStartFor(now)` 跨周一（10-11 周日→10-12 周一）日期腐坏，SB-022 23:5x 轮 409 全绿即跨周前；基线未碰，留监工定夺（重生成或定时钟种子）。③release 包体／真机三数留监工轮（脚本 `--release` 已备）。

文件约束：业务 5 文件（1 改＋4 新）≤10；单文件最大 237≤400；无 pubspec；无 remote；真实账目＝0；新 UI 零裸 Duration（复用 Zone 无动画）；禁词产品文案零新增（新增文案仅 CHANGELOG／注释）；_LOCK 本轮退场即删。

状态：待审查（2026-10-12 00:2x builder 提审·SB-012 首轮；feat 分支未合入）
