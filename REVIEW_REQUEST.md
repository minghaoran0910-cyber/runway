# REVIEW_REQUEST — SB-010返工第2轮/R3末轮（应答REVIEW第2轮REQUEST_CHANGES+22:40死锁裁决）

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-010-notify-collect`（未merge、未push、无remote，合规）
任务卡：`docs/tasks/SB-010.md`（已merge main取d6ae1ab新验收4；另SB-019决策性文字顺带合入，非本卡范围不动代码）
commit：`267c125 fix(notify): 通知身份去重替代时间桶+3单测 [SB-010]`（+ trailer `Agent: opencode`；另 `a459c8d` progress登记轮；基座第1轮 `84f47c6` 在位）

问题逐条应答（REVIEW第2轮 P1×1，新验收4）：
1. [P1·新验收4身份去重] 旧实现SHA-1(包|标题|金额分|UTC分钟桶)+单测锁定分钟桶语义，extras无tag/id/when → 已按卡重做：Kotlin用sbn.tag/sbn.id/sbn.postTime/notification.when+内容哈希（sha1包|标题trim|金额分），extras补传tag/notifId/whenMs/postTimeMs/contentHash，occurredAt取when可信值否则postTime；Dart键体预镜像三元组化（when可信：SHA-1包|tag|id|when毫秒|内容哈希；否则回退SHA-1包|tag|id|内容哈希|postTime秒，1e12为毫秒可信下界），parsePaymentNotice新增tag/notifId/whenMs/postTimeMs透传，occurredAt同口径回退。去重以notifyKey为准，DAO幂等逻辑不动。第1轮已修项保留未回退：键体哈希化（§5标题不明文落库，值级单测在位）+Kotlin BigDecimal HALF_UP（8.20→820镜像单测在位）+merchant三处32。
2. 卡要求3单测已补（新文件test/notification_identity_test.dart，拆分保单文件≤400行）：①同商户同金额不同when→异键且DAO保留2条 ②同通知重投三同→同键且DAO幂等仅1条 ③回退路径（同postTime秒同键/跨秒异键/秒级when走回退/40位hex形状）。风暴测试按新语义复核（50条tag/id/when各异→50互异键不丢）。旧分钟桶单测已改身份制（同身份同when同键/when不同异键）；SHA标准向量更新为内容哈希+身份键向量（python hashlib对拍：`||0`→d2abfc06…、`a|b|99`→ebadb7a4…、身份键→edc5af55…，锁定Dart与Kotlin MessageDigest一致）。
3. 4b已知边界如实记：when系App自报，同秒两笔理论可并（人手不可达）；通知重建出毫秒级新when的罕见情形多出一条待确认，由待确认池一键消化，非静默错账（实现未做静默合并，符合“不漏一笔真账”）。

验证：
- `dart format` 0改动；`flutter analyze --fatal-infos --fatal-warnings` No issues；全量`flutter test` 163/163绿（160继承+3新增）；`tool/ci.sh`四闸门全绿（含macOS+APK双build，ALL GREEN）；`tool/check-repo-hygiene.sh` OK
- 文件约束：业务6文件（Service 112行、MainActivity 89行、parse 223行、pending_page 392行、单测363+136行）≤400，文件数6≤10；无docs规范改动（除merge带入的卡本身d6ae1ab）、无pubspec依赖变更、无schema变更（pending表结构不动，仅键内容换语义）
- 红线：全库“全自动”（除禁令行）零命中（沿用单测grep断言）；ui/theme与motion_spec之外裸Color/Duration零新增；测试全合成fixtures，真实账目=0；未碰remote、未push

偏差声明：无新增偏差（桶口径废除系卡d6ae1ab实质拍板，非builder自选；阈值1e12毫秒可信判定为实现细节，已在注释与单测锁定）。

请审计后结论写 `REVIEW.md`（PASS 或 REQUEST_CHANGES，本卡第 3 轮/上限 3 轮；再打回按裁决直接熔断）。
