# REVIEW_REQUEST — SB-007 目标阶梯与实物换算

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-007-goal-ladder`（未merge、未push、无remote，合规）
任务卡：`docs/tasks/SB-007.md`
commit：`8092cfc feat(goal): 目标阶梯与实物换算+schema v2 [SB-007]`（+ trailer `Agent: opencode`）

验收对照（任务卡 5 项）：
1. 目标 CRUD：名称/目标额/参考单价（内置奶茶1800/键盘29900/手机399900/5090 1649900分，chips一键填入+可自定义改名改价） —— ✓ `ui/goal_page.dart`（GoalPage列表+设定对话框，首条id最小者为当前目标）+ `data/app_db.dart`（Goals DAO：list/watch/insert/update/delete）。
2. 换算引擎：按"比基线多省 + 环比增量"输出"本周省出 N 杯奶茶"式文案；单测17条（含月光月"基线花光但环比增量省出2杯奶茶"用例） —— ✓ `logic/goal_ladder.dart`（computeGoal/describeSaving/equivalentOf/ladderNameFor/nextLadderHint；纯Dart，禁import flutter）。
3. 进度条随记一笔实时联动（数据源 SB-004） —— ✓ `ui/goal_page.dart`（watchGoals+watchAll双流，记一笔即重算）+ widget测试"记一笔后换算文案联动"；首页 `ui/home_page.dart` 传真实goalFen（闭环SB-006 D1目标未持久化）。
4. 文案全量"得到"框架，零亏欠式表述 —— ✓ 引擎+UI文案单测断言禁词（"又花掉/只剩/还差/超支/别买/不该"全量扫描为零）；大额只陈述（"相当于 N 件手机"，无行动召唤）；空态"定第一个目标，开始攒出奶茶"。
5. golden四组：目标设定页+进度卡 Light/Dark × 空/有；四闸门全绿 + hygiene OK —— ✓ `test/golden_goal_test.dart` 4组基线 `golden/sb007/goal_{light,dark}_{data,empty}.png` 新建并比对通过；`tool/ci.sh`（format/analyze/test-smoke/build macOS+APK，ALL GREEN）+ `check-repo-hygiene.sh` OK；全量 `flutter test` 84/84绿（59继承+25新增，SB-006 golden零回归）；对比度闸门绿。

验证：
- `flutter analyze --fatal-infos --fatal-warnings app`：No issues
- 文件约束：代码文件9（lib新3：goal_ladder 181行/goal_page 341行/goal_card 111行；lib改2：app_db 161行/home_page 205行；drift生成app_db.g.dart 1；test新2：goal_ladder_test 200行/golden_goal_test 191行；test改1：dashboard_page_test 104行），均≤400行（生成文件除外，SB-004先例）；无依赖变更（pubspec 0改动）、无docs规范改动
- schema v2：Goals表（name/targetFen/priceName/priceFen/tier/doneAt/createdAt，PRD §4 goal模型子集）；onUpgrade v1→v2建表（存量transactions不动）；`rollbackGoalsToV1()`开发期回滚（删表回v1形状）；build_runner已重生成g.dart

偏差声明（请监工知悉/裁决）：
- D1 文件数13（含golden基线4张）：卡预估"引擎1+DAO迁移2+页面2+组件1+测试4=10"未含golden产物与regen零星差。本次代码文件9≤10；golden 4张为验收5明示四组之直接产物（SB-006先例：基线png随附）；多出部分=基线4张。请监工裁决是否接受（或指示基线精简口径）。
- D2 首页入口为目标卡点击（GestureDetector零像素改动）：初版曾加AppBar旗标按钮，致SB-006 golden 4组像素漂移（0.01%/270px），已回退；现方案SB-006基线零改动、零回归。代价是入口隐性（无独立图标），G5打磨时可按规范补显性入口。
- D3 口径叠加说明：默认基线=上月实际支出时，"比基线多省"与"环比增量"数值相等、总额为其2倍——此为卡口径字面实现（两项各自钳零后相加），调用方可传预算baseline覆盖以解耦；单测已锁定该行为。如需去重口径请打回，我改引擎+卡口径。
- D4 doneAt/tier已建nullable列但成就写入待后续卡（成就卡归SB-008/G3）；tier落库时由ladderNameFor推导写入。

请审计后结论写 `REVIEW.md`（PASS 或 REQUEST_CHANGES，本卡第 1 轮/上限 3 轮）。
