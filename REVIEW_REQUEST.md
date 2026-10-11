# REVIEW_REQUEST — SB-020 常买价格眼（第 2 轮 · 卡 SB-020 应答第 1 轮 RC）

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-020-price-watch`（未 merge、未 push、无 remote，合规）
任务卡：`docs/tasks/SB-020.md`（排期注 SB-019 之后；SB-019 已合入归档，前置满足）
基座：`main@43ffac9`（第 1 轮 RC 审结后；本轮 feat 侧 merge main 取票，merge commit f23a7c2，progress 冲突已按 union 解）
提交：`6c61952 feat(price)`（r3 业务）+ `f23a7c2 merge main` + `10c6b50 fix(quick-add)`（本轮返工，3 文件）
应答：REVIEW.md「SB-020 第 1 轮 · REQUEST_CHANGES」问题 1（P1 回归：quick_add 存量 2 例 pending timers + 进程挂死；feat 挂 / main 对照绿）

返工改动（3 文件，断言零削弱）：
- `app/lib/ui/quick_add_page.dart`（改，203 行，diff main +47）：PriceHint 外包 `Builder` 先算 `priceKeyFor`——无键（备注空）直接 `SizedBox.shrink`，不建 `StreamBuilder`、不订阅 `watchAll`（空态测试免 pending，生产侧亦省一次订阅）；有键时原逻辑不变（`summarizeAll` 查表→≥3 条现身中性小字，Key priceHint）。
- `app/test/quick_add_test.dart`（改，112 行）：遵循全仓统一口径（见 widget_test.dart 头注）——去 `addTearDown(db.close)`（watch 订阅后 close 会挂起），加 `_unmountAndFlush`（unmount + 100ms×2 排干 drift 零时长 Timer），3 例测末调用；全部断言原文不动。
- `app/test/golden_quick_add_test.dart`（改，81 行）：同口径——去 `db.close`，加 `unmountAndFlush`，light/dark 例末调用；golden 基线未动。

验收对照（SB-020 卡 §验收 1~5）：
1. ≥3 条出均价/最低/最近与走势，<3 不显示不猜：`summarizePrices` length<3→null + PriceZone 空即零高度 + golden_price「无历史零高度」test 双锁；本轮未动。
2. 商户/关键词任一不同即不合并：`priceKeyFor` 精确匹配 + price_watch_test 假阳性用例；本轮未动。
3. 「较均价 ±X」只陈述无说教：`describeVsAvg` + 禁词 grep=0；本轮未动。
4. 目标单价联动：跟随=中位数（goalFollowFetch 回填 28）+ 手改优先（resolveGoalPrice）+ 换算引擎零改动；本轮未动。
5. 单测≥10 + golden 两组 + 四闸门全绿 + hygiene OK + **RC 硬标准**：price_watch 13 + golden_price 7 = 20 新例全绿（禁重开遵守）；`flutter test test/quick_add_test.dart test/golden_quick_add_test.dart` → 6/6 All tests passed（复跑实测）；全量 `flutter test` → 380/380 All tests passed，exit=0，无挂死（14s，实测）；`tool/ci.sh` ALL GREEN（format 0 改动/analyze No issues/smoke/双构建 ✓Built）+ `bash tool/check-repo-hygiene.sh` OK。

文件约束：代码 10 文件=6 lib（price_watch 105/price_card 187/goal_price_follow 95/goal_page 391/quick_add 203/category_page 329）+ 4 test（price_watch 92/golden_price 206/quick_add 112/golden_quick_add 81）≤10；单文件最大 391≤400；无 pubspec；无 remote；真实账目=0；裸 Color(0x)=0；测试 Duration 仅排干 Timer（全仓既有口径）；_LOCK 本轮施工锁退场即删。
存量保护：SB-004 断言逐行未动（仅 teardown 机制变更）；已绿 price 20 例禁重开遵守（price_watch/golden_price 零触碰）；golden/sb004 基线零改动（空态 shrink 零像素差，复跑通过实证）。

偏差声明：无实质偏差。补充说明（非偏差）：①无 DB schema 变更——纯内存聚合复用 transactions 表 watchAll；②PriceZone 取 top 2 同键卡（按笔数倒序）；③键分隔兼容全角 ｜/半角 |；④本轮新增「无键不订阅」使空态 QuickAdd 零订阅，系回归根治 + 生产优化二合一。

状态：待审查（2026-10-11 20:3x builder 提审·SB-020 第 2 轮）
