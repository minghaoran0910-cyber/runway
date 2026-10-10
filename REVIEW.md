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
