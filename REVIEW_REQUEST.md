# REVIEW_REQUEST — SB-017 大额冷静期

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-017-cooloff`（未 merge、未 push、无 remote，合规）
任务卡：`docs/tasks/SB-017.md`（排期注 SB-015/016 之后，前置已满足；SB-016 已合入）
基座：`main@87744d5`（06:4x 巡检轮后，空分支续用）
提交：`d406da5 feat(cooloff)` + `b56ae38 docs(progress)`（流程登记）

改动清单（业务 9 文件 ≤10，手写单文件最大 399 行 ≤400；golden png 不计）：
- `app/lib/logic/cooloff.dart`（新建，123 行）：cooloffThreshold（自定义>0优先，否则日均×3，日均复用SB-016 dailyAverage禁第二套公式；日均≤0即0零编造）+ shouldProposeCooloff（仅source=manual，notify/import/estimate一律false；等阈值即触发；已建单false）+ shouldExpireCooloff（24h边界）+ 五文案（问/副/忍住/仍要买/超时，得到框架，零行动召唤）+ validateCooloffCustomFen（0=自动）/validateCooloffAmountFen；禁词复用achievementBannedWords
- `app/lib/data/cooloff_store.dart`（新建，26 行）：Cooloffs（txId/amountFen/proposedAt/status/decidedAt，同txId只一单）+ CooloffPrefs（enabled默认开/customFen默认0自动）
- `app/lib/data/cooloff_dao.dart`（新建，107 行）：proposeCooloff幂等（同txId返既有id，不弹第二次）+ decideCooloff（bought/held/expired）+ 开关/customFen读写 + rollbackCooloffToV8
- `app/lib/data/app_db.dart`（改，399 行）：import + 两表入@DriftDatabase + schemaVersion 8→9 + onUpgrade from<9 建两表；表注释压缩让行（零语义改动，回滚方法全保留）
- `app/lib/data/app_db.g.dart`（改）：build_runner 重生成（含 Cooloff/CooloffPref）
- `app/lib/ui/cooloff_card.dart`（新建，297 行）：CooloffCard（提出态问句+副文案+仍要买Filled主钮无摩擦/忍住Outlined次钮，Key cooloffAsk/Buy/Hold/Hint；忍住态省额+梗行Key cooloffDone/Joke）+ CooloffZone（开关行Key cooloffSwitch + 阈值≤0给先记账引导 + 待决策单优先/今日忍住展示/超时自动落expired静默/候选24h内手动大额自动建单；忍住删交易→省额经目标引擎自然并入进度）
- `app/lib/ui/home_page.dart`（改）：收口区之后挂CooloffZone（+2行import/同区）
- `app/test/cooloff_test.dart`（新建，22 条）：倍数3/窗24h/阈值自动与自定义/日均0/触发与等阈值/未达/三来源不触发/已建单/阈值0/24h边界/五文案口径/零禁词/零说教恐吓10词抽查/双校验/状态值域
- `app/test/golden_cooloff_test.dart`（新建，11 条）：widget 5（提出双钮/忍住省额梗/仍要买即回调/首页集成开关/DAO开关默认开建单幂等决策回滚）+ golden 4（sb017 提出/忍住×Light/Dark）+ 动效零裸量 + 对比度闸门
- golden（不计文件数）：新建 `golden/sb017/` 四图；重生成 `golden/sb006/` 四图（首页同区连带，字节增量~1%即新增卡位移，上方看板区布局不动）

验收对照（SB-017 卡 §验收 1~5）：
1. 采集来账不触发（source!=manual一律false单测锁定三来源；候选过滤+r.source检查双保险）；24h未处理静默记入（shouldExpire边界单测+Zone自动落expired，展示收口；同txId幂等不弹第二次单测+DAO断言）
2. 忍住后省额并入当前目标进度（删交易→computeGoal monthSpend下降自然并入，无第二套账本）+ 一句梗（复用SB-014称号池goalGrainTitle+grainJokeFor，只说粮仓不说人，widget断言省额行）
3. 文案抽查零说教零恐吓（禁词全表断言零命中 + 说教10词说教/惩罚/冲动/剁手/警告/克制/自律/后悔/罪恶/浪费抽查零命中）
4. golden 两组 Light+Dark 四图（提出/忍住；结构完整无重叠无截断，测试环境中文字体缺字为方块属既有现象，SB-013~016先例口径）
5. `tool/ci.sh` ALL GREEN（format 0改动/analyze No issues/冒烟绿/macos+apk双构建成功）+ `tool/check-repo-hygiene.sh` OK；全量302/302绿（269继承+33新）；`dart format` 0改动

文件约束：业务 9 文件 ≤10；单文件最大 399 行（app_db）；无 pubspec 变更；无 remote；测试全合成 fixtures，真实账目=0（grain_report 3行概念注释系基线，06:4x巡检已裁p=0.95非红线）；探针零使用（未写 /tmp，未建 probe 文件）。

偏差声明：
1. 忍住=删交易实现（卡称"取消则省额入目标"）：交易已正常记入（不拦截），忍住即删该笔+省额经目标引擎自然并入，无第二套省额账本；口径与"省额并入目标进度"一致，实现位置在Zone._hold。
2. 提出时机=Zone观测到24h内手动大额后自动建单（非记账页拦截弹窗）：满足"先弹冷静卡"且"决定权在人·仍要买无摩擦"（交易先行落库，卡只做决策分流）；24h前交易不补弹（静默记入语义）。
3. sb006 四图重生成连带（首页挂同区所致，上方看板区像素不动，字节增量~1%，沿SB-016 D3先例）；CHANGELOG 待 SB-012 统一补（沿用 SB-013~016 既有结论，不三提）。

请审计后结论写 `REVIEW.md`（PASS 或 REQUEST_CHANGES）。
