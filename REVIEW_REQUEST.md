# REVIEW_REQUEST — SB-025 时钟卫生收尾（首轮提审）

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-025-clock-hygiene`（未 merge、未 push、无 remote，合规）
任务卡：`docs/tasks/SB-025.md`（状态：待办；2026-10-12 15:22 浩然批准下发）
基座：`main@6c2f67b` 起步（20:1x 巡检簿记头，无需 merge main，基线干净）
S0 守卫说明：S0.1~S0.5 全过（main 单分支/无 _LOCK/工作树净/REQ 19:00:14 < REVIEW 20:13:50 无新提审）；S0.6 按监工 REVIEW.md 20:0x 段误报裁定（decision p=0.85）放行——现行 REQ 第 6 行「未达 WAITING_HUMAN 线」系 SB-024 已审结旧文（squash@5cf4ff2·done/=22）元叙述，非显式标记行，新规则（^状态 WAITING_HUMAN/整行）匹配=0。

施工改动（业务 9 文件≤10，单文件 +1~+4 行≤400；生产 lib/ 零改动；夹具零改动；无 pubspec；无 remote）：
- 9 测试文件：`dashboard_page_test` / `golden_home_budget_test` / `perf_budget_test`（3 处）/ `cooloff_test` / `golden_cooloff_test`（3 处）/ `golden_dashboard_test` / `golden_achievement_test` / `golden_role_test` / `golden_price_test`——各加 `import 'fixed_clock.dart';`（SB-023 既定样式），直调 `DateTime.now()` 全改 `FixedClock.today()`（相对种子，行为与直调一致；golden 用相对种子故渲染不变）。
- 文件数偏差声明：卡预估 8，实测 9（`perf_budget_test` 3 处与 `golden_home_budget_test` 各计 1 文件；SB-023「三族外延期」时 grep 口径差异所致）。仍≤10 上限，未扩 scope，未新开工作面。

验收对照（卡 SB-025 两项）：
1. grep 除夹具封装外=0 ——达标。实测 `grep -rn "DateTime.now()\|new Date()" app/test/` 仅剩 `fixed_clock.dart` 内 3 处（第 3 行注释口径/第 9 行注释/第 10 行 `today()` 本体，卡验收「夹具封装除外」口径），测试文件命中=0。
2. `tool/ci.sh` 四闸门绿 + golden 零 diff 零重生成——达标。format 97 文件 0 改动 / analyze No issues / test 全量 414/414（含本轮 9 文件全部用例与 golden 像素断言）/ build macos+apk 双成功 ALL GREEN；`tool/check-repo-hygiene.sh` OK；`git status` 仅 9 测试文件（golden/*.png 零改动，lib/ 零改动）。

测试：全量 `flutter test` 414/414 绿（SB-023 基线 414，纯迁移无增删）；纸面行为不变，无新增单测（迁移卡，断言语义零改）。

偏差声明（如实申报）：
① 文件数 9≠卡预估 8（见上，grep 全量实测为准，接受①的反向是验收①失败，故全迁）。
② 全部用 `today()` 相对种子，未用 `fixedMonday` 绝对钉——因本轮 9 文件种子语义均为"今天/当月相对"，绝对钉会改变 golden 渲染日期，违反验收②；三族（grain/goal/daily_close）绝对钉口径系 SB-023 专属，本轮不碰。
③ `cooloff_test.dart:216` 的 `proposedAt` 系状态值域锁定种子（非 24h 窗口断言），改走夹具后行为一致，全量绿实证。

文件约束：业务 9 文件≤10；单文件增量≤4 行；无 pubspec；无 remote；真实账目 0；禁词零新增；_LOCK 本轮退场即删。

状态：待审查（2026-10-12 20:2x builder 提审·SB-025 首轮；feat 分支未合入；合入轮需冒烟，锚点 cd5d73a）
