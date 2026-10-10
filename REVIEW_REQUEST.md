# REVIEW_REQUEST — SB-015 预算线（自动给，一键改）

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-015-budget`（未 merge、未 push、无 remote，合规）
任务卡：`docs/tasks/SB-015.md`（SB-011 之后开工，前置已满足）
基座：`main@771daeb`（SB-014 结案后）
提交：`37e7fa1 feat(budget): SB-015 预算线自动给一键改 [SB-015]`

改动清单（业务 9 文件 ≤10，手写单文件最大 396 行 ≤400；golden png 不计）：
- `app/lib/logic/budget.dart`（新建，224 行）：suggestBudget 纯函数（同月>中位数>观察期）+ median3/applyTighten/validateTighten/validateBudgetFen + computeBudgetSaved（与 SB-007 同构，基线换预算）+ computeBudgetWeekly（周折算×7/30+环比增量）+ 得到框架文案（budgetTitle/Body/Hint/BasisText）；224 行
- `app/lib/data/budget_store.dart`（新建）：Budgets 表（monthKey/budgetFen/basisFen/tightenPct/basis/createdAt；同 key 多行即历史）
- `app/lib/data/budget_dao.dart`（新建）：currentBudget/listBudgetHistory/watchBudgetHistory/upsertBudget（改即插新行）+ rollbackBudgetsToV6
- `app/lib/data/app_db.dart`（改，396 行）：Budgets 入表 + schemaVersion 6→7 + onUpgrade from<7 建表；注释压缩让行（零语义改动）
- `app/lib/data/app_db.g.dart`（改）：build_runner 重生成（含 budgets 53 处）
- `app/lib/ui/budget_card.dart`（新建，336 行）：BudgetCard（观察/生效+进度条复用余粮视觉语言）+ BudgetEditDialog（金额空=自动建议，收紧 0–15）+ editBudget（手动/自动两路一律插新行留历史）+ BudgetZone（transactions 推导三月+去年同月，接 budgets 表）
- `app/lib/ui/weekly_page.dart`（改）：周报卡内相对预算省出行（无预算零高度旧像素不动）+ 历史之后接 BudgetZone；_monthSpendOf/_lastMonthSpendOf helpers
- `app/test/budget_test.dart`（新建，31 条）：基线三要素 7 + 优先级/观察期 4 + 省出口径 10 + 周增量 3 + 文案 4（含全量零禁词断言）+ DAO 历史 3（含 v7 回滚）
- `app/test/golden_budget_test.dart`（新建，9 条）：widget 3（生效/观察/周报集成滚动）+ golden 4（sb015 观察/生效×Light/Dark）+ 动效零裸量 + 对比度闸门
- golden（不计文件数）：新建 `golden/sb015/` 四图；重生成 `golden/sb007/` 零动（GoalPage 未碰）；重生成 `golden/sb014/weekly_light_data + weekly_dark_empty` 两图（底部预算区连带，上方周报区像素不动）

验收对照（SB-015 卡 §验收 1~5）：
1. 基线三要素：median3 单测（100/200/10000→200）；同月优先单测（500000 在即忽略中位数）；默认收紧 5%（10000→9500）+0–15 可调（越界钳制单测）；对话框收紧输入框可调
2. 取数优先级纯函数 suggestBudget + 单测（同月>中位数>观察期）；dataMonths<3 即观察期（budgetFen=0，零编造单测）；全零月份仍观察期
3. 预算可改有历史：upsert 即插新行，current 取最新、history 倒序（DAO 单测）；改后 computeBudgetSaved 换基线即重算（单测 6 改后即时重算）；对话框空金额=按建议口径自动落库
4. 省出口径 10 条：月光满省/持平零/超支非负/超预算环比保留/正常 200+100/改后重算/首月/观察期/反超/大额不截断；周增量 3 条（折算/省出与非负/delta 可负）；文案仅得到框架（全量零禁词断言，测试名含口径词属断言非用户可见，沿 SB-014 先例）
5. `tool/ci.sh` ALL GREEN（format 零改动/analyze No issues/全量 227/227/macos+apk 双构建成功）+ `tool/check-repo-hygiene.sh` OK；`dart format` 0 改动

文件约束：业务 9 文件 ≤10；单文件最大 396 行（app_db.dart）；无 pubspec 变更；无 remote；测试全合成 fixtures，真实账目=0；探针零使用（未写 /tmp，未建 probe 文件，调试用临时文件已删）。

偏差声明：
1. 卡注 schema v5 系过期编号（写卡时基座 v4）：实际 v6→v7 落地，迁移+回滚语义与卡要求一致；属编号过期非口径变更。
2. 预算同区置于周报页历史之后（未置首页/目标区）：GoalPage 加任意高度会触发 SB-007 CRUD 旧用例 scrollUntilVisible(500) 打到 maxScrollExtent 顶出视口（实测偏移 212→420 复现定位）；置底后旧 widget 断言零影响，sb007 基线零漂移。首页接线随 SB-016 每日反馈布局时一并评估。
3. CHANGELOG.md 本仓从未建立（SB-013/014 既有结论），本卡未新建，待 SB-012 统一补。

请审计后结论写 `REVIEW.md`（PASS 或 REQUEST_CHANGES）。
