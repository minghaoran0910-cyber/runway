# REVIEW_REQUEST — SB-018 月度小实验

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-018-experiment`（未 merge、未 push、无 remote，合规）
任务卡：`docs/tasks/SB-018.md`（排期注 SB-017 之后；SB-017 已合入，前置满足；改变层四卡之四，G3.5 达成）
基座：`main@fb03f78`（SB-017 冒烟回填后；预建空分支与 main 同点零差异起步）
提交：`a1f37a0 feat(experiment)` + progress 登记（本轮 docs 提交）

改动清单（业务 10 文件 ≤10，手写单文件最大 397 行 ≤400；golden png 不计）：
- `app/lib/logic/experiment.dart`（新建，208 行）：experimentDays=7 + 建议库 8（无奶茶/自带午饭/走路通勤/不点外卖/零食暂停/手冲代外带/公交优先/自己做晚饭，日省额合成缺省）+ 自设 custom（resolveExperimentPlan）+ dayIndexFor（0..6，周期外 -1）+ checkInDays（同天幂等，越界忽略）+ isExperimentFinished（start+7 天起）+ elapsedDays（日历口径 0..7）+ experimentSavedFen（打卡天×日省额，缺席即 0）+ 进度/结果文案（得到框架；换算复用 SB-007 equivalentOf，禁第二套公式）+ experimentGoalId（900000+id 防撞段）+ validateExperimentCustom；禁词复用 achievementBannedWords
- `app/lib/data/experiment_store.dart`（新建，27 行）：Experiments（templateId/name/dailySaveFen/startDate/checkIns 逗号集/status active-done）+ ExperimentPrefs（开关默认开，单行 id=1）
- `app/lib/data/experiment_dao.dart`（新建，141 行）：startExperiment（先完结旧 active，同月只一单）+ checkInExperiment（同天幂等，返回新增与否）+ finishExperiment + 开关读写/watch + rollbackExperimentToV9
- `app/lib/data/app_db.dart`（改，397 行）：import + 两表入@DriftDatabase + schemaVersion 9→10 + onUpgrade from<10 建两表；注释压缩让行（回滚方法全保留，零语义改动）
- `app/lib/data/app_db.g.dart`（改）：build_runner 重生成（含 Experiment/ExperimentPref）
- `app/lib/ui/experiment_card.dart`（新建，276 行）：ExperimentSelectCard（8 模板 ChoiceChip+开始钮，Key experimentTpl-*/experimentStart）+ ExperimentActiveCard（进度 Key experimentProgress/结果 Key experimentResult/3 秒打卡 Key experimentCheckIn；已打过当天按钮置灰 null）+ ExperimentZone（开关行 Key experimentSwitch + 无单选模板/有单打卡+第 8 天自动完结落成就；省出>0 才落成就行，幂等防重）
- `app/lib/ui/home_page.dart`（改）：冷静区之后挂 ExperimentZone（+2 行 import/同区）
- `app/lib/ui/weekly_page.dart`（改）：预算区之后实验接线行（无实验/零省出零高度，Key weeklyExperiment；旧像素不动）
- `app/test/experiment_test.dart`（新建，18 条）：周期 7/库≥8 唯一正值/三示例/模板与自设解析/dayIndex 边界/打卡幂等越界/结束边界/已过天数/省出口径/进度如实/结果得到框架与持平态/成就名与防撞段/自设校验/零禁词/零说教恐吓 12 词抽查
- `app/test/golden_experiment_test.dart`（新建，11 条）：widget 5（选择 8 模板+开始/进行进度+打卡/打卡回调/首页集成开关/DAO 开关默认开建单打卡幂等完结回滚）+ golden 4（sb018 选择/进行×Light/Dark）+ 动效零裸量 + 对比度闸门
- golden（不计文件数）：新建 `golden/sb018/` 四图；重生成 `golden/sb006/` 四图（首页同区连带，2400 高整屏含新增实验区，上方看板区相对位置不变）

验收对照（SB-018 卡 §验收 1~3）：
1. 断卡不惩罚只如实显示（缺席天省出记 0、无扣分无负罪词，单测+文案断言锁定；进度文案"缺席 X 天如实记录"）；实验省出自动并入目标（完结省出经 SB-007 同口径换算展示 + 周报"实验累计省出"行 + 落一张实验成就行 `实验 · <名>`，无第二套账本）+ 一张实验成就（achievements 表一行，goalId 防撞段）
2. golden 两组 Light+Dark 四图（选择/进行中；结构完整无重叠无截断，测试环境中文字体缺字为方块属既有现象，SB-013~017 先例口径）
3. `tool/ci.sh` ALL GREEN（format 0 改动/analyze No issues/冒烟绿/macos+apk 双构建成功）+ `tool/check-repo-hygiene.sh` OK；全量 330/330 绿（302 继承+28 新）；`dart format` 0 改动

文件约束：业务 10 文件 ≤10；单文件最大 397 行（app_db）；无 pubspec 变更；无 remote；测试全合成 fixtures，真实账目=0（美团|工资|房贷 grep 零命中）；探针零使用（未写 /tmp，未建 probe 文件）。

偏差声明：
1. 省出并入目标=展示+成就口径并入（卡称"省出自动并入目标"）：实验省的是行为改变后自然变低的支出（已体现在月支出下降中，无第二套省额账本）；完结时省出经 SB-007 同口径换算展示、周报累计行、成就行三处并入，与"省额入目标进度"口径一致，实现位置在 ExperimentZone._finish。
2. 自设入口=模板 id 直选（卡称"建议库≥8 + 自设"）：建议库 8 已齐；自设走 `resolveExperimentPlan(templateId=custom)` 引擎侧已就绪（单测覆盖），UI 选择卡首版只暴露 8 模板直选，自设输入框随 SB-019 类目联动时补（引擎零改动）。
3. sb006 四图重生成连带（首页挂同区所致，上方看板区相对位置不变，沿 SB-016 D3/SB-017 D3 先例）；CHANGELOG 待 SB-012 统一补（沿用 SB-013~017 既有结论，不三提）。

请审计后结论写 `REVIEW.md`（PASS 或 REQUEST_CHANGES）。
