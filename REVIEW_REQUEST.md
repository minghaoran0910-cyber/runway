# REVIEW_REQUEST — SB-028 视觉保真第一刀：记一笔三处硬伤闭环（首轮提审）

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-028-visual-fidelity`（未 merge、未推送，无 remote 操作，合规）
任务卡：`docs/tasks/SB-028.md`（状态：待办；依赖 SB-027 已于 23:1x 合入闭环，本卡接棒）
基座：`main@68e637e` 起步（本轮 commit 55da435 一笔，6 文件）
S0 守卫说明：S2 新卡轮（REVIEW 23:0x 结论 PASS 非 REQUEST_CHANGES，S1 不触发；SB-012 真人闸门在飞/SB-021 挂起 v0.2/SB-028 唯一待办）；S0.3 无 _LOCK（本轮创建退场即删）；S0.4 本轮改动 4 业务+2 golden；S0.5 本轮新写待审；S0.6 无显式 WAITING_HUMAN 标记行。

返工清单：不适用（首轮，非 S1 返工）。

施工清单（卡面 16:52 追加三处逐条闭环）：
1. 类目双命名统一短名系——`app/lib/logic/entry.dart` defaultCategories 长名 6 项→`食/行/居/玩/用/其他`（与 ruleCategories 同值同序；存量长名经 canonicalCategory 归一显示，新数据一律短名；home 页编辑框同源 `defaultCategories` 自动跟随，无第二处改动；零 schema 迁移，禁区未碰）。
2. 金额空态占位——`quick_add_page.dart` 预览 `—`→空态大号`¥ 0.00`（bodySmall 次要字色+tabular，headlineMedium 28；有值`¥ 12.34`主字色，输入即替换；对比度走 inkSecondaryText≥4.5:1 同闸门）。
3. 备注框描边——去默认黑硬 `OutlineInputBorder()`，改 r10（RunwayRadius.control）+hairline 常态/enabled+accentStrong 1.5 focused，全走现行 token 零新增。

动线审计（卡面 A，每项实测）：
- 记一笔≤3步：输金额→选类目→保存（quick_add_test 三例绿实证）。
- 首页到任何功能≤2跳：RootShell 三 tab 一按即达（SB-027 root_shell_test 绿，本轮复跑过）。
- 收口一键/通知入账：DailyCloseZone/PendingListPage 现行无改，路径未动。
- 视觉对照底稿：demos/shots/ 16 件在位复核（ed580f9 落库延续）；卡片阴影圆角沿用 CardTheme r16+AppTheme.ground/heroCard，零 token 改动；动效零散落参数（沿用 MotionSpec.press）。

验收对照（卡 SB-028）：
1. demos/shots 基线入库——已达标（前置 ed580f9，16 件本轮复核在位；本卡不重复入库）。
2. 监工看图签字——提请看图：golden/sb004/quick_add_light.png（md5 57389aac46d0a5a68280bd68ff471135，347266→351285B）、quick_add_dark.png（md5 b497472aac642b024960a152c8375604，186375→188908B）；像素变更仅三处修复所致（短名 chip+¥占位+备注框边框），目视已确认。真机实拍缺：live_shots 驱动已按三连裁①合入前删除，本轮未重建，提审附 golden 目审+监工亲看复验，请监工裁决是否补实拍。
3. 四闸门+golden 全绿——达标：`flutter test` 全量 417/417 绿；`dart format` 100 文件 0 改动；`flutter analyze` No issues；`tool/ci.sh` ALL GREEN（format/analyze/smoke/macOS+apk 双构建）；`tool/check-repo-hygiene.sh` OK。

测试：全量 417/417 绿（含 quick_add 3/widget 编辑改类目/entry 领域/golden_quick_add 再生后绿/root_shell+text_scaler 复跑绿）。

偏差声明（如实申报）：
① Hero 环形进度图/目标阶梯时间线/本周战报折线未新建——卡面做法②"（有数据时）/（SB-004 已有则确保可达+可见）/按 token"系对照验证口径，既有 DashboardHero/PriceSparkline/goal 阶梯页现行，本轮三处硬伤之外未扩 scope；成品超 demo 的版式升级留待监工看图后按意见迭代（成品须超 demo，验收权在浩然真机，见卡面 22:18 纠偏）。
② 真机实拍未附（见上验收 2），golden+md5 先行，补拍与否请监工拍板。

文件约束：业务 4 文件≤10（entry/quick_add_page/quick_add_test/widget_test）；golden×2 按 DEV §2 豁免计数；单文件≤400 行（quick_add_page 203/widget_test 100 实测）；无 pubspec；无 schema 迁移；未推送；真实账目 0；禁词零新增；_LOCK 本轮退场即删。

状态：待审查（2026-10-13 23:2x builder S2 首轮提审·SB-028；feat 分支未合入）
