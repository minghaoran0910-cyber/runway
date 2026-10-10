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
