# REVIEW_REQUEST — SB-009 安全垫与周报

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-009-safety-weekly`（未merge、未push、无remote，合规）
任务卡：`docs/tasks/SB-009.md`
commit：`dc70a16 feat(safety): 安全垫与周报+schema v4 [SB-009]`（+ trailer `Agent: opencode`）

验收对照（任务卡 5 项）：
1. 安全垫目标可设（默认 6 个月，进度=自由基金余额/目标额），与目标阶梯同区展示不重复造轮子 —— ✓ `logic/safety_report.dart`（computeSafetyPad：目标=近3月月均×月数，余额=本月可换算省出computeGoal口径，validateSafetyMonths 1–36）+ `ui/safety_card.dart`（SafetyPadCard复用GoalProgressCard视觉语言：r16卡/r10进度条/tabular/tokens；SafetyZone由GoalPage目标区之下挂载；设月数对话框upsert落库）。
2. 周报每周一自动生成历史留存：支出/收入（若有）/省出金额换算 Top3/环比上周；纯本地生成无网络 —— ✓ `ui/weekly_page.dart`（打开周报页时周一且本周未生成则自动落库，weekStart幂等去重；手动"生成本周周报"按钮兜底；历史序列weekStart倒序）+ 引擎computeWeekly/sumPrevWeekSpend/shouldGenerateWeekly；收入字段预留0（transactions暂无收入口径，见D4）；零网络调用。
3. 换算口径复用 SB-007 引擎（禁复制粘贴第二套） —— ✓ 周报省出=max(0,上周−本周)单环比增量（见D3）；文案换算复用`equivalentOf`/`describeSaving`，禁词复用`achievementBannedWords`（safetyBannedWords getter转发，不另建表）；类目归一复用`canonicalCategory`。源码级无重复换算实现。
4. golden四组：安全垫卡 + 周报页 Light/Dark × 空/有 —— ✓ `test/golden_safety_test.dart` 4组基线 `golden/sb009/safety_{light_data,dark_empty}` + `weekly_{light_data,dark_empty}` 新建并比对通过；SB-007 golden 4张重生成（见D2）。
5. 四闸门全绿 + hygiene OK —— ✓ `dart format --set-exit-if-changed` 0改动；`flutter analyze --fatal-infos --fatal-warnings` No issues；全量 `flutter test` 133/133绿（107继承+26新增：单测15+widget/golden11含对比度闸门）；`tool/check-repo-hygiene.sh` OK；`flutter build macos --debug` + `flutter build apk --debug` 双成功。

验证：
- 文件约束：代码文件8（lib新3：safety_report 273行/safety_card 228行/weekly_page 247行；lib改2：app_db 299行/goal_page 375行；test新2：safety_report_test 239行/golden_safety_test 278行；test改1：golden_goal_test 197行CRUD滚动），均≤400行（app_db.g.dart生成文件豁免沿SB-004先例）；无依赖变更（pubspec 0改动）、无docs规范改动
- schema v4：SafetyPad表（targetMonths默认6，单行id=1约定）+WeeklyReports表（weekStart/spend/income/saved/topJson/momDelta）；onUpgrade v3→v4建双表（存量不动）；`rollbackSafetyWeeklyToV3()`开发期回滚（删双表回v3形状）；build_runner已重生成g.dart
- 文案得到框架：安全垫/周报标题正文环比Top单测断言禁词零命中（复用成就禁词表）；大额只陈述（safetyBody/weeklyBody复用equivalentOf无行动召唤）；周报"比上周多花X·整体仍在积累"（陈述+托底，无亏欠）

偏差声明（请监工知悉/裁决）：
- D1 文件数9（代码8+g.dart regen豁免）：卡预估9（引擎1、DAO+迁移2、页面2、测试4）。实际test改1（golden_goal CRUD滚动，见D2）计入，lib改goal_page为同区挂载必需。golden 8张为验收4+回归4之直接产物（沿SB-006/007/008先例随附）。请监工裁决是否接受。
- D2 SB-007 golden 4张重生成 + CRUD测试加滚动：安全垫同区展示为卡面明示要求（"与目标阶梯同区展示"），非零像素改动，基线必须跟进；目标列表被顶出首屏视口（ListView懒加载），CRUD断言前加scrollUntilVisible。请监工逐张目审（防改基线骗测）。
- D3 周报省出口径为周粒度单环比增量（max(0,上周−本周)），未照搬月口径"基线差+环比增量"双项相加：周粒度下基线即上周，双项相加会双计。如需与月口径完全同形请打回，我改口径。
- D4 "自由基金余额"定义为本月可换算省出（computeGoal口径，非累计存款）；收入字段记0预留（transactions暂无收入口径，无编造）；提醒开关未做（需本地通知库，按卡要求须先ADR，故不引入）。
- D5 自动生成语义为"打开周报页时若为周一且本周未生成则自动落库"（幂等），非后台定时任务（本地优先、无后台常驻；G4采集阶段再议）；手动按钮为兜底。如需真后台调度请打回，我出ADR。

请审计后结论写 `REVIEW.md`（PASS 或 REQUEST_CHANGES，本卡第 1 轮/上限 3 轮）。
