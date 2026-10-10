# REVIEW_REQUEST — SB-016 每日收口一键（最小记账姿态）

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-016-daily-close`（未 merge、未 push、无 remote，合规）
任务卡：`docs/tasks/SB-016.md`（SB-011 之后、SB-017 之前，前置已满足；SB-015 已合入）
基座：`main@e2055b0`（SB-015 结案后，空分支续用）
提交：`d36f564 feat(close): SB-016 每日收口一键+今日攒出行 [SB-016]` + `dda8c47 docs(progress)`（流程登记）

改动清单（业务 10 文件 ≤10，手写单文件最大 400 行 ≤400；golden png 不计）：
- `app/lib/logic/estimate.dart`（新建，183 行）：dailyAverage（近30天/覆盖天数，空=0零编造）+ weekdayFactor（六1.2/日1.15/工作日1.0）+ estimateToday（日均×系数）+ shouldAskClose（今日零记录且未收口才问，有记录估算让位）+ hasRealToday/todaySpendOf/dailyBudgetFor（月预算/当月天数，无预算回落日均）+ computeTodaySaved（日预算−今日支出含估算，钳零）+ todaySavedText（复用SB-007价格表，≤0或换算不出回null整行不现，禁1/N）+ isBigDailySave（≥目标5%）+ 问/记/跳过三文案 + validateEstimateFen；禁词复用achievementBannedWords
- `app/lib/data/estimate_store.dart`（新建，23 行）：DailyCloses（dateKey/estimateFen/status/createdAt）+ ClosePrefs（enabled默认开）
- `app/lib/data/estimate_dao.dart`（新建，93 行）：closesForDate/watchClosesForDate/closeOfDate/markClosed/closeEnabled/watchCloseEnabled/setCloseEnabled + rollbackEstimateToV7
- `app/lib/data/app_db.dart`（改，400 行）：import estimate_store + 两表入@DriftDatabase + schemaVersion 7→8 + onUpgrade from<8 建两表；注释压缩让行（零语义改动，回滚方法全保留）
- `app/lib/data/app_db.g.dart`（改）：build_runner 重生成（含 DailyClose/ClosePref）
- `app/lib/ui/today_saved_row.dart`（新建，27 行）：TodaySavedRow（null即SizedBox.shrink，Key todaySaved/todaySavedEmpty）
- `app/lib/ui/daily_close_sheet.dart`（新建，334 行）：DailyCloseCard（问句/已记两态，Key dailyCloseAsk/Done/Confirm/Adjust/Skip/Hint）+ DailyCloseAdjustDialog（空=按估算）+ DailyCloseZone（开关行Key dailyCloseSwitch + 估算≤0给先记账引导 + 问句/已记分流；确认写transactions source=estimate并markClosed done，跳过mark skipped）
- `app/lib/ui/home_page.dart`（改，224 行）：目标卡后挂DailyCloseZone（+2行import/同区）
- `app/test/estimate_test.dart`（新建，29 条）：系数/日均/估算/问句/让位/支出/日预算/攒出/攒出文案/5%线/零禁词/问句口径/跳过/校验
- `app/test/golden_daily_close_test.dart`（新建，13 条）：widget 5（问句三钮/已记/已记含攒出/首页集成开关/DAO开关默认开落库回滚）+ golden 6（sb016 问句/已记/已记含攒出×Light/Dark）+ 动效零裸量 + 对比度闸门
- golden（不计文件数）：新建 `golden/sb016/` 六图；重生成 `golden/sb006/` 四图（首页同区连带，上方看板区布局不动，diff 空态~2.3%/有数据~10%即新增卡位移）

验收对照（SB-016 卡 §验收 1~6）：
1. 确认/微调/跳过三选一屏三钮（widget断言三Key全在）；跳过文案「先不记 · 明天见」零打扰零负罪（禁词全表断言零命中，含新增亏了/没了/花光/穷）
2. 估算记录 source=estimate（_confirm写transactions通道，中性类目其他+备注每日收口估算）；看板/周报天然合计（同一transactions表）；有今日真实记录shouldAskClose=false估算自动让位（单测锁定）
3. 收口开关默认开可关（closeEnabled无行即true单测+DAO widget断言；Zone首行Switch即时写库）
4. golden 三组 Light+Dark 六图（问句/已记/已记含今日攒出行；结构完整无重叠无截断，测试环境中文字体缺字为方块属既有现象，SB-013/014/015先例口径）
5. 「今日攒出」行：已记态固定反馈行TodaySavedRow，口径「今天攒出 ¥X · 够 N 杯奶茶」（单测锁定50元→够2杯奶茶）；金额=当日结余含估算（computeTodaySaved=日预算−今日支出）；saved≤0或<最小单价回null整行不出现（单测0/负/100/1799全null）；换算复用defaultPrices+cupUnit+formatFen无第二套；无1/N记号（大额40万不断言无/）；大额≥目标5% isBigDailySave供数（成就卡复用走既有AchievementGate，本卡不新造动效，本文件零裸Duration/Curves/Cubic）
6. `tool/ci.sh` ALL GREEN（format 0改动/analyze No issues/全量269/smoke/macos+apk双构建成功）+ `tool/check-repo-hygiene.sh` OK；`dart format` 0改动

文件约束：业务 10 文件 ≤10；单文件最大 400 行（app_db.dart恰顶）；无 pubspec 变更；无 remote；测试全合成 fixtures，真实账目=0；探针零使用（未写 /tmp，未建 probe 文件）。

偏差声明：
1. 卡注 schema v6 系过期编号（写卡时基座约v5）：实际 v7→v8 落地。source=estimate 本身无需新列（source列已存在），v8 新增 daily_closes + close_prefs 两表（开关与收口落点 persistence，无 shared_prefs 依赖故走 drift，沿 SB-011/015 拆分先例）；迁移+回滚语义与卡授权一致；属编号过期非口径变更（沿 SB-015 D1 既有结论口径）。
2. 测试文件2非3（widget并入golden单文件，沿SB-015先例）；卡预估7新建中DAO+迁移拆为store+dao两文件（app_db已396行顶，拆分经卡授权，业务总数仍恰10）。
3. sb006 四图重生成连带（首页挂同区所致，上方看板区像素不动，diff量级与SB-010先例一致）；sb007/sb014/sb015 零动。CHANGELOG 待 SB-012 统一补（沿用 SB-013/014/015 既有结论，不三提）。

请审计后结论写 `REVIEW.md`（PASS 或 REQUEST_CHANGES）。
