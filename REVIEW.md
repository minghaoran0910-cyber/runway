---

# REVIEW — 2026-10-10 23:1x 审查轮 · 第 3 轮（末轮）· 卡 SB-010
结论: PASS

触发: mtime REVIEW_REQUEST=1791643915（23:05 提审）新于 REVIEW=1791643170 → R3 末轮审查。分支 feat/SB-010-notify-collect tip `ead5df1`；返工 commit `267c125`（stat 实测 6 文件：MainActivity 7 行/Service 60/parse 67/pending_page 29/identity_test 136 新增/parse_test 80 改；未触 app_db.dart/pubspec）；基座 `84f47c6` 在位（git log 实测）；merge-base=d6ae1ab（已取 main 新验收4）。

检查项（监工本轮独立实测，非采信申报）:
- [x] 验收4 身份三元组：Kotlin `makeNotifyKey`（实测 44-59 行）when≥1e12 可信 → SHA-1(包|tag|id|when毫秒|内容哈希)，回退 → SHA-1(包|tag|id|内容哈希|postTime秒)；Dart 镜像（notification_parse.dart 63-90 行）同构同口径；阈值两侧一致（`WHEN_MS_THRESHOLD=1000000000000L`/`notifyWhenMsThreshold=1000000000000`）；分钟桶零残留（grep『桶』仅注释『废时间桶』声明）
- [x] extras 身份补传：Service Intent 含 tag/notifId/whenMs(0L 缺省)/postTimeMs/contentHash（实测）；MainActivity 五键全转发 Dart（实测 35-39 行）；whenMs=0 → isTrustedWhenMs=false 正确走回退；occurredAt when 可信优先否则 postTime（两侧实测）
- [x] 卡要求 3 单测在位且语义正确（identity_test 全文实读）：①同商户同金额不同 when→异键+DAO 实测留 2 条 ②三同重投→同键+id1==id2+仅 1 条 ③回退路径（同秒同键/跨秒异键/秒级 when 走回退/40-hex 形状）；风暴复核=50 条 tag/id/when 各异→50 互异键不丢（parse_test 实测断言）
- [x] SHA 对拍（python hashlib 本轮独立复算）：`||0`→d2abfc06…✓、`a|b|99`→ebadb7a4…✓、身份向量（com.eg.android.AlipayGphone|店|1000分|tag''|id0|when=1760000000000）→edc5af55eef780e31fb2cf3a0ddbfee986f21aeb 与测试锁定值完全匹配 ✓
- [x] 第 1 轮修复项不回退：BigDecimal HALF_UP 实测在位（movePointRight(2).setScale(0,HALF_UP).intValueExact）+8.20→820 双侧镜像单测实测；merchant 32 两侧统一（Kotlin take(32)/Dart substring(0,32)）；§5 键体哈希化在位（app/lib grep raw_text/rawText 实测零命中，标题原文不入键不入库）
- [x] 闸门独立复跑：`dart format --set-exit-if-changed` exit=0；`flutter analyze --fatal-infos --fatal-warnings` No issues；`flutter test` **163/163 All tests passed**（本轮真实回显，含 golden/对比度/禁词 grep 断言）
- [x] 文件约束实测：Service 112/MainActivity 89/parse 223/pending_page 392/parse_test 363/identity_test 136 行全部≤400；业务改动文件 6≤10；无 remote（wc -l=0）、无 _LOCK（根/app 双侧实测不存在）；Manifest service exported=false+BIND_NOTIFICATION_LISTENER_SERVICE（diff 实测）
- [x] 红线 grep：禁词(没省|又花|喝掉|罪恶|浪费钱)命中=禁词表本体+注释自警（与 22:40 轮同回显，零新增，历史先例判合规）；ui/theme 与 motion_spec 之外裸 Color(0x/Duration(milliseconds:=0（实测空回显）；『全自动』仅禁令声明行；测试全合成 fixtures，真实账目=0
- [x] golden 目审（本轮监工实看图）：sb010 待确认列表 Light/Dark 数据态——标题/批量开关行/条目金额/确认按钮完整、浅底深字与深底浅字正确、无乱码无重叠无异常色块（右上红白斜带=标准 debug banner）→ 通过

问题列表: 无打回项。观察（不阻塞）：①风暴『不卡』性能维度未实测（纯函数毫秒级，UI 渲染由 golden/widget 覆盖）；②ci.sh 四闸门 builder 申报 ALL GREEN，监工独立复跑三门（format/analyze/test）+APK 构建闸由冒烟实测覆盖，macOS 闸未独立复跑；③sb006 四图更新系 home_page 待确认入口重绘（第 1 轮基座带入，本轮 golden 绿含回归）；④卡内『审计结论』行为 builder 回填的第 1 轮结论（事实记录非规范改动）；⑤service exported=false 运行时 dumpsys 验证仍留 watch（冒烟未授通知权不绑定 service）。

模拟器冒烟: **PASS**（本轮真实回显，23:12-23:13，监工自跑）：JAVA_HOME=openjdk@17；`flutter build apk --debug`→『✓ Built build/app/outputs/flutter-apk/app-debug.apk』（Gradle assembleDebug 2,725ms）；runway_api36 起→sys.boot_completed=1；`adb install -r`→『Success』；`am start -n com.zangou.runway.runway/.MainActivity`→『Starting: Intent』；40s 后 pidof=3869 存活；logcat -d FATAL EXCEPTION=0、crash buffer FATAL=0；用毕 pkill emulator（pgrep 实测空）。

决策模型记录: 本轮无边界裁决项——4b 已知边界为卡文（d6ae1ab 浩然思路+监工定稿）内产品决策留痕，1e12 阈值为实现细节且被注释+单测锁定，均非新裁决，decision_evaluate 未触发。

下一步: 按合入授权（R5）squash 合入 main → 卡真 git mv 归档 done/ → 撤唤醒豁免句（22:40 裁决既定动作，R3 已审结）+LOOP.md 备查段同步 → 队列快照推进（SB-011 起 11 张待办，>2 无见底提醒）。末轮 PASS 结案，R4 计数终止。

利益点自省: 身份去重把『不漏一笔真账、也不吞一笔』建进传感器层，异常由待确认池一键消化、用户零自律负担——记账更无感而账户更可信，更近。

漂移与一致性审计: 禁词 grep=禁词表本体+自警注释（先例合规，零新增）；theme/motion_spec 外裸 Color(0x/Duration=0；feat 仅 SB-010 在审非残留；main 头 d6ae1ab=last_smoke_commit（docs 头）无未审先合；_LOCK 双侧不存在；progress.md 唯一真相在位（builder 22:53 行本轮随审入库）；task_plan.md 薄索引未动（非真相，合规）；无 remote；真实账目数据=0。

---

---
# REVIEW — 2026-10-10 23:3x 巡检轮（无新提审）
结论: 无审查动作（REVIEW_REQUEST mtime=REVIEW mtime=1791645469，23:1x 轮结案后无新提审）。队列无变化（docs/tasks 实测 SB-011~021 共 11 张待办，>2 无见底提醒；done/ 10 张）。main 头 fb4eae1 系 docs/chore（LOOP 备查段同步），按 23:1x 轮判定不触发重烟（last_smoke_commit=7d171d0）。
检查项:
- [x] 三件套提示词新鲜度（本轮实拉 cron get 回显）：wake 文案卡号通用引用 docs/tasks 状态行+task_plan 薄索引禁令在位、豁免句已撤（标准文案）、applicationId 未硬编码、路径全为 runway；runway-watchdog 文案 LOOP 驱动无过时参数；统一看门狗 rc 分流口径现行。未发现需 edit 的过时项。
漂移与一致性审计: 禁词 grep 命中 4 全为合规本体——achievement.dart:12 禁词表数据行/goal_ladder.dart:7 自警注释/goal_ladder_test.dart:127 测试断言/DESIGN_SYSTEM.md:86 规范条文，零新增违规；ui/theme+motion_spec 外裸 Color(0x=0、Duration(milliseconds=0（app/lib 实测路径）；_LOCK find=0；git branch -a 仅 main（无 feat 残留、无 remote）；main 头 fb4eae1 对应 REVIEW 末轮归档后的 LOOP 同步 commit，无未审先合；progress.md 唯一真相（23:1x 结案行在位）、task_plan.md 薄索引只读声明在位；真实账目数据=0（测试全合成 fixtures）。
观察: wake(e576d0b9) 23:15:00 实跑 ok/77s/静默——与监工末轮合入归档竞态（cron 豁免撤销落库 23:19:53、REVIEW/REQ 文件被 git 操作 touch 于 23:17:49），故 SB-011 未开工（无 feat/SB-011 分支、progress 无 builder 行）。23:45 wake 按通用逻辑应派 SB-011；下轮巡检核开工实况。『合入归档期间 wake 撞窗』列周一规范适配审查素材（错峰 :15/:45 设计在监工轮超时时失效）。
决策模型: 本轮无边界裁决项，未触发。
利益点自省: 巡检守住环轨、派活链验证到只差 SB-011 开工——传感器循环离『天天可见挪一步』更近一步，更近。
下一步: 等 23:45 wake 派 SB-011→提审后常规审查；周一(10-12)首轮附【规范适配审查】（素材已积：_LOCK 路径口径/LOOP crashed-builder 态/WAITING_HUMAN 分支/wake 撞窗错峰条款等）。

补记(同轮 23:3x)：监工提交落库时发现 main 新增 4584c39（浩然 23:26 双拍板，23:33 入库）——SB-021 摘出 v0.1 改『挂起 v0.2』、SB-016 验收 5『今日攒出』增补、SB-012 前置缩至 014~020（卡文 grep 实测回显）。待办队列实为 10 张（SB-011~020），>2 无提醒不变；4584c39 与本头均 docs-only，不触发重烟（last_smoke_commit=7d171d0 维持）。快照已修正。

---
# REVIEW — 2026-10-11 00:00 巡检轮（无新提审）
结论: 无审查动作（REVIEW_REQUEST mtime=1791645469 早于 REVIEW.md=1791646453，SB-010 结案后无新提审）。队列无变化（docs/tasks 实测 SB-011~020 十张待办 + SB-021 挂起 v0.2，>2 无见底提醒；done/ 十张）。
检查项:
- [x] SB-011 开工实况核验（上轮观察项闭环）：23:45 wake 实派成功——feat/SB-011-bill-import 已切（base=main@6541216）、WIP 实测 app_db.dart/.g 修改 + import_batch/bill_import/import_page/bill_import_test/golden_import_test 新增 + docs/ios-shortcuts.md + golden/sb011 四图（文件 mtime 23:55~23:58 实时写入）；feat 无 commit（log main..feat 空回显）、未提审。上轮"23:45 应派 SB-011"观察项就此闭环：非空转。
- [x] ⚠️ wake 23:45 轮次状态=error（cron list 实回显，非推测）：会话产出上述 WIP 后异常收尾（最后文件写入 23:58:27，监工 00:01 复核无 opencode 活跃进程、仅 kotlin daemon 驻留）。00:15 wake 轮观察其是否续用 feat 现场；LOOP 缺 crashed-builder 续做状态（已在周一素材册），连续失败或 feat 滞留将升级 watchdog 关注。按通知收口条款属常规运行观察，不推送。
- [x] 冒烟判定：git diff --stat 7d171d0..main 实测 8 文件全为 .md（LOOP/REVIEW/PRD/任务卡/progress/done 归档），docs-only 不触发重烟（last_smoke_commit=7d171d0 维持）。
- [x] 三件套提示词新鲜度：cron list 实拉——本巡检 */30、wake 15,45、runway-watchdog every 2h、需求反思 21:30 参数均现行；wake 文案上轮已实查（卡号通用引用 docs/tasks 状态行、豁免句已撤、路径 runway），30 分钟窗口内无新过时项，无需 edit。
决策模型: 本轮无边界裁决项（wake error 属运行观察非裁决），未触发。
利益点自省: SB-011 账单导入=把"零手工录入"的传感器管线真正建起来（golden 预览/结果四图已出），用户看见的是"账单自己流进攒够目标"——更近。
漂移与一致性审计: 禁词 app/lib+test grep=3 与上轮完全一致（achievement.dart:12 禁词表本体/goal_ladder.dart:7 自警注释/goal_ladder_test.dart:127 断言），零新增；theme/motion_spec 外裸 Color(0x=0、Duration(milliseconds=0（main 实测）；_LOCK tree=0；分支=main+feat/SB-011（在审非残留）；main 头 6541216 系监工巡检 docs 头，无未审先合；SB-011 WIP 未入库文件留待提审轮全量审查；无 remote；真实账目 grep(美团|工资|房贷|余额+数字)=0；progress.md 唯一真相在位、task_plan.md 薄索引未动。
下一步: 00:15 wake 观察 SB-011 是否续做/重做 → 提审后常规审查（重点：WIP 7 文件静态检查+golden 目审+真实账目红线 grep+ci 闸门复跑）。

# REVIEW — 2026-10-11 01:00 巡检轮（SB-011 崩溃 WIP 裁决与清理重派）
结论: PASS（本轮无新提审——REQ mtime 1791645469=23:17:49 早于 REVIEW，非审查轮；监工处置轮记录）
检查项:
- [x] 队列核对：docs/tasks SB-011~020 待办+SB-021 挂起 v0.2，与上轮快照一致零变化；待办十张>2 无排卡提醒。
- [x] 崩溃现场核验：feat/SB-011-bill-import tip=6541216 零 commit、9 项 WIP 最后写 23:59:55、无 _LOCK、无 headless 进程——与 00:15 wake 诊断一致，builder 23:45 error 后已死；00:45 wake 正常按守卫 skip（ok suppressed 非失败）。
- [x] 决策模型二意见：wip_disposal boolean（A 弃WIP重派 vs B 特赦救援轮 vs C stash 封存），status=ok，probabilityTrue=0.88≥0.75 → 按判落 A，决策p=0.88 标注。
- [x] A 执行实证：WIP 10 项+工作树版 progress.md(36行) 原样归档 ~/.openclaw/workspace/memory/runway-crash/sb011-20261011-0100/；checkout -- + clean -fd 后 status 净；checkout main；branch -d feat/SB-011-bill-import；branch -a 仅剩 main。
- [x] 重派可达性：S0 守卫将全过（main✓/_LOCK 本轮收尾删✓/净树✓/REQ 旧✓/无 WAITING_HUMAN✓），01:15 wake 按第2步『未开工卡→基于 main 新建 feat』重做 SB-011。
问题列表:
1. [非阻塞记录] 崩溃 WIP 含 docs/ios-shortcuts.md（builder 伸向 docs/ 禁区边界）——已弃不究；重派轮若再现 docs/ 新文件，审查轮按 DEV/GIT 规范裁决。
2. [环缺口] LOOP.md 无 crashed-builder 处置路径（WIP 悬空只能监工手裁）——本轮为首例实操，补态条款素材入周一规范适配审查（清单在案）。
下一步: 01:30/02:00 巡检核实 01:15 wake 是否开工（feat/SB-011-* 重切+_LOCK/progress 行）；再失败则按升级链请浩然拍板。冒烟不触发（last_smoke_commit=7d171d0，7d171d0..main 仅 docs 变动）。
决策模型: 本轮触发 1 项（wip_disposal=0.88，判 A，已按判执行）。
利益点自省: 本轮清掉悬空残骸让账单导入传感器管线以零污染状态重来，用户侧的『账单自己流进目标』更近（重派即续）；无更远风险项。
漂移与一致性审计(01:00轮): 禁词 app/lib+test grep=3 与基线完全一致（achievement.dart:12/goal_ladder.dart:7/goal_ladder_test.dart:127 合规本体）零新增；theme/motion_spec 外裸 Color(0x=0、Duration(milliseconds:=0（清理后 pristine main 实测）；_LOCK=本轮收尾即删无泄漏；分支=仅 main 无 feat 残留；main 头 1ec0e00 对应 REVIEW.md 00:00 归档轮无未审先合；SB-011 待办卡在册、done/ 十张完好；无 remote；真实账目 grep=0；progress.md 唯一真相在位、task_plan.md 薄索引未动。


## 唤醒轮指令·监工签发 2026-10-11 01:4x（SB-011 续做授权 · round 1 · S0.1 生效）
- 结论：CONTINUE_PERMIT——适用 LOOP.md S0.1；分支 = `feat/SB-011-bill-import`；崩溃现场已保全（WIP 提交 5f5ab9e：数据层/解析/去重/批次撤销/性能实测223ms/单测7绿/golden 四图全在其中），两分支工作树均净、REVIEW.md 最后 touch。
- 本轮范围（只修测试，禁止推倒重来）：`app/test/bill_import_test.dart` 仅剩 1 条红：widget 测试『坏路径给提示』。以最小 diff 修页面坏路径提示或其测试匹配，二者择其一贴合卡文义+DESIGN_SYSTEM 令牌。禁改已完成的数据层/解析/去重/撤销逻辑；golden 基线如受影响须列出供监工目审。
- 环境红线（本卡事故根因，必须遵守）：调试探针只能写入仓内 `_inbox/` 或 `probe*.tmp`（退出前删除），绝不写 `/tmp`——再碰即算铁律违规。
- 完成出口：`tool/ci.sh` 四闸门+hygiene 全绿 → 更新 progress.md → 写 REVIEW_REQUEST.md 提审（含验收对照+偏差声明，标注『应答续做授权』）。修不好出口：回滚本轮新增改动（WIP 提交 5f5ab9e 不许动），在 REVIEW_REQUEST.md 登记一行阻塞原因后退场——授权消耗，不再补发，巡检将按常规轮处理。
- 后续：本段被提审/退场登记覆盖即失效；监工 :00/:30 轮照常审查。

---
# REVIEW — 2026-10-11 02:30 巡检轮（无新提审·SB-011 mtime 假信号复核解除）
结论: 无审查动作。REQ mtime 1791654588(01:49:48) 新于 REVIEW 1791654398(01:46:38) 系假信号——REQ 内容与 HEAD 已提交版本零差异（git diff HEAD -- REVIEW_REQUEST.md 实测 0 行；正文仍系 SB-010 已结案提审文本+监工 01:4x 已应答的异常登记行+续做授权指令），mtime 为 01:40~01:49 授权落库 git checkout/merge 触写副作用。无新提审。
检查项:
- [x] builder 两轮被拦实况复核（01:51/02:15 progress 实登行）：均 S0.5 命中同一假信号、零改动零建锁 exit 0；本轮 pgrep 实测无 headless builder 进程（仅 OpenCode 桌面常驻 helper），无在途施工，解除拦阻无竞态。
- [x] 授权状态裁决：decision_evaluate 本轮已调用，status=unavailable（transport 错误实回显）→记『决策模型不可用』按原流程人工判：**SB-011 续做授权未消耗、仍有效**（S0.1 消耗条件=实际施工尝试或失败出口登记，两轮均在守卫前置退出，均未发生）。本段写入即刷新 REVIEW mtime 基准，02:45 wake S0.5 应放行，按授权原范围施工：只修 golden_bill_import_test『空粘贴与坏路径给提示』1 条红 widget 测试；探针禁 /tmp；失败出口按授权原条款（登记退场、授权消耗不再补发）。
- [x] 队列核对：docs/tasks 实测 SB-011~020 十张待办 + SB-021 挂起 v0.2；SB-011 状态行=待办（批次 G4 第 2 张）。done/ 10 张。待办十张>2 无见底提醒，与快照零变化。
- [x] 冒烟判定：git diff --name-only 7d171d0..main 实测非 docs/golden 文件 0 行 →docs-only 不重烟（last_smoke_commit=7d171d0 维持）。SB-011 代码仅在 feat（5f5ab9e 保全 WIP），提审后监工全量审查+重烟。
模拟器冒烟: 未触发（main 无新代码合入）
下一步: builder 02:45 按授权施工→提审→监工全量审（重点：widget 测试修复方案合规/6 文件约束/ci 四闸门/golden 目审/真实账目红线）。
漂移与一致性审计: 禁词(app/lib+test)=3 与基线完全一致（禁词表本体/自警注释/断言），含 SB-011 WIP 零新增；theme/motion_spec 外裸 Color(0x/Duration=0（feat 工作树实测）；_LOCK 双侧不存在；分支=main+feat/SB-011（授权点名在审非残留）；main 头 91b5efc（01:4x 监工 progress 登记行）对应 REVIEW 01:4x 归档轮，无未审先合；无 remote；真实账目 grep=0；progress.md 唯一真相（builder 两轮未提交登记行随本轮监工提交入库防半截丢失）；task_plan.md 薄索引未动合规。
利益点自省: 更近——两轮空转的续做授权经 mtime 基准复位解除拦阻，账单导入传感器（零手工录入）重回施工轨道。

---
# REVIEW — 2026-10-11 03:4x 审查轮 · 第 1 轮 · 卡 SB-011
结论: PASS（应答 01:4x CONTINUE_PERMIT · S0.1 续做授权轮提审）
检查项:
- [x] 授权范围核验：`git show 1c96f81` 实测唯一施工 diff=`app/lib/ui/bill_import_page.dart` 1 行（`await f.exists()`→`f.existsSync()`），另 2 文件系 REQ 重写+progress 登记；授权文『以最小 diff 修页面坏路径提示或其测试匹配，二者择其一』——builder 择页面侧，字面在授权内，数据层/解析/去重/撤销零触碰；根因陈述（setState 空窗期断言 0 命中）与页测『空粘贴与坏路径给提示』断言吻合，本轮实测绿
- [x] 全卡面首审（WIP 5f5ab9e 部分本轮全量审）：业务 9 文件≤10、手写最大 app_db.dart 399≤400（app_db.g.dart 4819 系 drift 生成除外）；schemaVersion=6、v5→v6 迁移=import_batches 表+transactions.importBatchId 可空列，与卡『授权声明』逐字吻合、存量不动可回滚；pubspec diff=0 行（零依赖变更，卡约束合规）；docs/ios-shortcuts.md 系卡文『涉及模块』点名随卡交付物（01:00 轮"builder 伸 docs/ 边界"疑虑就此闭环），『全自动』全文 1 处=禁令声明行本体
- [x] 验收 1 解析：支付宝 fixture 3 成功+2 失败（行 4 金额无效/行 6 非成功状态，行号+原因，不整体失败）、微信 ￥单位 3200 分+对方为空失败行（行 3）、类目映射食/行、时区字段断言实测；1 万行 failures=isEmpty
- [x] 验收 2 去重+撤销：两次导入 inserted 3→0/skippedDup 3/落库 3 条；dedupKey=日期天+金额分+对方（卡口径）；note 无逗号+source='import'+importBatchId 挂链（§5 原文不入库）；revokeImportBatch 整批清零（transactions+批次）；widget 确认入账→结果→撤销本批绿
- [x] 验收 3 性能：监工本轮独立复跑实测回显 `SB-011 perf: parse=132ms total=225ms rows=10000`（<5s；builder 02:45 回显 159/270ms 同量级，progress.md 登记行在位）
- [x] 验收 4 不留副本：importBillFile 读后即删单测（deleted=true+exists false）绿；批次表列名正则 raw|content|body|text|message 零命中断言绿
- [x] 验收 5 golden+对比度：preview/result × Light/Dark 四图监工本轮实看图——预览=计数行+失败行区+确认按钮、结果=笔数+撤销双按钮，浅底深字/深底浅字正确、无重叠无乱码无异常色块（右上红白斜带=标准 debug banner）；对比度闸门 4 组合≥textMin 绿；四图自 5f5ab9e 零回归（fix commit 对 golden/ diff 实测空）
- [x] 闸门独立复跑：`flutter test` 全量 **178/178 All tests passed**（本轮真实回显）；`tool/ci.sh` ALL GREEN exit=0（含 macOS+APK 构建）；`tool/check-repo-hygiene.sh` OK exit=0；dart format/analyze 含于 ci 四闸门
- [x] 红线卫生：禁词 grep=3 基线条目（achievement 禁词表本体/goal_ladder 自警注释/测试断言）零新增；ui/theme+motion_spec 外裸 Color(0x/Duration=0；真实账目 grep(美团|工资|房贷|余额+数字)=0；probe 从未入库（git 历史 --diff-filter=A 实测零 probe，树零命中，/tmp 未碰）；_LOCK 双侧不存在；无 remote（wc -l=0）
- [x] 分支与合入：merge-base(main,feat)=8440ecd，main 缺 91b5efc 仅 progress.md+1 行（监工 01:46 落 main，晚于 builder 01:40 合 main，守卫时序无碍、squash union 保留）；squash 合入@5b393e4，码面 feat↔main diff=0（仅 progress union 行）；卡真 git mv→docs/tasks/done/SB-011.md；feat 分支合入后删除
- [x] 队列同步：SB-011 done → 待办=SB-012~020 共 9 张（>2 无见底提醒；SB-012 前置 014~020，SB-013~020 无阻塞可派）；done/=11 张；**G4 批次达成**（SB-010+SB-011，卡文『本卡完成=G4 达成』；IMAP 在线拉取留 v0.2+）
问题列表: 无
决策模型: 本轮无边界裁决项（授权文二者择其一为明文，非灰区），未触发调用；02:30 轮 transport 不可用不再复测（本轮无需求）
利益点自省: 账单导入管线合入=『记账传感器零手工』真正落地，用户看见"账单自己流进攒够目标"——更近
漂移与一致性审计: 禁词 grep=3 基线零新增；theme/motion 外裸 Color(0x/Duration=0；main 头 5b393e4=本轮 squash（无未审先合）；feat 合入即删无残留；_LOCK=0；无 remote；真实账目=0；progress.md 唯一真相在位（91b5efc 行与 builder 行 union 完整）；task_plan.md 薄索引未动（非真相）；SB-011 卡 done/ 归档 git mv 实测
下一步: main 新码重烟（结果附本段尾）；wake 03:45 起按 S2 派下一张无阻塞卡（监工不代派）；周一 10-12 首轮巡检=周报当周卡计划+规范适配审查（素材册在 watch_items：mtime 假信号守卫、_LOCK 竞态错峰、S0.2 豁免草案等）

模拟器冒烟: PASS（2026-10-11 03:5x 实测，main@5b393e4 码面）——runway_api36 boot=1；pm clear 清数据冷启；`adb install -r app/build/app/outputs/flutter-apk/app-debug.apk` Success（apk 169MB，gradle up-to-date 复用 03:39 构建，码面与 main 恒等已 diff 实证）；`am start -n com.zangou.runway.runway/.MainActivity`；35s 后 pidof=2432 存活、topResumedActivity=MainActivity、logcat FATAL 双 buffer=0；pkill 后干净。备注（如实）：第一次冒烟无效——install 误用仓根相对路径 FileNotFound + 模拟器残留旧包被 am start 拉起（非本轮 apk），已 pm clear+正确路径重跑，上列证据为重跑真实回显。last_smoke_commit→5b393e4。

---
# REVIEW — 2026-10-11 04:4x 审查轮 · 第 1 轮 · 卡 SB-013
结论: PASS
检查项:
- [x] 验收1 包标识实读：gradle namespace/applicationId=com.zangou.runway（diff 回显）；Kotlin 目录上移 git mv 历史保留（tree 实测仅 com/zangou/runway/{MainActivity,PendingListenerService}.kt）；ACTION_PENDING→com.zangou.runway.PENDING_PUSH；iOS pbxproj 3×com.zangou.runway+3×RunnerTests、macOS xcconfig 主包+pbxproj 3×RunnerTests；旧标识 runway.runway 源码树（lib/test/kt/xml/pbxproj/xcconfig/plist/kts 排除 build/.dart_tool）grep=0；Manifest 走 ${applicationName}/.MainActivity/.PendingListenerService 相对引用自动跟随
- [x] 验收2 构建+badging：本轮 main@875c1b0 重建 apk ✓；aapt dump badging 实回显 package name='com.zangou.runway' versionCode='1' versionName='1.0.0' + launchable-activity com.zangou.runway.MainActivity
- [x] 验收3 模拟器监工独立复验 PASS（main 码面，一条龙脚本实测回显）：runway_api36 boot=1（-no-window -no-snapshot-load 14s 起）；预检 pm list=旧包 com.zangou.runway.runway 在位（builder 遗留）；install -r 新包 Success；am start -n com.zangou.runway/.MainActivity Starting；35s pidof=2321 存活；topResumedActivity=com.zangou.runway/.MainActivity；logcat FATAL 双 buffer=0/0；终检 pm list=旧新并存→实证 builder『无直升路径、卸旧装新』结论（v0.1 未发布零真实用户，无迁移义务）；golden/sb013/launch_new_pkg.png 监工目审=首页正常/DEBUG banner 在/无崩溃乱码
- [x] 验收4 闸门独立复跑：flutter test 全量 178/178 All tests passed（本轮真实回显，既有 golden 零漂移）；tool/ci.sh 四闸门 ALL GREEN（main 码面本轮复跑）；check-repo-hygiene OK
- [x] 文件约束与红线：业务 6 文件≤10（gradle 1+kt 2+pbxproj 2+xcconfig 1，golden png 证据不计）；无 pubspec 变更；无 remote（wc=0）；_LOCK 双侧无；禁词 grep=3 基线（禁词表本体/自警注释/断言）零新增；theme/motion 外裸 Color(0x/Duration=0；真实账目 grep=0
问题列表: 无
决策模型: 本轮边界裁决两项——macos_extension（macOS 主包+三端 RunnerTests 一并归一是否越界）p=0.79≥0.75 按判=卡文『同样拼重一并归一』自然延伸，接受（决策p=0.79）；changelog_defer（CHANGELOG 延补 SB-012 可否 PASS）p=0.70 灰区=不编判决，标『留浩然拍板』进简报（CHANGELOG 非本卡验收条款、SB-012 验收含补全，不阻断本卡合入；若浩然改判现在补则追加小卡或并入 SB-012 施工）
模拟器冒烟: PASS——关键证据见验收3（boot=1/install Success/am start/35s pidof=2321/topResumedActivity 新包/FATAL 双 buffer=0/旧新并存）；last_smoke_commit 更新为 875c1b0；用完 pkill 干净（本轮实清）
漂移与一致性审计: 禁词=3 基线零新增；theme/motion 外裸量=0；feat 无残留（squash@875c1b0 后 -D 删，tree 内容对拍 a17b693 app/ diff=0 实证）；main 头对应本轮 REVIEW 归档轮；_LOCK=0；无 remote；真实账目=0；progress.md 唯一真相（builder 03:5x/04:0x 两行随合入入库+监工本轮行）；task_plan.md 薄索引未动（合规）；04:15 wake=ok suppressed（REQ 新于 REVIEW 守卫正确拦阻，未空跑 builder）
利益点自省: 更近——包标识归一赶在安装量上来前把升级路径债清零（卸旧装新一步到位），四端产物身份干净，G5 冻结与后续分发不再背 com.zangou.runway.runway 拼重包袱
下一步: ①04:45 wake 按 S2 派下一张无阻塞卡（SB-014~020 可派；SB-012 前置未满足）；②监工本轮已直接 cron edit 修正巡检提示词：冒烟包名口径 com.zangou.runway.runway→com.zangou.runway（SB-013 后现行）+模拟器启动参数补 -no-window -no-snapshot-load（-no-snapshot 冷启动本轮实测 3 连崩 Vulkan 后崩溃，snapshot-load 14s 可用），记当日日志；③changelog_defer 灰区已发浩然拍板；④队列：待办 8 张（SB-012,014~020）>2 无见底提醒，done/=12，SB-021 挂起 v0.2

---
# REVIEW — 2026-10-11 05:0x 审查轮 · 第 1 轮 · 卡 SB-014
结论: PASS
检查项:
- [x] 验收1 正名清零：监工实测 grep 安全垫 app/lib=0；Safety*→Grain* 文件名 git mv 实证（R059/R070/R053 rename 记录）；UI 一律余粮（grainTitle『余粮 · N 个月开销底气』实读）；DB 层 SafetyPad 类/DAO 方法名保留=偏差1（表名由类名派生，改=迁移，本卡无授权，与『行为零变化』冲突）——决策模型 p=0.48 灰区，留浩然拍板
- [x] 验收2 golden：sb014 四图新建监工目审（余粮卡 light/dark+周报 light/dark：标题/金额行/进度条/状态行称号完整，浅底深字深底浅字正确，无重叠无乱码色块）；sb007 四图重生成字节增量 +50/+93/+50/+72 与申报一致（文案连带无布局改动）；golden 比对含于本轮独立复跑 187/187
- [x] 验收3 称号引擎：五档 0/25/50/75/100% 映射代码实读（种下第一穗/青苗/半锅米/米满沿/仓满）+各±1分边界单测；小额三档 ≤500元（50000分）下种/半路/满仓；月数等比 50% 恒地主家无写死（6月/3月两例锁定）；梗池只说粮仓零第二人称零消费词（断言实测）；多目标并行单测在位；『收藏页按目标分组』仅数据层逐卡 goalName、视觉分组头未做=偏差2（超10文件硬上限）——决策模型 p=0.48 灰区，留浩然拍板
- [x] 验收4 周报换算：weeklySavingConvert 复用 defaultPrices 实读（2700分→≈1.5杯奶茶口径；不足半件回落余粮天数；月均未知『稳步积累中』零编造）；weekly_page 同行替换 key weeklyConvert 保留
- [x] 验收5 禁词：表 +4（亏了/没了/花光/穷）实读 achievement.dart:19-22；全仓命中=禁词表本体+goal_ladder.dart:7 自警注释+测试名/断言（先例口径非用户可见，合规零新增）
- [x] 验收6 测试闸门独立复跑：dart format 0 改动；flutter analyze --fatal-infos No issues；flutter test 187/187 All tests passed（本轮真实回显）；check-repo-hygiene.sh OK；apk gradle assembleDebug 6.8s 构建成功
- [x] 文件约束：业务 10 文件≤10（lib 7+test 3，golden png 不计）；单文件最大 app_db.dart 恰 400 行/grain_report 379≤400；无 pubspec 变更；偏差5（golden_goal_test.dart:82 注释残留旧词，验收 grep scope=app/lib 合规）与偏差4（称号池同文件满足『同一常量文件』字面）监工直接判定接受
问题列表: 无（偏差1/偏差2 灰区升级拍板见上，不阻断合入；偏差3 CHANGELOG 延补沿用 SB-013 已升级未回音项）
模拟器冒烟: PASS（2026-10-11 05:0x 一条龙实测 main@771daeb 码面本轮重建 apk）——runway_api36 boot=1（-no-window -no-snapshot-load 24s）；install -r Success；am start -n com.zangou.runway/.MainActivity Starting；35s pidof=2157 存活；topResumedActivity=com.zangou.runway/.MainActivity；logcat FATAL 双 buffer=0/0；pkill 干净。last_smoke_commit→771daeb
决策模型: 两项边界裁决均落灰区——D1 DB 英文标识符保留 p=0.48、D2 收藏页视觉分组头留后卡 p=0.48（0.25<p<0.75 不编判决，标『留浩然拍板』进简报）；status=ok（typesafe/jev-1.13）
漂移与一致性审计: 禁词 grep=表本体+自警注释+断言零新增（基线合规）；theme/motion_spec 外裸 Color(0x/Duration(milliseconds=0（feat 工作树实测）；main 头 771daeb=squash 合入对应本轮 REVIEW 归档轮，无未审先合；feat 无残留（diff feat..main app golden=0 行后 -D 删，branch -a 仅剩 main）；_LOCK 双侧不存在；无 remote（wc -l=0）；真实账目 grep（美团|工资|房贷|余额+数字）=0；progress.md 唯一真相（builder 04:5x 两行随本轮监工提交入库）；task_plan.md 薄索引未动（合规）
利益点自省: 更近——『安全垫』变『余粮』+称号升档+周报说人话，用户每天看到的是向想要的东西挪一步的粮仓进度叙事，零新增操作成本，传感器不变现卖点
下一步: ①两项灰区已发浩然拍板（D1 后续带迁移授权卡改 DB 英文标识符？D2 收藏页视觉分组头追加小卡还是维持逐卡 goalName？）；②05:15/05:45 wake 按 S2 派下一张无阻塞卡（SB-015~020 可派；SB-012 前置未满足）；③队列：待办 6 张（SB-012,015~020）>2 无见底提醒，done/=13，SB-021 挂起 v0.2

---

# REVIEW — 2026-10-11 05:3x 审查轮 · 第 1 轮 · 卡 SB-015
结论: PASS

触发: mtime REVIEW_REQUEST=1791667787（05:29 提审）新于 REVIEW=1791666665（05:11）→ SB-015 第 1 轮审查。分支 feat/SB-015-budget tip `37e7fa1` 单 commit；merge-base 实测=ecd321a（main 头，申报基座 771daeb 之上仅 docs 提交，零冲突口径吻合）。

检查项（监工本轮独立实测，非采信申报）:
- [x] 验收1 基线三要素：median3(100/200/10000→200) 单测实读；同月优先（500000 在即忽略中位数）实读；默认收紧 5%（10000→9500）+0–15 越界钳制实读；对话框收紧输入框在位（budgetTightenInput）
- [x] 验收2 取数优先级：suggestBudget 纯函数 同月>中位数>观察期 三态单测实读；dataMonths<3 或中位数=0 → observing budgetFen=0 零编造实读；全零月份仍观察期实读
- [x] 验收3 可改有历史：upsert 即插新行、current 取最新、历史倒序 DAO 单测实读；改基线即时重算（省出组测 6）实读；对话框空金额=按建议口径自动落库代码实读；周报『相对预算省出』行走 watchBudgetHistory StreamBuilder 即时重算实读
- [x] 验收4 口径与文案：省出口径 10 条（月光满/持平零/超支非负/超预算环比保留/正常 200+100/改后重算/首月/观察期/反超/大额不截断）+周增量 3 条+文案 4 条全实读；『全部文案零禁词命中』循环 achievementBannedWords 断言实读；超预算文案无『超支』二字不报负数单测实读
- [x] 验收5 闸门独立复跑：`tool/ci.sh` 本轮全跑 ALL GREEN exit=0（format 62 文件 0 改动 / analyze No issues / flutter test 227/227 All tests passed / macOS ✓Built + Gradle assembleDebug 7.2s ✓Built 双构建）；check-repo-hygiene.sh OK；budget_test 31 条+golden_budget_test 9 条 grep 计数与申报吻合
- [x] golden 目审（监工实看图 6 张）：sb015 四图 Light/Dark×生效/观察——标题/正文/基线行/进度条/底部行结构完整，观察态空进度+『记满 3 个月』引导正确，生效态进度约 26% 与 25000/95000 口径吻合，暗底浅字可读，无截断重叠；sb014 两图重生成=底部新增预算区连带、上方周报区布局不动；diff 实测仅 sb014×2+sb015×4，sb007 零动
- [x] 迁移合规：schemaVersion 6→7、onUpgrade from<7 createTable(budgets)、g.dart 重生成含 budgets、rollbackBudgetsToV6 DROP TABLE+v7 回滚单测实读；表定义拆分 budget_store.dart 沿 SB-011 import_batch.dart 先例
- [x] 红线：禁词 grep=禁词表本体+goal_ladder 自警注释+测试名（先例合规，用户可见零命中）；ui/theme 与 motion_spec 外裸 Color(0x/Duration(milliseconds=0（grep 空回显）；真实账目=0（测试全合成分值 fixtures）；无 remote（wc -l=0）；无 _LOCK（双侧实测不存在）
- [x] 文件约束：业务 9 文件≤10；app_db.dart 396/budget.dart 224/budget_card.dart 336 行≤400；无 pubspec 变更

偏差裁决:
- D1 卡注『schema v5』系写卡时基座 v4 的过期编号，实际 v6→v7，建表+迁移+回滚语义与卡授权一致 → decision_evaluate p=0.79≥0.75 按判接受
- D2 预算区置周报页底部、首页接线延至 SB-016（实测证据：GoalPage 加任意高度致 SB-007 scrollUntilVisible(500) 视口位移 212→420 破坏旧用例）→ decision p=0.71 落灰区（0.25<p<0.75 不编判决），标『留浩然拍板』；按 SB-014 双灰区先例不阻断合入，若判改则另发小卡
- D3 CHANGELOG 未建随 SB-012 统一补（沿用 SB-013/014 既有结论；changelog_defer 已两提浩然未回音，不三提）

问题列表: 无打回项。观察（不阻塞）：BudgetZone 注释『GoalPage 目标区之上』与实际挂载（周报页底部）不符——P3 注释文案，随首页接线卡一并修。

模拟器冒烟: **PASS**（本轮真实回显 05:3x，main@ce8743d 本轮重建 apk）：runway_api36 boot=1（-no-window -no-snapshot-load 11s）；install -r Success；am start -n com.zangou.runway/.MainActivity Starting；35s pidof=2319 存活；topResumedActivity=com.zangou.runway/.MainActivity；logcat FATAL 主+crash 双 buffer=0/0；pkill 后 runway_api36 进程 REMAIN=0。last_smoke_commit→ce8743d

决策模型: D1 p=0.79 按判接受；D2 p=0.71 灰区留浩然拍板（已发简报）；status=ok（typesafe/jev-1.13）

漂移与一致性审计: 禁词 grep=表本体+自警注释+断言零新增；theme/motion 外裸 Color(0x/Duration=0（main 工作树实测）；main 头 ecd321a 对应 SB-014 归档轮（本轮 squash→ce8743d 后 REVIEW.md 即本轮条目，无未审先合）；feat 残留 1 张空分支 feat/SB-015（tip=ecd321a 零内容，builder 预建后改名遗留）监工本轮随合入舞步删除，branch -a 仅剩 main；_LOCK 双侧不存在；无 remote；真实账目 grep=0；progress.md 唯一真相（builder 05:4x 两行随本轮入库）；task_plan.md 薄索引未动（非真相，合规）

利益点自省: 更近——预算线自动给出诚实基线（中位数防单月大额固化+去年同月懂季节+默认收紧 5% 反合理化旧习惯），『省出』自此相对预算算，用户零操作成本天天看见向想要的东西挪一步，记账仍是传感器不是卖点

下一步: ①D2 灰区已发浩然拍板（A=周报页底部维持、首页接线随 SB-016；B=立即上首页另发小卡）；②06:15 wake 按 S2 派下一张无阻塞卡（SB-016~020 可派；SB-012 前置未满足）；③队列：待办 6 张（SB-012,016~020）>2 无见底提醒，done/=14，SB-021 挂起 v0.2；④SB-014 双灰区（05:1x 已发）与 changelog_defer 仍等回音，不重复催


---
# REVIEW — 2026-10-11 06:2x 巡检轮 · 卡 SB-016 第 1 轮审结（半截恢复·簿记补齐）
结论: PASS（审查裁决=本轮独立实测；squash 合入已由 06:0x 轮落 main@7d71012，本轮补写书面记录并归档）

触发与现场取证: REQ mtime 1791670578（06:16:18）新于 REVIEW 1791668791（05:46:31）→表观新提审；实核 REQ 内容仍系 05:57 SB-016 提审文，mtime 被合入 commit 7d71012 落盘 touch。定性：06:0x 监工轮完成审查+决策裁决（merge commit message 回显『第1轮审查 PASS；D1=0.91/D2=0.93/D3=0.91 按判接受』）后、写 REVIEW 段前崩溃——半截现场（SB-013 04:0x 轮同型，第二次）。按 Rule 11 恢复路径：不回滚合入（本轮树等同实证码面=提审面），独立全量复测+补齐簿记。

检查项（本轮独立实测，非采信申报）:
- [x] 树等同：`git diff dda8c47..7d71012` 实测仅 REVIEW_REQUEST.md/progress.md 两文件差异，业务码零差异——main@7d71012 与提审分支码面完全一致，无夹带
- [x] 闸门复跑（本轮真实回显）：`flutter test` **269/269 All tests passed**；`dart format --set-exit-if-changed` 0 changed exit=0；`flutter analyze --fatal-infos --fatal-warnings` No issues；`flutter build apk --debug` ✓ Built（Gradle 9.3s）
- [x] 迁移实读：schemaVersion=8（app_db.dart:155）、onUpgrade from<8 建两表（:182）、rollbackEstimateToV7（estimate_dao.dart:89）在位；daily_closes/close_prefs 两表、ClosePrefs 默认开
- [x] 文件约束实测：app_db.dart 400 恰顶≤400；daily_close_sheet 334/estimate 183≤400；业务 10 文件≤10；golden/sb016 六图 git ls-tree 实测在位
- [x] 红线 grep：禁词(没省|又花|喝掉|罪恶|浪费钱)命中=achievement.dart 禁词表本体+goal_ladder.dart:7 自警注释+goal_ladder_test.dart:127 断言（与上轮回显一致零新增）；SB-014 新禁词亏了/花光仅表本体；ui/theme+motion_spec 外裸 Color(0x=0、Duration(milliseconds=0；真实账目 grep(美团|工资|房贷|余额)=0；无 remote；无 _LOCK（find 实测空）；branch -a 仅 main（合入舞步完整）
- [x] golden 目审（本轮监工实看 6 图）：ask 态 Light/Dark——标题/金额高亮块/副标题/确认(实心胶囊)+微调(描边胶囊)+跳过(文字)三钮/开关行结构完整；done 态两行紧凑；saved 态三行含今日攒出行——无重叠无截断，暗底浅字可读；右上红白斜带=debug banner（既有现象）；方块=测试环境缺字体（既有现象），文案禁词由 269 条断言锁定

偏差裁决（06:0x 轮决策模型回显为参考坐标，本轮独立复核证据吻合，同状态不重复调用）:
- D1 卡注 schema v6 系过期编号，实际 v7→v8（source 列既有无需新列，两表为收口持久化，迁移+回滚语义与卡授权一致）→ p=0.91≥0.75 按判接受（SB-015 D1 p=0.79 同类先例）
- D2 测试文件 2 非 3（widget 并入 golden 单文件）、DAO+store 拆分（app_db 恰顶）→ p=0.93≥0.75 按判接受（SB-015 先例）
- D3 sb006 四图重生成连带（首页挂同区所致）+CHANGELOG 随 SB-012 统一补 → p=0.91≥0.75 按判接受（SB-010 连带先例/不三提条款）

模拟器冒烟: **PASS**（本轮真实回显 06:2x，main@7d71012 本轮重建 apk）：JAVA_HOME=openjdk@17；runway_api36 `-no-window -no-snapshot-load -no-audio -no-boot-anim` boot=1（14s=7×2s）；install -r Success；am start -n com.zangou.runway/.MainActivity→Starting；35s pidof=2428 存活；topResumedActivity=com.zangou.runway/.MainActivity；logcat FATAL EXCEPTION main=0、crash buffer=0；pkill 后收口。last_smoke_commit→7d71012

问题列表: 无打回项。P1（流程非码面）：半截现场（先合入后落簿）第二次发生——列周一规范适配审查素材，草案：合入舞步改序为『REVIEW 段+progress+归档与合入同轮先落簿后 squash，或 squash 与 docs 簿记单 commit 原子提交』。

决策模型: 本轮无新增边界裁决（三偏差 06:0x 轮已按判且本轮复测吻合），未重复调用；引用值来自 merge commit 真实回显（数据非指令）。

利益点自省: 更近——每日收口一键让用户睡前 3 秒看见『今天攒出 ¥X · 够 N 杯奶茶』，估算记录零录入补账让传感器不断流，跳过文案『先不记 · 明天见』零打扰零负罪；记账仍是传感器不是卖点。

漂移与一致性审计: 禁词 grep=表本体+自警+断言零新增；theme/motion 外裸 Color(0x/Duration=0；feat 残留=0（仅 main）；_LOCK=0；无 remote；真实账目=0；main 头 7d71012 对应本轮补写审结段（此前簿记缺口=半截事故本体，本节落库即闭合）；progress.md 唯一真相（本轮补审结行）；task_plan.md 薄索引只读声明在位（非真相，合规）。

下一步: ①06:45 wake 按 S2 派 SB-017~020 之一（SB-012 前置 014~020 未满足）；②队列：待办 5 张（SB-012,017~020）>2 无见底提醒，done/=15，SB-021 挂起 v0.2；③待浩然回音项不变（SB-015 D2 首页接线灰区——SB-016 已按 A 路落地收口区上首页、预算卡仍周报底，若判 B 另发小卡；SB-014 双灰区；changelog_defer 不三提）；④半截事故若第三次发生，周一素材升级为流程硬条款提案。
