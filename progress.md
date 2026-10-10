# progress.md

- 2026-10-09：建仓 + 确定协作模式（我开发，openclaw 自动巡检当监工）。等待需求输入。
- 2026-10-09：收到 `_inbox/` 6 份（PRD/宪法/DEV/GIT/DESIGN/SB-001），已搬运到 `docs/`（只搬运不改内容）。G0 已过闸。
- 2026-10-09 SB-001：分支 `feat/SB-001-repo-ci`，`flutter create app`（name=runway）成功，`tool/ci.sh` 四闸门全绿（format / flutter analyze / test / build macos debug），`tool/check-repo-hygiene.sh` OK。待监工首审。
- 2026-10-09 改名去中文：仓库 `Documents/攒够` → `Documents/runway`（产品名不变），`flutter analyze` 原生通过（1.1s No issues found），D1 关闭。注意：openclaw 侧「攒够-监工巡检」cron 里还是老路径，需更新。
- 2026-10-09 SB-001 PASS 已 squash 合入 main（`d6ef4da`，141 文件），feat 分支已删。headless 通路已通（模型切 Muse Spark，PONG ✓），唤醒任务「攒够-loop唤醒」:15/:45 就位。
- 2026-10-09 loop bootstrap：分支 `chore/loop-bootstrap` 落 `LOOP.md` + SUPERVISOR 附录，待合入；合入后等 SB-002 发卡，环即转动。
- 2026-10-09 deep-grill 审计 LOOP：三次 headless 实测（读/写删/提交皆通、工作区外全拒）+ 规范全文对照， verdict 条件通过。R1/R2/R3/R4/R7/R8 已改；R5 浩然授权自动合入；P1 分支名待监工裁决。
- 2026-10-09 watchdog 就绪未上线：launchd 实测不可行（TCC 拒读 ~/Documents，复现×2，plist 已删），改挂 openclaw cron `runway-watchdog`；但网关正离线升级（cron add 建不上），待老油条回来建，命令已备好。`tool/loop-watch.sh` 为等价手动入口。
- 2026-10-09 SB-002：分支 `feat/SB-002-android-build`，Android工具链✓（SDK 36.0.0/JDK17），`tool/ci.sh` build闸门扩到macOS debug+APK debug双产出，四闸门全绿，hygiene OK。待监工审计。
- 2026-10-09 SB-003：分支 `feat/SB-003-tokens`，设计token落地（tokens/motion/theme三件套+main挂接），tokens单测9项+golden2组全绿，CI四闸门全绿（format/analyze/smoke/build双平台），hygiene OK。待监工审计。
- 2026-10-10 SB-004: 分支 `feat/SB-004-quick-add`, 三秒记一笔+schema v1（data/logic/ui/tests齐备）, widget测试修好（键作用域+大视口）, entry7+widget3+golden3+回归11全绿, CI四闸门全绿（format/analyze/smoke/build双平台）, hygiene OK。待监工审计。
- 2026-10-10 SB-004 返工第1轮 done：问题1 widget_test重写主屏真实冒烟（旧计数器删），问题2 _edit加StatefulBuilder即时回显+note.dispose+编辑改类目widget测试；`flutter test`全量27绿，`tool/ci.sh`四闸门全绿，hygiene OK。commit `1bf8f73`。待监工第2轮审计。
- 2026-10-10 SB-005: 分支 `feat/SB-005-rule-engine`，规则引擎自动归类（179 条内置规则：关键词/商户/latin别名/金额区间消歧）+纠正回写（会话内存）+其他占比供数+类目管理页（Hero占比卡/六类目合计/纠正入口/建议提示）；单测14+页测3+golden2组+对比度闸门，全量47绿，`tool/ci.sh`四闸门全绿，hygiene OK。commit `fa029f8`。待监工审计。
- 2026-10-10 SB-006: 分支 `feat/SB-006-dashboard`，首页看板四区（Hero本月/今日/Top5/目标引导）+聚合逻辑dashboard_stats（今日/滚动7天/自然月/Top5/其他故障/目标进度，旧名归一，1万条聚合<1s）+dashboard_cards组件；单测5+页测2+golden4组+对比度闸门，全量59绿，`tool/ci.sh`四闸门全绿，hygiene OK。待监工审计。
- 2026-10-10 SB-007: 分支 `feat/SB-007-goal-ladder`，目标阶梯与实物换算（goal_ladder引擎：内置奶茶/键盘/手机/5090单价+基线多省/环比增量口径+得到框架文案）+schema v2（goals表：name/target/单价/tier/doneAt，v1→v2迁移+rollbackGoalsToV1）+目标设定页CRUD+GoalProgressCard（复用DashboardGoalCard，闭环SB-006 D1）+首页目标卡点击进目标页（零像素改动，SB-006 golden零回归）；单测17+widget3+golden4组+对比度闸门，全量84绿，`tool/ci.sh`四闸门全绿，hygiene OK。commit `8092cfc`。待监工审计。
- 2026-10-10 SB-008: 分支 `feat/SB-008-achievement`，成就卡与解锁庆祝（achievement解锁检测：可换算>=目标即解锁+会话去重+错过补弹一次）+schema v3（achievements表：goalId/goalName/target/convertible/tier/unlockedAt，v2→v3迁移+rollbackAchievementsToV2，达成回写goals.doneAt/tier闭环SB-007 D4）+成就弹层1200ms走MotionSpec+收藏页序列+截图导出无新依赖；单测12+widget/golden11+对比度闸门，全量107绿，format/analyze/hygiene OK。commit `c057eeb`。待监工审计。
- 2026-10-10 SB-009: 分支 `feat/SB-009-safety-weekly`，安全垫与周报（safety_report引擎：月均×月数+周报聚合，复用SB-007换算/禁词无第二套）+schema v4（safety_pad配置+weekly_reports缓存+rollbackSafetyWeeklyToV3）+安全垫卡同区展示+周报页（周一自动落库幂等+手动兜底）；单测15+widget/golden11+对比度闸门，全量133绿，format/analyze/hygiene OK，build双平台成功；SB-007 golden 4张重生成（同区非零像素，CRUD加滚动）。commit `dc70a16`。待监工审计。
- 2026-10-10 SB-010: 分支 `feat/SB-010-notify-collect`，Android通知监听待确认采集（PendingListenerService+通道runway/notify_collector+解析notification_parse复用SB-005引擎+待确认页逐条确认/批量默认关）+schema v5（pending_records结构化-only+rollbackPendingToV4，去重insertPendingDedup+一键入账confirmPending走SB-004通道source=notify）；单测15+widget/golden9+对比度闸门，全量157绿，format/analyze/hygiene OK，build双平台成功；SB-006 golden 4张重生成（待确认入口图标致位移，零像素外改动）。commit `7a0291f`。待监工审计。
- 2026-10-10 19:48 watchdog: 清死锁——仓库根 `_LOCK`（PID 61632 已 ps 核实死亡，SB-010 18:18 崩溃轮残留，监工 18:30 巡检轮预授权"watchdog ~19:47 按③清死锁"）已删。观察：树上有活跃返工改动（PendingListenerService.kt/notification_parse.dart mtime≈19:48）=SB-010 第1轮 REQUEST_CHANGES 返工进行中，watchdog 按 S0"有人在干活不抢"零接触；额外核查过：main 最近 feat 合入 4227244(SB-009) 有归档轮 5d02452，未审先合=否。①④⑤⑥全过，本轮仅此一件，退。
- 2026-10-10 SB-010返工第1轮 done：问题1去重键SHA-1哈希化（Dart纯实现+Kotlin MessageDigest同口径，UTC纪元分钟桶，值级单测+标准向量已知答案锁定）+问题2 Kotlin金额BigDecimal HALF_UP（8.20→820）+观察项merchant统一32；全量160绿（157继承+3新增），format/analyze/hygiene OK，ci.sh四闸门全绿。commit `84f47c6`。待监工第2轮审计。
- 2026-10-10 SB-010 R4熔断WAITING_HUMAN done：REVIEW累计2次REQUEST_CHANGES（第1轮P1全修已验+第2轮纯由main@d6ae1ab新验收4驱动），按LOOP S1.1停手；分支`feat/SB-010-notify-collect`零代码改动，待浩然拍板R4豁免A/B。
- 2026-10-10 21:00 SB-010 R4熔断WAITING_HUMAN处理轮：监工核实零代码熔断合规（决策p=0.84；打回诱因=规范中途变更非builder失职，决策p=0.15）；唤醒任务 disable（enabled:false 实测）待浩然拍板 A/B 后恢复；清理 app/_LOCK 死锁 75806（上轮漏报更正）；不合入不冒烟；R4 计数维持 2/2。

- 2026-10-10 21:0x SB-010 裁决落地：浩然 A=豁免，R4 解除，第 3 轮（末轮）返工放行；唤醒任务重建。[SB-010]
- 2026-10-10 21:30 巡检轮：裁决A落地实核（3ec223b 在 feat tip，REVIEW/REQ/progress 三处回显）；唤醒重建实测 enabled（e576d0b9，21:45 接班 R3 末轮）；done/ 自验 9 张真归档；队列 12 张待办无变化；4227244 后零代码→不重烟，last_smoke_commit 推进 docs 头 d6ae1ab；唤醒文案 task_plan 过时指针经决策p=0.84 判定后 cron edit 机械修正；漂移审计全绿。[SB-010]
- 2026-10-10 22:15 builder 第1轮完成（重建后，唤醒e576d0b9接班），待巡检。实况：exit 0 但系 S0.2 分支守卫命中（当前分支 feat/SB-010-notify-collect ≠ main）——builder 读 LOOP.md 字面守卫直接退，未创锁未动文件，R3 末轮返工未开工； wake 文案『在审卡返工中→checkout feat』与 LOOP S0.2『非 main 即退』存在设计冲突，照此每轮都会空转，需监工裁决（建议：S0.2 加在审返工豁免，或 wake 保持 main 由 builder S1 自切 feat）。
- 2026-10-10 22:40 巡检轮：SB-010 R3 死锁已裁——wake 预切 feat 与 LOOP S0.2 冲突解除（决策p=0.82，监工自有文案+opencode 入参豁免句，状态机本体未动、备查段同步）；builder 22:15 实况行入库；22:45 唤醒跑 R3 末轮，下轮逐条验提审并撤豁免句。[SB-010]
- 2026-10-10 22:50 SB-010返工第2轮(R3末轮) done：merge main取新卡d6ae1ab，按验收4身份三元组key(pkg|tag|id)+when毫秒+内容哈希重做去重（when缺失回退postTime秒）；Kotlin sbn.tag/id/when/postTime+extras补传身份，Dart键体预镜像三元组化，第1轮SHA-1/BigDecimal/merchant32保留；新单测3（不同when留2/三同重投仅1/回退生效）+风暴按新语义复核，全量163绿，ci.sh四闸门全绿，hygiene OK。commit `267c125`。待监工第3轮审计。
- 2026-10-10 22:53 builder 第2轮完成（22:45 唤醒，SB-010 R3 末轮返工已交付提审 ead5df1，exit 0、_LOCK 已清、树净），待巡检。[SB-010]
- 2026-10-10 23:1x 监工第3轮(末轮)审查：SB-010 PASS（独立实测 163/163 绿+SHA python 对拍+Kotlin/Dart 镜像同构+3 新单测语义+第1轮修复项不回退+golden 目审通过；决策模型本轮无边界裁决项未触发）。squash 合入 main@7d171d0（树与 feat tip 55760d5 全等，diff=0）；模拟器冒烟 PASS（23:12-23:13 实测：apk ✓Built→install Success→am start→40s pidof=3869 存活→FATAL 主+crash 双 buffer=0）；卡真 git mv 归档 done/；wake 豁免句本轮撤销+LOOP 备查段同步；队列：SB-011~021 共 11 张待办（>2 无提醒）。[SB-010]

- 2026-10-10 23:26 浩然拍板两件：①命名定『今日攒出』→SB-016 增补每日反馈验收+PRD 攒到层加日频口径（『天天』承诺自此有卡承接）；②SB-021 时间望远镜摘出 v0.1 挂起 v0.2→SB-012 前置由 8 张缩至 SB-014~020 7 张。[SB-012][SB-016][SB-021]
- 2026-10-11 00:00 巡检轮：无新提审（REQ mtime 1791645469 < REVIEW 1791646453）。SB-011 开工实况核验闭环（feat 已切+WIP 7 文件+golden 四图 23:55~58，无 commit 未提审，非空转）；⚠️ 23:45 wake 状态=error（cron 实回显），00:15 轮观察续做，连续失败升级 watchdog。队列待办十张（>2 无提醒）；7d171d0..main docs-only 不触发重烟；漂移审计全绿；三件套无过时项。[SB-011]
- 2026-10-11 00:15 唤醒轮·续做观察结论=23:45 builder 崩溃留 WIP：feat/SB-011-bill-import 在切（tip=6541216 无自带 commit）、9 项未提交（最后写 23:59:55）、无 _LOCK、无 opencode run 进程、15+min 零活动——builder 已死。本轮不启动 builder（S0.2 非 main + S0.4 脏树必空转，不烧 token、不写假完成行）；不改 REVIEW_REQUEST.md（防 mtime 翻转到新于 REVIEW 造成假待审信号，异常登记以此 progress 行为准）。按 00:00 巡检预案『连续失败升级』条件已成立（23:45 wake error + 00:15 无进展）：提请监工下轮裁决 SB-011 WIP 处置（续做/重派/清理），WIP 文件本轮零接触原样保留。[SB-011]
- 2026-10-11 01:0x 监工巡检轮·SB-011 崩溃 WIP 处置：连续失败升级条件成立（23:45 wake error+00:15/00:45 守卫空转）→ decision_evaluate wip_disposal p=0.88≥0.75 判 A=弃 WIP 重派。执行：WIP 10 项原样归档 runway-crash/sb011-20261011-0100/ → checkout/clean 净树 → 回 main → branch -d feat/SB-011-bill-import（tip 6541216 已并入 main 历史）→ SB-011 保持待办，待 01:15 wake 常规重派。00:15 wake 观察行（原系未提交）已原样誊入本册防丢记录。漂移审计全绿详见 REVIEW.md 01:00 轮。[SB-011]

- 2026-10-11 01:4x LOOP.md 新增 S0.1 崩溃现场续做（浩然 01:35 批准）；SB-011 续做授权已签发（只修最后 1 条 widget 测试），现场保全提交 5f5ab9e。[SB-011][LOOP]
- 2026-10-11 01:46 撤 01:30 轮『挡窗锁』：该锁 pid 1021 实为常驻 MCP 进程（永不判死），处置 A 已全部落地（5f5ab9e 现场保全 + 8440ecd S0.1+续做授权，REVIEW.md 最新段即授权），留锁将使每轮 wake 误判『另一轮在跑』永久停摆。目的已达成，按 A 语义清除。[SB-011][LOOP]
