---
# REVIEW — 2026-10-11 09:0x 审查轮 · SB-018 月度小实验
结论: PASS（第 1 轮 · 卡 SB-018）

触发核查: REQ mtime 1791679819(08:50:19) > REVIEW 1791679346(08:42:26)，内容=SB-018 新提审面（非已审 SB-017 面）；分支 feat/SB-018-experiment@a1f37a0+afb8a81，基座 main@fb03f78（SB-017 冒烟回填后同点零差异起步）。builder 第12轮遗留未提交 progress wake 行，监工代簿随 squash 落 main（docs-only，零语义改动）。

检查项（监工独立实测，非转述 builder 声明）:
- [x] `flutter test` 全量 330/330 All tests passed（本轮真实回显，exit=0）
- [x] 分文件实跑：experiment_test.dart +18 绿、golden_experiment_test.dart +11 绿（29 新全过；REQ"28 新"系措辞口径差 1，无实害）
- [x] `dart format --output=none --set-exit-if-changed` 81 files 0 changed；`flutter analyze` No issues found
- [x] `tool/check-repo-hygiene.sh` repo hygiene: OK
- [x] 文件约束：业务 10 文件 ≤10（含生成码 app_db.g.dart）；手写最大 app_db.dart 397 ≤400 行（wc -l 实测）；store 拆独立文件防膨胀；无 pubspec 变更
- [x] schema v10 实读：@DriftDatabase +Experiments/+ExperimentPrefs；schemaVersion 9→10；onUpgrade from<10 建两表；rollbackExperimentToV9 在位；app_db.dart diff 系注释压缩让行零语义改动；Experiments 列（templateId/name/dailySaveFen/startDate/checkIns/status）+开关默认开实读
- [x] 验收1：断卡不惩罚——缺席天省出记 0（experimentSavedFen=打卡天×日省额，缺席即 0），进度文案"缺席如实记录"，无扣分无负罪词；dayIndexFor 周期外 -1、checkInDays 越界忽略+同天幂等、DAO checkInExperiment 幂等返 bool 全部源码+单测双核；省出并入目标=展示+成就+周报累计行三处（见 D1 裁决）；一张实验成就 goalId=900000+id 防撞段实读
- [x] 验收2：golden/sb018 四图实存（08:48 新建，select/active×Light/Dark）；sb006 四图重生成系首页同区连带（见 D3）
- [x] 验收3：四闸门独立复跑全绿；真实账目 grep（美团|工资|房贷）=0，测试全合成 fixtures
- [x] 禁词复用 achievementBannedWords 实读（不建第二套）；零禁词/零说教 12 词抽查单测在位并实跑绿
- [x] 首页挂载实读：CooloffZone 之后 ExperimentZone 同区（+4 行 import/注释/挂载/间隔，REQ"+2 行"措辞口径）；周报预算区之后接线行实读（StreamBuilder watchExperiments，无实验/零省出零高度，Key weeklyExperiment）
- [x] 自设引擎侧实读：resolveExperimentPlan custom 分支+validateExperimentCustom（名 1–16 字/日省额 >0/上限防呆）在位且单测覆盖
- [x] 红线：remote=0；_LOCK find 全仓=0；LOOP 无 WAITING_HUMAN 标记

三偏差裁决（decision_evaluate 单调用三问，模型 typesafe/jev-1.13-20260917，status=ok）:
- D1 省出并入目标=展示+成就口径并入（不建第二套省额账本，经 SB-007 同口径换算+周报累计+成就三处并入）→ 决策p=0.90 按判接受（SB-017 D1=0.90、SB-016 D1=0.91 同型先例）
- D2 自设实验首版 UI 不暴露输入框（引擎已就绪+单测过，自设入口声明"随 SB-019 补"）→ 决策p=0.72 灰区（0.25<p<0.75），留浩然拍板：A=随 SB-019 补自设 UI（builder 声明口径）/ B=单独发一张小卡补自设入口。**核验注**：监工 grep SB-019 卡文无"自设"字样——延后承接未在卡文落地，选 A 需把自设 UI 写入 SB-019 条款或另发小卡，否则自设永无 UI。
- D3 sb006 四图连带重生成 + CHANGELOG 随 SB-012 统一补（既有结论不三提）→ 决策p=0.89 按判接受（SB-016 D3=0.91/SB-017 D3=0.89 先例）

问题列表: 无打回项。P3 观察（不阻塞，挂账）：①Zone build 内自动完结落成就副作用写库（_finishingIds 幂等防重在位）=挂账"第三张卡再现则升规范提案"条件达成→周一素材册正式列册；②REQ 新增数 28/实测 29、home_page +2/+4 两处措辞口径无实害；③自设 UI 承接条款未写入 SB-019 卡文（随 D2 拍板处理）。

模拟器冒烟: 待本轮补跑回填（簿记三件套先行落库，半截事故防御新序）。

合入舞步: squash@main（本轮提交后回填 hash）；feat 分支删前树等同核对（feat..main diff app/golden=0 行实测）后 -D 清理；卡真 `git mv` 归档 docs/tasks/done/SB-018.md，状态行已改验收通过。

利益点自省: 更近——每月一个 7 天小实验=行为改变成本压到"选一个+每天 3 秒"，断卡不罚只如实显示、省出肉眼进目标与成就，得到框架零负罪；打卡即传感器，不要求任何全量记账。连续计数：SB-017 更近第 1 次→本轮更近第 2 次，无 SilentBook 旧病同构（机制兜底=不打卡实验照常完结记 0）。SB-019 联动时复核实验卡真实开启率/打卡率。

漂移与一致性审计（真实回显，口径=app/lib+app/test）: 禁词(没省|又花|喝掉|罪恶|浪费钱)零新增（命中全=成就表本体+goal_ladder 自警+测试断言基线）；theme/motion 外裸 Color(0x=0、Duration(milliseconds=0；美团|工资|房贷=0；_LOCK find=0；remote=0；合入后 feat 残留=0（仅 main）；task_plan 薄索引只读声明在位；progress.md 唯一真相 ✓。REQ 假新信号排查：本轮 mtime 新且内容实读为 SB-018 面，非 touch 假信号（素材⑧口径）。

下一步: ①冒烟补跑+回填 REVIEW+更新快照 last_smoke_commit；②09:45/10:15 wake 应派 SB-019 或 SB-020（SB-012 前置 019/020 未满足）；队列：待办 SB-012,019,020 共3+SB-021 挂起 v0.2，done/=17，>2 无见底提醒；③待浩然回音：本轮 D2 灰区（A/B 拍板，已发简报）+SB-015 D2 首页接线灰区+SB-014 双灰区+changelog_defer 不三提；④明日周一首轮出规范适配审查（素材册含⑫Zone build 副作用升规范提案）。
