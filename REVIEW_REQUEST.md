# REVIEW_REQUEST — SB-033 美学细节：环扫数字滚动 + 千分位全局统一（新卡提审）

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-033-countup-format`（未 merge、未推送，无 remote 操作，合规）
任务卡：`docs/tasks/SB-033.md`（状态：待办；R4=SB-033 新卡首轮，无 RC 计数）
基座：`main@88b0849` 起步（SB-032 合入后最新）
S0 守卫说明：S2 新卡轮（REVIEW 12:5x 无 REQUEST_CHANGES，S1 不触发；SB-012 真人闸门在飞/SB-021 挂起 v0.2/SB-034 排 033 后与本卡无关）；S0.3 _LOCK 本轮创建退场即删；S0.4 工作树本轮改动外干净；S0.5 REQ 新于 REVIEW（本轮提审）；S0.6 无显式 WAITING_HUMAN 标记行（旧文第 6 行 S0.6 元叙述沿 p=0.85 豁免）。

施工（裁定③两处都改）：
1. 千分位：`app/lib/logic/entry.dart` formatFen 加纯 Dart 手写分组（禁 intl 新依赖，领域层禁 flutter import 遵守）；全 App ¥输出 grep 实测已走 formatFen/formatAmount，唯一裸串=`quick_add_page.dart:90` 空态"¥ 0.00"输入占位（豁免理由：可编辑金额输入框的 2 位小数占位提示，非落库金额显示；输入即替换，附后无存储分叉）。
2. 环扫数字滚动：`app/lib/ui/widgets/progress_ring.dart` 新增 CountUpMonths（TweenAnimationBuilder begin 0→months，duration=MotionSpec.state 260ms + curve=emphasizedDecelerate，与 ProgressRing 同值同帧起播；disableAnimations 时直接显示终值；tabular 由 style 保证）；`dashboard_cards.dart` Hero 环心静态 Text 替换为 CountUpMonths（homeTotal 键保留，RunwayHero 字号/色不动）。动效时长守 §11（state 260 ∈ 220–320，滚动远≤600）。

验收对照（卡 §验收标准逐条）：
1. 格式化单测：entry_test 新增`SB-033 千分位`（0→'0'/123400→'1,234'/3612000→'36,120'/123456→'1,234.56'/负数→'-1,234'/极值100000000→'1,000,000'）；achievement_test 存量期望 '3999'→'3,999'（全局统一本意）；grep 无裸金额直出（1 豁免已申报）。
2. 监工实拍项（builder 预置证据）：progress_ring_test 新增`SB-033 中间帧≠终值+终值收敛`（130ms 泵中间态≠'1.2'，settle 后='1.2'）；千分位三页对照即 5 再生帧（目标页 light/dark + 成就弹层 light/dark + 收藏页 light）。
3. golden 更新 5 帧（sb007 goal_light_data/goal_dark_data 各 0.32% 8412px/sb008 achievement_light_popup 0.16% 2130px/dark_still 0.16%/collection_light_data 0.09% 2300px，目审均为逗号增量零布局漂移）；全量 444/444 绿（基线 442+新 2）+ `tool/ci.sh` ALL GREEN（含 macos+apk 双构建）+ `bash tool/check-repo-hygiene.sh` OK + `dart format` 0 改动 + `flutter analyze --fatal-infos` 零问题；无 pubspec/tokens/schema 迁移。

偏差声明：无新增偏差；formatRunway（跑道月数）未动（非金额，豁免）；百分比 toStringAsFixed 未动（非金额，豁免）。

文件约束：业务 3（entry/progress_ring/dashboard_cards）+ 测试 3（entry/achievement/progress_ring）=6 文件≤10，最大 376 行≤400；golden 5 再生（png 不计入文件数，清单如上）；无 pubspec；无 tokens；无 schema 迁移；未推送；真实账目 0；_LOCK 本轮退场即删。

状态：待审查（2026-10-14 13:2x builder S2 新卡提审·SB-033；feat 分支未合入）
