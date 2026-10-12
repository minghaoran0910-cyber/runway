# REVIEW_REQUEST — SB-023 测试时钟腐坏根治（首轮）

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-023-clock-fix`（未 merge、未 push、无 remote，合规）
任务卡：`docs/tasks/SB-023.md`（2026-10-12 14:36 浩然批准下发；排期注插队最前）
基座：`main@154a9a1`（零差异起步，`git checkout -b` 直切）
提交：`3714605 test(golden)`（4 改＋1 新＋golden 1 图重生成）

施工改动（业务文件 5≤10，单文件最大 347 行；golden png 按 DEV §2.2 不计）：
- `app/test/fixed_clock.dart`（新，18 行）：FixedClock 双模夹具——`today()` 动态封装（相对种子，保月份/周关系）＋`fixedMonday` 绝对钉（2026-10-12 周一，页时钟与绝对种子）＋`lastWeekMonday`；测试目录唯一允许直调 `DateTime.now` 之处（卡验收"固定夹具封装除外"口径）。
- `app/lib/ui/weekly_page.dart`（改，+27-13）：nowOverride 可选时钟缝——`_now` getter（override ?? DateTime.now），build/手动生成/自动生成/月-Key/月合计/上月合计 6 处经 `_now`；null 默认＝生产行为一字不改（见偏差①）。
- `app/test/golden_grain_test.dart`（改）：种子改绝对钉＋本周历史预置一条（周一 auto-generate 被幂等抑止，任意真实日期结构恒定 2 期）＋4 处 WeeklyPage 传 `nowOverride`。
- `app/test/golden_goal_test.dart`（改，2 处）：`DateTime.now()`→`FixedClock.today()`（相对种子保本月/上月关系，页只渲染数字无日期串，基线零触碰）。
- `app/test/golden_daily_close_test.dart`（改，2 处）：同上封装（收口卡 golden 本就字面量，基线零触碰）。
- `golden/sb014/weekly_light_data.png`（重生成唯一）：目审对照旧基线＝仅＋1 本周历史卡＋标题/历史日期串冻结为 10-12/10-05，其余卡位/字体/布局零漂移；其余 3 张 grain golden 字节零差未动，goal/daily_close golden 零触碰。

验收对照（卡 SB-023）：
1. 三族任意日期全绿：证ａ实测复现——周一全量 413/414，唯一红即本卡目标（grain 周报 light）；证ｂ腐坏解剖（scratch 实测，已删）：结构差（周一 auto-gen 多一张历史卡）6.57%，纯日期串差（同结构跨周）0.07% 照样红＝容差≈0，遂零生产改动无解（偏差①依据）；证ｃ修复后全量 **414/414**＋grain 文件连跑 2 遍全绿（渲染路径无 DateTime.now 可达：页经 override、种子绝对，grep 实证）；OS 级改日期仿真未做（无 faketime 依赖可加，禁令所限），等价性由"渲染输入全冻结"构造保证＋留监工多日期复核。
2. grep 直调清零：三族内 `DateTime.now()` 直调＝0（`grep -n` 实证，仅剩 `FixedClock.today()` 调用＋夹具内唯一封装＋注释）；三族外 8 文件未动（见偏差②）。
3. 四闸门＋hygiene＋生产 diff：`tool/ci.sh` ALL GREEN（format/analyze/test-smoke/双构建）＋`flutter analyze` No issues＋全量 414/414＋hygiene OK；生产 lib/ diff＝weekly_page.dart 1 文件加法缝（零行为变化），余零 diff。

测试：`flutter test` 全量 **414/414**（约 20s，含新增夹具 0 例——纯 helper 无断言）；`dart format` 0 改动；`flutter analyze` No issues；`tool/ci.sh` ALL GREEN＋hygiene OK；双构建 ✓Built（macOS＋APK）。

偏差声明（请监工裁决，不阻塞审）：
① 生产 1 文件加法缝 vs 验收"生产 lib/ 零 diff"——零改动下周报整页 golden 跨周必红已成实证（0.07% 串差即红），手段与目的冲突时保目的（根治）；缝为纯加法可选参数，默认 null＝旧行为逐行等价，无 token/动效/数据/依赖触碰；翻案成本＝revert 1 文件＋基线回 HEAD（单 commit 可逆）。
② grep 三族外 8 文件延期（dashboard_page/golden_dashboard/golden_home_budget/golden_price/golden_role/golden_achievement/golden_cooloff/cooloff_test＋perf_budget 共 9 处直调，均为相对种子、渲染数字或固定文案、当轮全绿稳定）：全改＝13 文件超 DEV 10 件硬约束，遂本轮只收三族；建议后续微卡统一收（纯 `FixedClock.today()` 机械替换，零行为变化）。

文件约束：业务 5 文件（4 改＋1 新）≤10；单文件最大 347≤400；无 pubspec；无 remote；真实账目＝0；禁词产品文案零新增；_LOCK 本轮退场即删。

状态：待审查（2026-10-12 15:0x builder 提审·SB-023 首轮；feat 分支未合入；progress/REQ 未提交改动留工作树，监工可代簿随 squash 入头，循 SB-012 例）
