# REVIEW — 2026-10-10 G3·SB-007 目标阶梯与实物换算（第 1 轮）

结论: PASS

检查项:
- [x] 验收1 目标 CRUD：goal_page.dart（chips 内置奶茶1800/键盘29900/手机399900/5090 1649900 可自定义）+ app_db.dart Goals DAO（list/watch/insert/update/delete）
- [x] 验收2 换算引擎：goal_ladder.dart 纯 Dart（grep 确认零 flutter import）；单测 17 条 ≥15，含月光月"基线花光但环比增量省出2杯"用例
- [x] 验收3 实时联动：watchGoals+watchAll 双流重算；widget 测试"记一笔后换算文案联动"在案；home_page 传真实 goalFen（闭环 SB-006 D1）
- [x] 验收4 得到框架：禁词全量扫描"又花掉/只剩/还差/超支/别买/不该"仅存在于注释说明，代码/UI 字符串零命中；大额 equivalentOf 只陈述无行动召唤；空态"定第一个目标，开始攒出奶茶"
- [x] 验收5 golden 四组：golden/sb007/ 4 张新建；全量 84/84 绿（59 继承+25 新增），SB-006 golden 零回归（main 与 HEAD 对 golden/sb004-006 + docs/ 零 diff）
- [x] 闸门复跑：flutter analyze --fatal-infos --fatal-warnings No issues；flutter test 84/84；check-repo-hygiene OK
- [x] schema v2 合规：仅新增 goals 表（卡内显式授权禁区仅此）；onUpgrade v1→v2 createTable(goals)，存量 transactions 不动；rollbackGoalsToV1 开发期回滚在位
- [x] 依赖变更：pubspec 0 改动（git diff main..HEAD 确认）
- [x] 文件约束：代码文件 9（≤10），最大 goal_page 341 行（≤400）；g.dart 生成文件豁免沿 SB-004 先例
- [x] 红线：新增代码/测试/文档扫描无真实账目数据（全合成 fixtures）；无 git remote 未碰
- [x] commit 规范：8092cfc 带 trailer `Agent: opencode`；分支 feat/SB-007-goal-ladder 命名合规
- [x] 模拟器冒烟：PASS — main@5f99099 squash 后 `flutter build apk --debug` 成功；runway_api36 boot=1（5×3s 轮询）；adb install -r Success；am start 启动 → Displayed +10s535ms；30s 后 pid=2586 存活；logcat 主日志+crash 缓冲 FATAL EXCEPTION=0；emulator/adb 已清理

偏差裁决:
1. D1（13 文件含 golden 4 张）：接受。代码文件 9≤10 卡预估；golden 基线为验收 5 明示产物，沿 SB-006 先例随附。
2. D2（入口为目标卡 GestureDetector 点击，无显性图标）：接受。SB-006 golden 零漂移优先；显性入口按规范流程 G5 打磨补。
3. D3（默认基线=上月实际时，比基线多省与环比增量等额、总额×2）：接受为卡口径字面实现（PRD §3 两项相加）。留观：接入月预算基线时（G4 前后）复核去重口径，周报文案（SB-010）统一时一并核对，避免"多省"虚高。
4. D4（doneAt/tier 建列不写入）：接受。成就写入归 SB-008/G3 后续卡，tier 由 ladderNameFor 推导口径认可。

问题列表:
1. 无阻塞问题。非阻塞备忘：goal_ladder.dart 注释中"攺"为"攒"之笔误（第 38/117/126 行附近，仅注释不影响文案），下轮任意卡顺手提一下即可，不必单独返工。

下一步:
- 已 squash 合入 main@5f99099（监工授权舞步：合入→checkout main→删 feat 分支→回填卡状态→归档本审+冒烟）。
- 开发方按 docs/tasks/SB-008.md（成就卡·G3）继续；首页目标入口已闭环，SB-008 直接消费 goals 表。
- G3 进度：目标阶梯 ✓（本卡），成就卡/安全垫/周报待 SB-008/009。
