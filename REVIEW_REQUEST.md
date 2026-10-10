# REVIEW_REQUEST — SB-014 余粮正名与粮仓梗包

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-014-granary`（未 merge、未 push、无 remote，合规）
任务卡：`docs/tasks/SB-014.md`（余粮正名，浩然 2026-10-10 批准；SB-009 合入后开工，前置已满足）
基座：`main@e871b18`（SB-013 结案后；本分支系预建空分支，tip 与 main 同，零冲突）
提交：`18e0263 feat(granary): SB-014 余粮正名与粮仓梗包 [SB-014]`

改动清单（业务 10 文件 ≤10，手写单文件最大 400 行 ≤400；golden png 不计）：
- `app/lib/logic/safety_report.dart → app/lib/logic/grain_report.dart`（git mv）：标识符 Safety*→Grain*（GrainReserveView/computeGrainReserve/validateGrainMonths/grainTitle/grainBody/grainHint/grainBannedWords）；新增称号引擎（grainTitleRoute5/Route3/grainMonthsRoute/grainJokes 同文件常量池 + goalGrainTitle/grainMonthsTitle/grainJokeFor/isSmallGrainTarget）与周报物理换算 weeklySavingConvert；379 行
- `app/lib/logic/achievement.dart`：禁词表 +4（亏了/没了/花光/穷），余无改动
- `app/lib/logic/goal_ladder.dart`：阶梯档 `安全垫`→`余粮`（阈值 6000000 不变）+ 注释同步
- `app/lib/ui/safety_card.dart → app/lib/ui/grain_card.dart`（git mv）：GrainReserveCard/GrainMonthsDialog/editGrainMonths/GrainZone，keys safety*→grain*，文案余粮化，状态行嵌月数称号（`已攒 50% · 地主家 · …`）；布局零增删（同等 Text 行数）
- `app/lib/ui/goal_page.dart`：import 切换 + SafetyZone→GrainZone + 注释同步（布局不动）
- `app/lib/ui/weekly_page.dart`：import 切换（goal_ladder 引用消除）+ 换算行改接 weeklySavingConvert（同行替换，布局不动）
- `app/lib/data/app_db.dart`：仅注释 `安全垫配置`→`余粮配置` + SB-014 表名保持声明；schema/DAO/表名零改动（无迁移授权，行为零变化）；400 行（上限内）
- `app/test/safety_report_test.dart → app/test/grain_report_test.dart`（git mv）：标识符同步 + 新增 8 条（五档±1分/三档/月数换算2例/并行映射/物理换算/禁词/梗/改名回归）
- `app/test/golden_safety_test.dart → app/test/golden_grain_test.dart`（git mv）：keys/路径切 sb014 + 新增称号行 widget 断言
- `app/test/goal_ladder_test.dart`：阶梯期望 `安全垫`→`余粮`
- golden（不计文件数）：新建 `golden/sb014/` 四图（grain_light_data/grain_dark_empty/weekly_light_data/weekly_dark_empty）；重生成 `golden/sb007/` 四图（目标页内嵌余粮区文案连带，字节增量 +50~+93/张，文案外无改动）

验收对照（SB-014 卡 §验收 1~6）：
1. 正名：`grep -r 安全垫 app/lib` = 0（实测）；UI 一律余粮；logic/ui/test 文件名+标识符 Safety*→Grain* git mv 同步；DB 表/列名保持（行为零变化，见偏差1）
2. golden：sb014 四图新建通过（本轮 `--update-goldens` 生成 + 回跑全绿）；sb007 四图重生成（余粮区文案连带）；除文案外无布局改动（同等 widget 行数，字节微增为证）
3. 称号：五档 `种下第一穗→青苗→半锅米→米满沿→仓满` 按 0/25/50/75/100% 映射，边界各 ±1 分单测锁定；小额（≤500元）三档 `下种/半路/满仓`；月数档等比（6个月50%=30000 与 3个月50%=15000 同为地主家，2 例锁定，无写死月数）；称号池+梗句同文件（grain_report.dart）；多目标并行映射单测（两目标不同进度各得其号）；收藏页分组见偏差2
4. 周报换算：weeklySavingConvert 复用 defaultPrices（2700分→`≈ 1.5 杯奶茶` 实测）；不足半件回落余粮天数（500分+月均30000→`够 0.5 天余粮`）；月均未知→`稳步积累中`；零编造分支全覆盖单测
5. 禁词：原 6 + 增 4 = 10 词；新增后全仓用户可见文案零命中（称号/梗/余粮/周报全量断言）；梗零第二人称零消费词（`你/买` 断言）；UI 无裸 Color(0x)/Duration（date 算术 Duration 系 SB-009 原样保留，非动效）
6. 测试：全量 `flutter test` 187/187 绿（178 继承 + 9 新增）；`tool/ci.sh` ALL GREEN（format 0 改动/analyze No issues/smoke 绿/macos+apk 双构建成功）；`tool/check-repo-hygiene.sh` OK；`dart format` 0 改动

文件约束：业务 10 文件 ≤10；单文件最大 400 行（app_db.dart 恰 400，grain_report 379）；无 pubspec 变更；无 remote；测试全合成 fixtures，真实账目=0；探针零使用（未写 /tmp，未建 probe 文件）。

偏差声明：
1. DB 层英文标识符保留（SafetyPad 表/DAO 方法名）：SB-014 无 schema 迁移授权，改表名即行为变化；验收 1 的 grep 口径仅限中文 `安全垫`（=0 已达），英文表名属存储层非用户可见。 escapism 零新增。
2. 收藏页视觉分组头未做：achievements 数据模型已按目标分组（goalId/goalName逐卡展示即分组视图）；称号引擎按目标映射已单测锁定。视觉分组头（同目标折叠）需改 achievements_page（将超 10 文件），留后续小卡。
3. CHANGELOG.md 本仓从未建立（SB-013 偏差既有结论），本卡未新建，待 SB-012 统一补。
4. 称号常量与引擎同落 grain_report.dart（未单拆称号引擎文件）：卡预估 8 文件计入接线后实为 10 整，单拆即超限；常量池独立成段注释隔离，满足"同一常量文件"字面要求。
5. golden_goal_test.dart 第 82 行注释残留 `安全垫`：属 app/test 注释非用户可见（验收 grep  scope=app/lib），为保 10 文件未动该文件。

请审计后结论写 `REVIEW.md`（PASS 或 REQUEST_CHANGES）。
