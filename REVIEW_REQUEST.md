# REVIEW_REQUEST — SB-032 测试卫生：达成态两帧底板对齐（新卡提审）

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-032-test-hygiene`（commit ca84a76，未 merge、未推送，无 remote 操作，合规）
任务卡：`docs/tasks/SB-032.md`（状态：待办；R4=SB-032 新卡首轮，无 RC 计数）
基座：`main@36fa0cf` 起步（本轮 commit 一笔 2 文件，见文件约束；feat 分支 0 独占提交故 reset 至 36fa0cf 对齐真相注册表，无工作丢失）
S0 守卫说明：S2 新卡轮（REVIEW 11:3x 巡检零动作轮，无 REQUEST_CHANGES，S1 不触发；SB-012 真人闸门在飞/SB-021 挂起 v0.2/SB-033·SB-034 排队与本卡无关）；S0.3 _LOCK 本轮创建退场即删；S0.4 工作树本轮改动外干净；S0.5 REVIEW 新于 REQ（11:40 > 02:49）；S0.6 无显式 WAITING_HUMAN 标记行（唯一命中=SB-031 旧文第 6 行元叙述，沿 p=0.85 豁免）。

根因：`AchievementSession.global` 静态标志跨测泄漏——light 先跑 claim 成功弹层入镜，dark 后跑 shown 跳过不再弹（即 REVIEW 03:0x 挂账观察）；与主题无关，与日期无关。

验收对照（卡 §验收标准逐条）：
1. golden 四态零 diff：data/empty × light/dark 四帧再生后字节未动（git status 仅 light_done 一帧变更）；done-dark 字节未动（本就无弹层）；done-light 再生（211009→243509B，去遮罩后达成页全可见）；全程沿用 FixedClock 相对夹具，禁新建时钟注入（未新增任何时钟代码），渲染无日期串，任意日期结论同构。
2. 全量 442/442 绿（与 SB-031 基线计数一致，本轮只加断言未加用例）+ `tool/ci.sh` ALL GREEN（含 macos+apk 双构建）+ `bash tool/check-repo-hygiene.sh` OK + `dart format` 0 改动 + `flutter analyze --fatal-infos` 零问题；生产 `app/lib/` 零改动（`git diff HEAD --name-only -- app/lib` 空输出实证）。

偏差声明：无新增偏差；抑制弹层语义=门闩"已庆祝"预置（与 SB-008「落库后不再弹」生产语义一致，纯种子层表达）；弹层本体覆盖仍由 golden_achievement_test 承担，未弱化。

文件约束：测试 1 改（golden_goal_test.dart 284 行≤400：import 1 + 种子预置 12 + 复位 2 + 回归断言 2 + 注释）+ golden 1 再生（light_done）=2 文件≤4；无 pubspec；无 tokens；无 schema 迁移；未推送；真实账目 0；禁词零新增；_LOCK 本轮退场即删。

状态：待审查（2026-10-14 12:2x builder S2 新卡提审·SB-032；feat 分支未合入）
