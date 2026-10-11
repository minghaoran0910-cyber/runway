# REVIEW_REQUEST — SB-022 零日温度线（v3 返工轮 · 应答第 1 轮 RC，规范变更不计 R4）

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-022-zero-warm`（未 merge、未 push、无 remote，合规）
任务卡：`docs/tasks/SB-022.md` v3（21:47 打趣风 + 21:50 点名制 + 22:56 D2 结案 N 含估算补记；SB-020 已归档，前置满足）
基座：`main@cf7a646`（feat 侧 merge main 取 v3 卡 + RC 票，commit 91d7d78，progress 按时序 union 解冲突）
提交：`437a5fd feat(close)`（v3 返工：3 lib + 2 test + golden 2 图新建）
应答：REVIEW.md「SB-022 第 1 轮 · REQUEST_CHANGES」返工清单 1~5（逐条，D1/D2 按裁决执行）

返工改动（代码 5 文件 ≤10，无 pubspec，单文件最大 397）：
- `app/lib/logic/week_warm.dart`（改，92→150 行）：新增 `JoyRow` 小类（当日行：amountFen/category/note/source；logic 不碰 drift）+ `overspendHeadline`（虽然今天多花了 ¥X，X=|saved| 走 formatFen）+ `pickJoyNotes`（当日弹性 + source≠estimate + note 非空，金额倒序取 ≤2 笔原样返回；note 空=无名可点走退档链，D1 按卡判）+ `overspendSecondLine`（三级退档：点名句「但买了X，取悦自己不叫乱花」→ 有固定/必要行则通用交代「但该交的都交上了，日子在稳稳过」（禁点名不存在物件）→「但账记明白了」）+ `overspendComfort`（周中了犒劳犒劳自己吧。工作辛苦了。明天努力💪，零感叹号）；`warmExtendedBannedWords` 去多花/多花了（诚实事实词），仅保留浪费增补（成就表零触碰，`same()` 仍锁）。
- `app/lib/ui/today_saved_row.dart`（改，80→126 行）：新增 `joyRows` + `roleOverrides`（默认空）；saved>0 路径一字不动；saved==0 原三段一字不动；saved<0 新分支 4 段（overspendHeadline/joyLine/overspendComfort/weekRoleLine，Key 独立）。
- `app/lib/ui/daily_close_sheet.dart`（改，381→397 行）：`DailyCloseCard` 透传 joyRows + roleOverrides（默认空，直构调用方零改）；`DailyCloseZone` 在闭包外一次组装当日快照（与 today 同自然日口径），闭包内只读引用。
- `app/test/week_warm_test.dart`（改，10→17 例）：翻转多花断言（扩展集不再含多花/多花了，浪费/超支仍在）+ 新增首行格式与扫描放行、点名单笔/合并≤2/估算与空备注排除、退档通用句与编造防护（房租/水电/奶茶/霸王茶姬四词零命中）、无行可退记账句、犒劳零感叹号零禁词、负结余全量扫描。
- `app/test/golden_zero_day_test.dart`（改，+2 widget +2 golden）：负结余三段全现身且「今天攒 0」零现身、退档链 widget、golden 负结余 light/dark 双态、全量扫描含负结余文案。
- `golden/sb022/overspend_light.png` + `overspend_dark.png`（新建）：负结余双态基线。

验收对照（卡 v3）：
0. 负结余打趣三段 + 点名制：首段诚实承认（单测锁格式 + formatFen）+ 点名当日最大弹性真实 note（估算行/空备注排除单测锁，原样引用禁换算，widget 锁「霸王茶姬」现身）+ 无名可点退档链（通用句禁编造，单测锁四词零命中）+ 犒劳前瞻（零感叹号，💪 在场）；「今天攒 0」仅 saved==0 可用（负结余 widget 锁 findsNothing）；去向行保留（weekRoleLine 第四段）；N=全量口径含估算（`todayCount: today.length` 未动，D2 浩然 22:56 裁 A，卡已同步）。
2. 禁词修正：多花/多花了移出扩展集（翻转断言实证首段可说）；超支/浪费/不该/别买/还差/花光/亏了/穷维持禁用（浪费增补保留 + 成就表 10 词原样，单测 + golden 双锁零命中）；成就表零触碰（`same()` 锁仍绿，又花掉≠多花无冲突）；非零日与 SB-016 完全一致（saved>0/==0 路径一字不动，全量 409 通过实证）。
3. 只 import 现有纯函数（weekStartFor/resolveRole/formatFen/achievementBannedWords，无第二套判定/公式/表）；`tool/ci.sh` 四闸门全绿。

测试：`flutter test` 全量 409/409 All tests passed，exit=0（398 继承 + 11 新增），无挂死（15s 实测）；`dart format` 5 文件 0 改动；`flutter analyze --fatal-infos --fatal-warnings` No issues；`tool/ci.sh` ALL GREEN（format/analyze/smoke/双构建 ✓Built）+ `bash tool/check-repo-hygiene.sh` OK。

文件约束：代码 5 文件 = 3 lib（week_warm 150/today_saved_row 126/daily_close_sheet 397）+ 2 test（week_warm 202/golden_zero_day 254）≤10；单文件最大 397≤400；无 pubspec；无 remote；真实账目=0；裸 Color(0x)=0（app/lib，theme/motion 外）；新/改 UI 文件裸 Duration/Curves/Cubic=0（单测锁）；禁词文案零命中（双锁）；_LOCK 本轮退场即删。

偏差声明：①sb016 done×2 / sb006 data×2 未重生成——负结余分支为新增档，saved>=0 渲染路径一字不动，全量 golden 实测通过（零像素差实证，属对照实验口径非省略）；sb022 zero 双图同步字节零差免重生成。②D2 口径 todayCount 含 estimate（浩然 22:56 裁 A，卡已同步，代码沿旧口径零改）。③JoyRow 用小类而非 record——纯 400 行红线下的等价表达（record 字面量在 Zone 侧多占 7 行），语义与 RC 清单一致。

状态：待审查（2026-10-11 23:4x builder 提审·SB-022 v3 返工轮）
