# REVIEW_REQUEST — SB-031 达成态打磨三项收口（新卡提审）

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-031-done-polish`（commit 7d79b63，未 merge、未推送，无 remote 操作，合规）
任务卡：`docs/tasks/SB-031.md`（状态：待办；R4=SB-031 新卡首轮，无 RC 计数）
基座：`main@2e29f9f` 起步（本轮 commit 一笔 7 文件，见文件约束）
S0 守卫说明：S2 新卡轮（REVIEW 02:2x 结论 SB-030 PASS，无 REQUEST_CHANGES，S1 不触发；SB-012 真人闸门在飞/SB-021 挂起 v0.2 与本卡无关）；S0.3 _LOCK 本轮创建退场即删；S0.4 工作树本轮改动外干净；S0.5 REVIEW 新于 REQ（02:4x 巡检段后无新审查）；S0.6 无显式 WAITING_HUMAN 标记行。

验收对照（卡 §验收标准逐条）：
1. 三项各自落地：①文案去 ✓（`goal_timeline.dart` 达成行改「已攒够 · N 周」，瓦片 `Icons.check` 保留；反向选择未采用，无需裁决）②达成态 golden 新增浅/深两帧（`goal_light_done.png` 211009B/`goal_dark_done.png` 115218B，合成夹具目标 10000 分+上月 6000 分→convertible 12000 达成）③编辑/删除键并入状态行右侧（状态文本 Expanded + 双键同 Row trailing，`goalEdit-/goalDelete-` 键名保留）；trend_line listEquals 修复零回退；未达成行 tabular 口径未动。
2. 达成态 golden 浅/深两帧已生成，golden 测试内断言达成行在位+文案去 ✓（`find.textContaining('✓')` findsNothing，页内其他「已攒够」系 goal/ladder/grain/achievement 复用口径非本卡回退）；sb007 data 两帧随布局再生（light 243143B/dark 114298B，仅时间线区像素变更，empty 两帧未动），待监工目审。
3. 基线 439/439 + 新增 3（trailing 同 Row 断言 1 + 达成态 golden 浅/深 2）= 全量 442/442 绿；双 ✓ 消除后达成态断言已同步（`find.textContaining('✓')` findsNothing + `goalTimelineDone-1` 在位）。
4. `tool/ci.sh` ALL GREEN（format 107 文件 0 改动/analyze No issues/test 全量/macOS+apk 双构建）+ `bash tool/check-repo-hygiene.sh` OK。

偏差声明：无新增偏差；N 周口径/折线口径沿 SB-030 按判受未动；本轮未碰 trend_line、未动 tokens/pubspec/schema。

文件约束：代码 3 改（goal_timeline.dart 152 行≤400 + goal_timeline_test + golden_goal_test）+ golden 4（2 改 sb007 data 随布局再生 + 2 新 done）=7 文件，代码计数 3≤10；无 pubspec；无 tokens；无 schema 迁移；未推送；真实账目 0；禁词零新增；_LOCK 本轮退场即删。

状态：待审查（2026-10-14 02:5x builder S2 新卡提审·SB-031；feat 分支未合入）
