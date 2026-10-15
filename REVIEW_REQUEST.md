# REVIEW_REQUEST — SB-046 Hero 载体/问句取整 + 起步文案数据态同步（提审·首审）

- **卡**：docs/tasks/SB-046.md ｜ **分支**：feat/SB-046-hero-precision@51006f2（基于 main@1d977fe）｜ **性质**：SB-043 P1 取整先例的机械延伸，非新设计裁决；裁A测试期冻结下 SB-046 豁免照常落地（REVIEW 21:4x 票）。
- **缘起**：21:0x 走查 P3 指名「留 SB-046」+ 19:5x 审美审计 P3 起步文案不同步；见底自派（裁④）。

## 改动→验收对照
- **载体行取整**：`todaySavedText()`（estimate.dart:150）`formatFen` → `formatFenHead`；显示位 today_saved_row.dart:44 零改（调用方）。`formatFenHead` 自带 ¥ 前缀，同步去重 `¥`（`'今天攒出 ${formatFenHead(...)}'`）。
- **问句行取整**：`closeAskText()`（estimate.dart:161）同改；「大约」与分位小数矛盾消除。列表/明细行 `formatFen` 分位不动（双口径沿 SB-043）。
- **起步文案数据态**：hero verdict else 分支（dashboard_cards.dart:42）加笔数分支：`convertibleFen<=0 && (todayCount>0||monthCount>0)` → `已记下、攒出在路上`（9 字≤14）；零笔零攒出仍 `记下第一笔，开始攒跑道`。禁词表（achievement.dart:13）零动；笔数字段复用在册（dashboard_stats.dart:58/:62）。

## 验证
- 自检三件套：`dart format` 0 改动 + `flutter analyze --fatal-infos` No issues + 相关测试 54/54（estimate/entry/dashboard_stats/progress_ring）。
- 全量：+486 All tests passed REAL_EXIT=0（483 基线 + 3 新增：SB-046 取整 1 + 起步 2）。
- `tool/ci.sh` 四闸绿 + `tool/check-repo-hygiene.sh` OK + macOS/app-debug 双 build 绿。
- 金样联动（仅受影响帧，声明）：sb016 close_light/dark_ask（1104px 差 = ¥57.5→¥58 取整实证，estimateFen 5750）+ sb006 dashboard_light/dark_data（593px 差 = 起步新文案实证，3 笔种子 convertible=0 翻新分支）。其余金样零动。
- 模拟器实拍 2 帧（FATAL=0，已收口 ALIVE=0）：docs/designaudit/2026-10-15-hero-precision/01_home_empty.png + 02_home_scrolled.png（1080x2400，空态基线：零笔零攒出分支「记下第一笔」在位实证）。

## 偏差声明（如实报，未修无隐瞒）
- 实拍 2 帧为空态基线，有数载体行（¥385.28→¥385）与有笔未攒新文案（已记下、攒出在路上）无真机帧——单轮 boot+种子成本，改由金样 4 帧 + 单测 3 例锁定，合入轮请监工走查补拍（SB-045 19:5x→20:39 裁 A 先例）。
- 文件计数 6≤10 合规：lib 2（estimate.dart、dashboard_cards.dart）+ test 2（estimate_test.dart、progress_ring_test.dart）+ 实拍 2（卡内视觉闸门授权）；golden 4 按 DEV §2.2 不计数；单文件 dashboard_cards ~385 行≤400；依赖变更 0；不碰禁区（tokens/pubspec/schema/规范/CI）。
- R1 申报：本卡首审。
