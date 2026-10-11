---
# REVIEW — 2026-10-11 09:3x 审查轮 · SB-019 分类角色轴
结论: PASS（第 1 轮 · 卡 SB-019）

触发核查: REQ mtime 1791682187(09:2x) > REVIEW 1791681613(09:2x 前一轮回填)，内容=SB-019 新提审面（非已审 SB-018 面，双核为真新，非 touch 假信号）。分支 feat/SB-019-role@71ca614+cb8d54e，实际基点 main@ad7ba21（REQ 声明 e004fce——SB-018 冒烟回填系 docs-only，app/golden 零差异，P3 措辞口径无实害）。

检查项（监工独立实测，非转述 builder 声明）:
- [x] `flutter test` 全量 360/360 All tests passed（本轮真实回显，exit=0）
- [x] 分文件实跑：role_test.dart +23 绿、golden_role_test.dart +6 绿（实测 29 新；REQ"24+6=30 新"系措辞口径差 1，与 SB-018 28/29 同型，无实害）
- [x] `dart format --output=none --set-exit-if-changed` 86 files 0 changed；`flutter analyze` No issues found；`tool/check-repo-hygiene.sh` repo hygiene: OK
- [x] 文件约束：业务 10 文件 ≤10（8 lib 含 app_db.g.dart 生成码 + 2 测试）；手写最大 app_db.dart 398 ≤400 行（wc -l 实测）；category_page 326/budget_card 365/cooloff_card 326/role_resolver 133；无 pubspec 变更
- [x] schema v11 实读：schemaVersion=11；onUpgrade from<11 createTable(roleOverrides)；rollbackCategoryRolesToV10（DROP TABLE role_overrides）在位；RoleOverrides 入 @DriftDatabase 表列；app_db.dart diff 系注释压缩让行+try/catch 空块化零语义改动；表定义拆 category_role_store.dart 独立文件（DEV §2 单文件 ≤400 授权拆分先例 SB-018）
- [x] 验收1 全类目角色完整：resolveRole 归一→覆盖优先→默认→弹性兜底永不 null 实读；默认映射食/行/用=必要、居=固定、玩/其他=弹性 实读（=卡注 0.93 决策口径的六字类目映射，旧名餐饮/交通/购物/居住/娱乐经 canonicalCategory 归一）；ensureDefaultRoles 幂等（缺失即补/已有不动/返新增数）源码+单测双核（6/0）
- [x] 验收2 弹性占比位置：elasticShare hero 在 category_page 头部（Key 'elasticShare'）实读；home_page diff=0 行实测（首页零新增）；elasticShareText 得到框架两态文案在位
- [x] 验收3 联动禁第二套：BudgetZone StreamBuilder 过滤仅弹性→_BudgetBody 原聚合公式逐行未动（diff 实测仅外层包装+基线文案缀「· 仅弹性」）；cooloff flows 仅弹性过滤→dailyAverage/cooloffThreshold 原公式复用、自定义阈值仍优先、固定账单不触发候选；单测锁定弹性中位数/弹性日均×3
- [x] 验收4 聚餐拆分：isDiningSplitCandidate（食+备注含聚餐）只判不改类；diningGuide 引导卡有候选才出现（单测三态）；食仍解析必要单测锁定
- [x] 验收5 单测 ≥12：实测 23+6=29 例全绿
- [x] 验收6 golden：golden/sb019 两图新建（role_light/role_dark 实存）；sb005 两图+sb014 周报两图连带重生成（见 D3）；对比度闸门测试在位实跑绿
- [x] 禁词复用 achievementBannedWords 实读（不建第二套）；roleBannedWords 零命中单测实跑绿
- [x] 红线：remote=0；_LOCK find 全仓=0；真实账目 grep（美团|工资|房贷）app/lib+app/test=0，测试全合成 fixtures；REQ 无 WAITING_HUMAN 标记

四偏差裁决（decision_evaluate 单调用四问，模型 typesafe/jev-1.13-20260917，status=ok）:
- D1 卡注 schema v7 过期编号→实际 v10→v11（SB-016/017/018 连发致漂移，迁移+回滚+单测齐备）→ 决策p=0.87 按判接受（SB-015 D1=0.79 同型先例）
- D2 新建类目无独立表单：全应用历来无创建类目入口，以"交易中新类目名出现即必选提示"（validateRole+rolePrompt+单测）兜底，独立表单声明随后续卡补但未写入任何卡文 → 决策p=0.70 灰区（0.25<p<0.75），留浩然拍板：A=接受兜底、独立新建类目表单随下一批小卡补 / B=立即另发小卡承接。**核验注**：与 SB-018 D2（自设实验 UI 延后 p=0.72）同病=延后项无卡文承接，两项可一并拍板（见快照 pending_human_decision）
- D3 golden 连带重生成（sb005 页新增区块 ~24%、sb014 预算行后缀 422px）+CHANGELOG 随 SB-012 统一补（既有结论不三提）→ 决策p=0.88 按判接受（SB-016/017/018 D3=0.89~0.91 先例）
- D4 角色存储=独立 role_overrides 覆盖表替代卡文"categories 增 role 列"：本应用类目为字符串归一驱动无 categories 实体表，覆盖表+默认映射语义等价且永无未映射态；类名 RoleOverrides 避 drift 单数化与 logic 枚举 CategoryRole 重名；v11 未发布无兼容问题 → 决策p=0.89 按判接受

问题列表: 无打回项。P3 观察（不阻塞，挂账）：①REQ 新数 24+6 实测 23+6、基座声明 e004fce 实为 ad7ba21，两处措辞口径无实害；②D2 灰区挂账待拍板（不阻断归档，SB-018 D2 先例）；③"builder 声明延后但无卡文承接"第三次再现（SB-015 D2/SB-018 D2/SB-019 D2）→周一素材册⑯：DEV_WORKFLOW 拟增条款"延后项必须落卡号或入 pending_human_decision 台账，否则视同缺失"。

模拟器冒烟: **已回填 PASS**（20:1x 轮回填：10:0x 轮 v3 一条龙实测 main@6ad2261 通过，证据见 20:1x 回填段；6ad2261..HEAD app/golden diff=0 本轮实测，证据覆盖至今）

合入舞步: squash@main@48459ce；feat/SB-019-role 删前树等同核对（feat..main diff app/golden=0 行实测）后清理；卡真 `git mv` 归档 docs/tasks/done/SB-019.md，状态行改验收通过+审计结论填写；progress.md 监工轮登记随本 commit 落库。

利益点自省: 更近——角色轴把"能省的空间有多大"变成类目页一行肉眼可见的弹性占比，预算/冷静只压弹性=优化打点打在可变的部分，必要/固定账单不打扰（不要求用户全量自律，默认映射自动兜底、覆盖可改）；记账仍是传感器，本卡零新增输入负担。连续计数：SB-017 更近第 1 次→SB-018 更近第 2 次→本轮更近第 3 次，无 SilentBook 旧病同构（机制兜底=未知类目归弹性暴露为可优化，不藏进刚性）。

漂移与一致性审计（真实回显，口径=app/lib+app/test+docs）: 禁词(没省|又花|喝掉|罪恶|浪费钱)零新增——命中全=成就表本体+goal_ladder 自警+测试断言基线；本卡 6 新/改文件内唯一命中=budget_card 注释"零亏欠表述"（自警措辞非禁词，与 goal_ladder 同型）；theme/motion 外裸 Color(0x=0、Duration(milliseconds=0；美团|工资|房贷=0；_LOCK find=0；remote=0；main 头 48459ce 对应本轮审结 ✓；合入后 feat 残留=0（仅 main）；task_plan 薄索引只读声明实读在位（未据此判进度）；progress.md 唯一真相 ✓。

下一步: ①冒烟回填证据段+快照 last_smoke_commit→48459ce（本轮或下轮）；②09:45/10:15 wake 应派 SB-020（SB-019 已归档）；SB-012 前置（019/020 其一）已随本卡满足，批次仅剩 SB-020+SB-012=2 张 ≤2 → 周一排下一批（素材册）；③待浩然回音：SB-019 D2 灰区（A/B，本轮随简报发）+SB-018 D2 自设 UI（同拍）+SB-015 D2/SB-014 D1/D2/SB-010 D1/D3 旧灰区未回音（周一再提）+changelog_defer 不三提；④明日周一首轮：当周卡计划+规范适配审查（素材册⑫~⑯）。

## 监工清障 — 2026-10-11 14:4x（SB-020 停摆 4h 处置）
- 根因：10:32 轮 builder 崩在两个预建空分支（price-watch/pricewatch，与 main 零差异），遗留 SB-019 旧提审文本的 REVIEW_REQUEST mtime(10:32) 反而新于 REVIEW(09:40) → 唤醒每轮撞 S0.5 空退；巡检 12:07/13:38 两轮又被模型掐死，无人解套。夜半 7 条『投递失败』=空简报 NO_REPLY 发不进微信，只吵耳朵不碍施工。
- 处置：两空分支已删（零差异，安全）；工作树回 main；本段落盘即刷新 REVIEW.md mtime → S0.5 解除。下一轮唤醒（:15/:45）按 S2 正常开 SB-020（价格之眼），无需人工。

## 裁决记录+现场保全 — 2026-10-11 15:0x（浩然五连A + SB-020 第3起脏树）
- **浩然拍板（14:38『按你推荐的来』=五连A）落地**：①CHANGELOG 维持 SB-012 验收5 承接，无改动；②DB 英文旧标识符维持现状，结案；③收藏页分组标签现状结案，折叠升级挂 v0.2 建议池；④预算卡上首页→**SB-012 新增验收7**（本次落卡）；⑤两笔 UI 欠账（新建类目表单+自设实验输入框）→列入明日周一批次提案，随小卡统一补。
- **SB-020 崩溃现场**：本轮 builder 未切分支在 main 直接施工后崩退（无 commit/无进程/无锁），6 个 WIP 文件+提审/进度登记已代提交保全至 `feat/SB-020-price-watch`（main 已净回）。提审未遂文本留档待审。
- **续做授权（S0.1 · round 1 · 一次性）**：分支 = `feat/SB-020-price-watch`。下轮 wake：①merge main；②**禁止推倒重来**，从 WIP 续做到 SB-020 卡验收齐（价格之眼逻辑+卡片+golden/单测）；③`tool/ci.sh`+format+analyze 全绿 → commit → progress 登记 → 写 REVIEW_REQUEST 提审；④探针只准 `_inbox/`/`probe*.tmp` 退出前删，**绝禁 /tmp**；修不完则 REVIEW_REQUEST 登记阻塞退场，授权即消耗。
- **升级预警**：24h 内 builder 第 3 次中途崩（SB-011×2、SB-020×1，本轮起 S0.1 已兜住成本）。根因排查（疑似 opencode 会话超时/被 gateway 重启杀进程）由主会话明日专项处理，期间环照常施工。

## 唤醒轮指令·监工签发 2026-10-11 15:4x（SB-020 续做授权 · round 2 · S0.1 · 友军火力已解除）
- **死因更正备案**：round 1（15:34:29 SIGTERM）与 24h 内其余几起『测试跑一半无征兆死』的凶手已查明——**不是 opencode、不是网关、不是模型**，是 wake 旧文案自带的『连续10分钟无输出→kill』（杀了 00:04、15:34 两轮）与『cron 30分钟硬超时』（杀了 01:45、10:15 两轮，run 档案留有 job timed out 实录）。wake 已改写为即发即忘派发器（不 poll 不 kill，timeout 120s），builder 生死交还 LOOP 的 _LOCK+trap。**凡死于友军火力的轮次不消耗返工计数，本授权为 r2 补发。**
- builder 第一步：`git checkout feat/SB-020-price-watch`（现场保全在 3cc2eb1：goal_page 拆分完成、价格测试 20/20、逻辑 179/179 绿）→ merge main 取本授权。
- **本轮唯一任务=golden 收尾**：绕开 opencode 290s 壳超时的硬规矩——golden **逐文件跑**（for t in app/test/golden_price*.dart; do flutter test "$t"; done 式），单命令墙钟 <250s，禁止批量一把梭；已绿的测试不许重开。
- 出口：`tool/ci.sh`+hygiene 全绿 → progress 登记 → REVIEW_REQUEST 提审（标注『应答续做授权 r2』）；修不完→登记阻塞退场。探针只准 `_inbox/`/`probe*.tmp` 退出前删，禁 /tmp。
- 本授权一次性消耗；若再无征兆 SIGTERM=新病因，巡检裁决升级人工。

## 唤醒轮指令·监工签发 2026-10-11 16:1x（SB-020 续做授权 · round 3 · S0.1 · 最后一次自动授权）
- r2 死于新型友军火力（宿主 turn 退出回收子进程，15:53）——非 builder 过错，按 r2 条款转监工裁决：现场已定格（e810b41），**r3 为最后一轮自动授权**，再失败即停环升级人工，不再自动补发。
- 派发架构已换代：wake 现为 command 型定时任务（纯 shell 守卫+点火+心跳保活，无 agent turn，杀 builder 的『静默判死/硬超时』两条规则随旧架构作废）。
- builder 第一步：`git checkout feat/SB-020-price-watch` → merge main 取本授权。范围不变：**只剩 golden 逐文件收尾**（for t in app/test/golden_price*.dart 式单命令 <250s），已绿测试与拆分成果禁重开。
- 出口：`tool/ci.sh`+hygiene 全绿 → progress → REVIEW_REQUEST 提审（标『应答 r3』）；失败→登记阻塞退场。探针只准 `_inbox/`/`probe*.tmp`（已 gitignore），禁 /tmp。

## 监工票 — 2026-10-11 17:2x（r3 收尾补票 · 非新授权）
- r3 实况：builder 16:15 轮已完成全部业务（merge 244e8e3 + feat 6c61952 常买价格眼·同键统计+跟随），但崩于出口之前——REVIEW_REQUEST 仍是 SB-019 旧文本，提审未写。
- 下一轮 builder 唯一任务=r3 出口补齐（不计新一轮）：①git checkout feat/SB-020-price-watch → merge main 取本票；②tool/ci.sh 四闸门 + golden 逐文件（单命令 <250s）复跑验证；③progress 登记 + 写 REVIEW_REQUEST 提审（标注『r3 收尾补票 · 6c61952』）；④禁止新增业务代码。验证不过→登记阻塞退场转人工。
- 观察者近况备案：16:00 巡检轮被网关重启打断（正常）；16:30 巡检轮一次模型挂死触发 40min 超时（孤例，复发再处理）。施工链无损伤。

# REVIEW — 2026-10-11 SB-020 第 1 轮 · 卡 SB-020（监工独立实测）
结论: REQUEST_CHANGES

审查对象更正备案：17:2x「收尾补票」票判"REQ 未写"系误读——feat@6c61952（16:16:53 真实回显）已含 SB-020 新提审文本+progress 登记行（feat 侧 REQ 文件 4569B），根仓 main 侧 REQ 仍是 SB-019 旧文本（mtime 启发式在"分支出口"架构下失效，列周一素材⑰）。本轮以 feat REQ 为审查依据（第 1 轮 · 卡 SB-020）。

检查项（全部真实回显）:
- [x] 文件约束实测：业务 8 文件 ≤10（wc：price_watch 105/price_card 187/goal_price_follow 95/goal_page 391/quick_add 195/category_page 329/price_watch_test 92/golden_price_test 206），最大 391≤400；diff main..feat=13 文件（8 业务+2 golden+REQ/progress/REVIEW），无 pubspec
- [x] 禁词 grep=基线 5 文件本体（achievement/goal_ladder+3 测试），price 新文件零命中；theme 外裸 Color(0x=0；裸 Duration=0；美团|工资|房贷=0；remote=0；_LOCK 全仓无
- [x] 验收1-4 逻辑实读：priceKeyFor 精确匹配+空即无键；summarizePrices <3→null；describeVsAvg 纯陈述；resolveGoalPrice 手动优先否则中位数；GoalFollowField <3 笔只提示不猜；goal_page 换算引擎零改动仅接线；category_page PriceZone 同区 +3 行
- [x] golden/sb020 两图在位；price 新 20 例在全量 +375 通过集合内（price_watch 13+golden_price 7 非失败项）
- [ ] **验收5"四闸门全绿+全量回归"不实**：见问题1——SB-004 存量 2 例在 feat 挂、main 对照绿

问题列表:
1. P1 回归（监工实测实锤）：`flutter test test/quick_add_test.dart test/golden_quick_add_test.dart` @feat → 2 [E]：`SB-004 golden quick-add light`、`SB-004 金额为 0 时拦截并提示`，均 **Pending timers**（fake_async 零时长 timer，栈=drift StreamQueryStore.markAsClosed→QueryStream._onCancelOrPause→_StreamBuilderBaseState._unsubscribe/dispose），且测试进程挂死>2min 不退出（日志 /tmp/sb020-feat2.log）。同一命令 @main@c99d224 对照 → All tests passed, MAIN_EXIT=0（/tmp/sb020-main2.log）。全量两轮（/tmp/sb020-test2.log、/tmp/sb020-final.log）均卡死在 +375 -2、同两例 [E]，无法收口 All tests passed。
2. 根因域：quick_add_page.dart +39 行的 PriceHint 流订阅生命周期——页面卸载后 drift markAsClosed 零 timer 未在测试 teardown 排干，拖挂 SB-004 存量用例并疑似拖死后续 golden 段。其他 watchAll 消费方（category 侧 PriceZone/BudgetZone）全量绿，仅 quick_add 两处挂。
3. 返工红线：**不得削弱存量断言、不得改 SB-004 测试语义交差**；修订阅生命周期/补正确 teardown 排干均可。已绿 price 20 例禁重开。
4. 流程注记（非打回项）：builder 曾在 /private/tmp/rw-sb020 worktree 出活，opencode headless 对 /private/tmp external_directory **自动拒绝**（wake.log 17:45 真实回显：permission auto-rejecting），17:45 后出口动作全部失败。监工本轮已移除该 worktree（树净、内容全部在 6c61952 commit，零丢失）；返工请回主仓工作树 `git checkout feat/SB-020-price-watch`。

模拟器冒烟: 本轮无（main 头 c99d224 为 docs 簿记，无新业务合入；last_smoke_commit=6ad2261 账实相符；SB-020 返工合入轮再按归档法 v3 一条龙必做）。

下一步（退回 builder）: ①主仓 `git checkout feat/SB-020-price-watch` → merge main 取本票；②修 quick_add PriceHint 订阅退场泄漏；过关硬标准=`flutter test test/quick_add_test.dart test/golden_quick_add_test.dart` All tests passed 且全量 `flutter test`（可分批逐文件跑）exit=0 无挂死；③REQ 更新再提审，标注（第 2 轮 · 卡 SB-020 应答）；④同症状再现=R4 第 2 次 REQUEST_CHANGES → 直接 WAITING_HUMAN 升浩然。

决策模型: 本轮无灰区边界——回归为对照实验实锤（feat 挂/main 绿），非裁量事项，未调用。

漂移与一致性审计（一行）: 禁词基线 5 文件零新增、theme 外裸 Color(0x=0、裸 Duration=0、真实账目=0、remote=0、_LOCK=0；main 头 c99d224=最近轮（收尾补票）对应 ✓；feat 残留=SB-020 一支（待返工，合法在审）；worktree /private/tmp/rw-sb020 本轮监工清除（零丢失）；progress.md 唯一真相、task_plan 薄索引未动 ✓。

利益点自省: 更近——价格之眼本身是"零成本看见向目标挪一步"的正向功能，本轮退回护住的是「记一笔」传感器入口零回归：传感器若因新功能抖一下，核心利益点就受伤；无 SilentBook 旧病同构。

## 巡检轮 — 2026-10-11 20:1x（唤醒缺位实锤重建 · 冒烟与审计欠账回填 · 本轮漂移审计）

触发：定时巡检。REQ mtime 17:22:59 < REVIEW 19:06:26=无新提审待办；builder 空闲（无 _LOCK、无 headless 进程、工作树净、main@ae7b8b9）。

【事故簿记 — wake 任务缺位（言实不符·监工侧·P1 簿记级）】19:0x 轮结论与 commit ae7b8b9 均记"wake command 任务缺位→本轮重建"，但本轮全量真实回显 `openclaw cron list`（27 项）中**无任何 wake 任务**；wake.log 末条 17:45（SB-020 r3 提审未遂现场）、dispatch.log 停 16:10 → 施工环 17:45 后停摆≈2.5h+。归因：上轮 cron add 大概率被多通道投递参数报错拦下而未复验——本轮首次 add 同样真实回显 `invalid cron.add params: ...requires an explicit channel (feishu, openclaw-weixin)`，改 `--no-deliver` 重试成功。**本轮已重建并 list 复验**：攒够-loop唤醒 id=e71e53ac-adcc-4f75-a85a-25c92a06a65a，cron `15,45 * * * *`(exact)，payload=command `sh ~/.openclaw/tools/runway-wake-dispatch.sh`（二代派发器：LOOP S0 全套守卫+python setsid 完全脱离点火+即发即忘；零 poll、零 kill、零超时，防友军火力复发）。重建后 `openclaw cron run` 手动实测，点火结果见本条快照/下轮续查。周一素材册⑱新增：凡任务重建必须 id+list 双回验方可入"已重建"口径。

【回填段（20:1x 轮，账与快照核对）】
- SB-019 模拟器冒烟 **PASS**@main 6ad2261（10:0x 轮 v3 一条龙·archive 独立构建·零碰工作树）：BUILD_EXIT=0（Gradle 29.5s ✓Built，apk 155MB）；BOOT=1（14s）；adb install Success；am start -n com.zangou.runway/.MainActivity 后 35s 存活（PIDOF=2190）；logcat FATAL=0/crash=0；pkill 收口二次 pgrep=0。本轮实测 `git diff 6ad2261..HEAD --stat -- app/ golden/`=空 → main 头 ae7b8b9 与冒烟证据 app 码零差，last_smoke_commit=6ad2261 账实相符持续成立。
- 10:0x/14:3x 巡检轮漂移审计：全绿（快照历史 note 在册）。
- 15:0x 轮：审计全绿+冒烟延迟裁决 decision p=0.86（6ad2261..446ffd0 app 码零差缓行）；15:3x 轮：WIP/feat 树禁词零新增（基线 5 文件本体）、裸 Color/Duration=0、_LOCK=builder 施工锁（pid99089 当时存活）非泄漏、d758032 保全 WIP 未污 main。

【本轮漂移与一致性审计（一行·真实回显）】禁词命中=基线本体 6 文件（achievement/goal_ladder+3 测试+DESIGN_SYSTEM.md 禁词表自身）零新增；theme/motion 外裸 Color(0x=0；裸 Duration=0；美团|工资|房贷=0；remote=0；_LOCK=0；main 头 ae7b8b9 对应 REVIEW 最近归档轮（SB-020 第1轮 RC）✓；feat 残留唯一=SB-020 在返工（合法在审）；task_plan 薄索引未动、progress.md 唯一真相 ✓。本轮新增不符项仅一条且已修复：wake 言实不符（见事故簿记）。

决策模型: 本轮无灰区边界裁决（wake 重建为机械修复非裁量事项），未调用。

利益点自省: 更近——本轮修复的是施工环瘫痪本身；SB-020『价格之眼』（=你想要的东西到价了自动看见，零自律零输入负担）能否交付完全取决于环是否活着。无 SilentBook 旧病同构。

下一步: ①builder 经新 wake 应答 SB-020 第 1 轮返工票（修 quick_add PriceHint 订阅退场泄漏；同症状再现=第 2 次 RC→WAITING_HUMAN 升浩然）；②明日周一首轮巡检：当周卡计划+规范适配审查（素材册⑫~⑲＋本轮新增⑱ wake 复验条款、⑰ mtime 启发式在分支出口架构下失效）。

# REVIEW — 2026-10-11 21:3x 轮 · SB-020 第 2 轮（监工独立复跑实审）
结论: PASS（第 2 轮 · 卡 SB-020）——第 1 轮 RC 唯一问题（P1 quick_add 存量回归）本轮返工达标

触发核查（真实回显）: REQ mtime 1791721631 > REVIEW 1791721284；feat@41a9fcf ct=1791721637（20:2x 提审）=真新提审面（应答第 1 轮 RC）。基座 f23a7c2 merge main@43ffac9 ✓（main is ancestor of feat 实测 YES）。工作树净（status=0 行）。

检查项（监工在 feat@41a9fcf 独立实跑，非转述 builder 声明）:
- [x] **RC 硬标准①** `flutter test test/quick_add_test.dart test/golden_quick_add_test.dart` → `00:02 +6: All tests passed!` PAIR_EXIT=0 无挂死（第 1 轮 feat 挂>2min → 本轮根治）
- [x] **RC 硬标准②** 全量 `flutter test` → `00:16 +380: All tests passed!` FULL_EXIT=0 无挂死（REQ 声明 380/380 与实测一致，本轮诚实）
- [x] 存量断言零削弱：10c6b50 diff 逐行实测——quick_add 3 例+golden 2 例 expect 断言原文未动，仅 `addTearDown(db.close)`→`_unmountAndFlush`（pumpWidget(Container)+100ms×2 多 pump 排干 drift 零时长 Timer）；该口径系 widget_test.dart 文件头自 SB-004 时代既有全仓统一记录（close-after-watch 挂起实测），非本轮新造
- [x] golden/sb004 基线零改动：`git diff main..feat -- golden/sb004/`=空回显；matchesGoldenFile 复跑通过（像素零差实证）
- [x] 已绿 price 20 例禁重开遵守：10c6b50 --stat 实测=3 文件（quick_add_page/quick_add_test/golden_quick_add_test），price_watch/golden_price 零触碰
- [x] 生产侧根治实读：PriceHint 外包 Builder 先算 priceKeyFor——无键直接 SizedBox.shrink，不建 StreamBuilder 不订阅 watchAll（空态零订阅：测试免 pending+生产省订阅各一）；有键路径原逻辑逐行保留（summarizeAll→≥3 现身→Key priceHint）
- [x] 闸门独立复跑：dart format 91 files 0 changed；flutter analyze No issues；check-repo-hygiene OK；ci.sh 构建闸门由本轮冒烟 apk 真实构建覆盖（BUILD_EXIT=0）
- [x] 文件约束：净差 main..feat 14 文件=代码 10（6 lib+4 test）+golden png 2+REQ/progress；≤10 ✓；wc 实测最大 goal_page 391≤400（quick_add_page 203/quick_add_test 112）；无 pubspec
- [x] 验收 1~4：本轮无逻辑改动，第 1 轮已审项（priceKeyFor 精确匹配/summarizePrices <3→null/describeVsAvg 纯陈述/resolveGoalPrice 手动优先+中位数跟随）由全量回归再锁定
- [x] 红线：remote=0；_LOCK=0；真实账目（美团|工资|房贷）=0；禁词全库命中=基线本体零新增（achievement 禁词表/goal_ladder 自警/3 测试断言基线/_inbox+DESIGN_SYSTEM 禁词表自身/REVIEW.md 审计行）；golden/sb020 两图在位

边界裁决（规则10）: 存量测试 teardown 机制变更（db.close→unmount 排干）属第 1 轮 RC 红线明文允许的『补正确 teardown 排干』而非违禁的『改 SB-004 测试语义交差』→ **decision p=0.93**（typesafe/jev-1.13-20260917，status=ok）按判接受。本轮无其他灰区。

R4 计数: SB-020 累计 REQUEST_CHANGES=1（第 1 轮）；本轮 PASS 未触发熔断（阈值 2）。

模拟器冒烟: **PASS @main 7bfe4cc**（v3 一条龙实测，`git archive` 独立构建 /tmp/runway-smoke-7bfe4cc，监工 git 纯读零碰工作树）：BUILD_EXIT=0（✓Built，apk 155473984B≈155MB）；BOOT=1（实测 ~28s）；adb install `Success`；`am start -n com.zangou.runway/.MainActivity` 后 35s 存活 PIDOF=2572；logcat FATAL crash=0/main=0；pkill 收口复测 pgrep=0。applicationId com.zangou.runway 现行口径再证 ✓。last_smoke_commit: 6ad2261→7bfe4cc。

合入舞步: squash 落 main@**7bfe4cc**（git log 头实存）；删支前树等同核对 `git diff main feat | wc -l`=**0** 后方 `-D`（squash 不置 upstream，树等同系历轮归档口径）；卡真 `git mv` 归档 docs/tasks/done/SB-020.md（状态行=验收通过+审计结论已填）；progress.md 监工轮登记；本条随同轮簿记 commit 落库。

漂移与一致性审计（一行·真实回显）: 禁词基线外零新增；theme/motion 外裸 Color(0x=0（app/lib 实测）；裸 Duration theme/motion 外=0（app/lib；测试排干 Timer=仓内既有口径豁免项，见边界裁决注）；美团|工资|房贷=0；_LOCK=0；remote=0；main 头 7bfe4cc=本轮审结合落 ✓；合入后 feat 残留=0；工作树净 ✓；task_plan 薄索引未动（未据此判进度）；progress.md 唯一真相 ✓。本轮无不符项。

利益点自省: **更近**——本卡把"常买的东西"从用户记忆里挪出来自动摆到眼前：均价/最低/这次比均价如何，≥3 笔自动现身、无备注零订阅零打扰（本轮根治恰是这条）；目标单价中位数跟随=省用户一次心算。零新增输入负担、不要自律、不预设全量记账（无键即不出）。连续计数：更近×4（SB-017→018→019→020），无 SilentBook 旧病同构。

下一步: ①wake（e71e53ac 在册 ok，21:45 已跑）下轮应派批次最后一张 **SB-012**（前置已满足；SB-012 完成=G5·v0.1.0 冻结）；②待办卡=1≤2 → 明日（周一）首轮巡检=当周卡计划+下一批提案+规范适配审查（素材册⑫~⑲，含⑰ mtime 启发式在分支出口架构下失效、⑱ wake id+list 双复验）；③待浩然灰区挂账=无新增（旧账五连A已消化）；④SB-021 维持挂起 v0.2。

## 监工票 — 2026-10-11 21:5x（SB-022 卡升 v3·点名制；本窗观察两条）
- **卡改判**：浩然两轮定调——负结余禁「今天攒 0」改打趣三段；第二段**点名今日买了啥**（读当日真实记录条目，不做价格换算；编造物件=红线）。main 卡已 v3。
- **在制轮处理**：当前 builder 轮持旧卡施工，其提审**一律按 v3 审**；规范变更驱动的返工**不计轮次**（先例：SB-010 R4 豁免），直接给一轮精准返工即可。
- **观察项①**：builder 本轮疑似改写 docs/tasks/SB-022.md 正文（工作树与分支头不一致），docs 规范内容非状态行=builder 禁改区——审查轮请核实并记违规。
- **观察项②**：builder（pid 82262）在跑但 _LOCK 缺失，22:15 wake 靠脏树守卫挡双开——审查轮若发现 builder 已退场，按现场保全规矩处理；本票不需浩然操作。
