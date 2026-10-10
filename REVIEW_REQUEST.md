# REVIEW_REQUEST — SB-008 成就卡与解锁庆祝

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-008-achievement`（未merge、未push、无remote，合规）
任务卡：`docs/tasks/SB-008.md`
commit：`c057eeb feat(achievement): 成就卡与解锁庆祝+schema v3 [SB-008]`（+ trailer `Agent: opencode`）

验收对照（任务卡 5 项）：
1. 解锁即时触发（本会话内达成即弹；错过在下次打开补弹一次） —— ✓ `logic/achievement.dart`（isGoalUnlocked/detectUnlocks/AchievementSession会话去重）+ `ui/achievement_gate.dart`（AchievementGate零像素门：claim即落库achievements一行+回写goals.doneAt/tier，落库后不再弹；widget测试"达成后弹并落库/落库后重开不再弹/未达成不弹"）。
2. 成就卡动效全走 MotionSpec 常量（1200ms 规格），代码零裸时长/曲线 —— ✓ `ui/achievement_card.dart`（showAchievementDialog，弹出动效1200ms规格内+easeOutBack唯一允许过冲，可打断）；单测断言`MotionSpec.achievement` 900–1200ms且`particlesMax≤12`；"动效零裸量"测试全量扫描新UI文件无裸Duration/Curves/Cubic。
3. 收藏页按时间序列展示，可分享为图片（截图导出，无新依赖） —— ✓ `ui/achievements_page.dart`（watchAchievements倒序序列+空态引导+分享按钮，RepaintBoundary截图导出PNG字节，widget测试覆盖空态/有数/导出，无新依赖，pubspec 0改动）。
4. golden四组：成就卡 Light/Dark × 弹出帧/静帧 + 收藏页空/有 —— ✓ `test/golden_achievement_test.dart` 4组基线 `golden/sb008/achievement_{light_popup,dark_still}` + `collection_{light_data,dark_empty}` 新建并比对通过；SB-007 golden零回归（goal_page改动仅达成态才出现的收藏入口+Gate，非达成零像素）。
5. 四闸门全绿 + hygiene OK —— ✓ `dart format` 0改动；`flutter analyze --fatal-infos --fatal-warnings` No issues；全量 `flutter test` 107/107绿（84继承+23新增：单测12+widget/golden11含对比度闸门）；`tool/check-repo-hygiene.sh` OK。

验证：
- `flutter analyze --fatal-infos --fatal-warnings app`：No issues
- 文件约束：代码文件8（lib新3：achievement 105行/achievement_card 233行/achievement_gate 128行/achievements_page 146行；lib改2：app_db 206行/goal_page 361行；test新2：achievement_test 172行/golden_achievement_test 348行），均≤400行（app_db.g.dart生成文件豁免沿SB-004先例）；无依赖变更（pubspec 0改动）、无docs规范改动
- schema v3：Achievements表（goalId/goalName/targetFen/convertibleFen/tier/unlockedAt，PRD §2成就卡子集）；onUpgrade v2→v3建表（存量goals/transactions不动）；`rollbackAchievementsToV2()`开发期回滚（删表回v2形状）；build_runner已重生成g.dart
- 文案得到框架：引擎+UI单测断言禁词（"又花掉/只剩/还差/超支/别买/不该"仅禁词表常量定义，标题/正文/分享零命中）；大额只陈述（achievementBody复用equivalentOf无行动召唤）；标题"已攒够X·得到Y底气"、分享"用攒够攒出X·稳步积累的证明"

偏差声明（请监工知悉/裁决）：
- D1 文件数13（含golden基线4张+g.dart regen）：卡预估10。代码文件8≤10；golden 4张为验收4明示四组之直接产物（沿SB-006/007先例随附）；g.dart为drift regen。请监工裁决是否接受。
- D2 收藏入口放在目标页达成态（TextButton"查看成就收藏"，key=goalToAchievements）：未达成时零像素（条件渲染，SB-007 golden零回归）；达成后才出现。显性全局入口（如首页/Tab）未做，G5打磨可按规范补。
- D3 补弹语义为"落库即庆祝"：错过指已达成但无成就行，下次打开Gate即弹并落库；落库后靠celebratedGoalIds去重，会话内靠AchievementSession.global去重。如需跨会话多弹/重复庆祝请打回，我改口径。
- D4 SB-007备忘"攺"笔误：本轮未顺手改（goal_ladder.dart不在本卡diff范围，碰即超卡范围；留待下轮含goal_ladder的卡或专项清理）。

请审计后结论写 `REVIEW.md`（PASS 或 REQUEST_CHANGES，本卡第 1 轮/上限 3 轮）。
