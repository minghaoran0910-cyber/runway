# REVIEW_REQUEST — SB-029 首页 hero 视觉升级：环形进度+公式行+水印归位（首轮提审）

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-029-hero-ring`（未 merge、未推送，无 remote 操作，合规）
任务卡：`docs/tasks/SB-029.md`（状态：待办；依赖无；SB-030 排本卡后）
基座：`main@d270bf1` 起步（本轮 commit 一笔，见文件约束）
S0 守卫说明：S2 新卡轮（REVIEW 00:0x 结论"无新审查请求"非 REQUEST_CHANGES，S1 不触发；SB-029/030 待办，取 SB-029 一单；SB-012 真人闸门在飞/SB-021 挂起 v0.2 与本卡无关）；S0.3 无 _LOCK（本轮创建退场即删）；S0.4 工作树本轮改动外干净；S0.5 REVIEW 新于 REQ（等监工审本轮）；S0.6 无显式 WAITING_HUMAN 标记行（旧文第 6 行元叙述按 20:0x 裁定豁免）。

返工清单：不适用（首轮，非 S1 返工）。

施工清单（demo 原件 demos/shots/home-light.png 对照，成品须超 demo 动线优先）：
1. 环形组件 `app/lib/ui/widgets/progress_ring.dart`（新建 89 行）：CustomPaint，§5 外框 96/r40/线宽 9/圆头；轨道=hero glow token（18% ≥8% 下限）；弧=白→亮灰蓝 Sweep 渐变（均为现行 token）；外沿 44.5<48 零贴边；入场动画 TweenAnimationBuilder 走 MotionSpec.state+emphasizedDecelerate（零裸时长）；圆心 child 由调用方传（SB-030 目标页可复用）。
2. 跑道口径 `app/lib/logic/dashboard_stats.dart`（+126 行，纯 Dart 禁 flutter 维持）：自然月三桶 m0/m1/m2（跨年进位）+月刚性（必要+固定，默认角色映射）；可动用=computeGoal(m0,m1).convertible（SB-007 原公式复用，禁第二套）；分母=上月刚性>0?上月:本月；runway=可动用/分母；delta=runway−prevRunway（m1/m2 同口径）；runwayFraction 满环=12 个月（0/负归 0，溢出钳 1 数字照实）；formatRunway/formatRunwayDelta 纯函数。
3. hero 重写 `dashboard_cards.dart`（377 行限内）：标题=首个目标名（无目标回落"本月支出"，"（示例数据）"删除）；右上琥珀行 heroCompare（有上月"比上月 ±N 个月"，无"首月记账中"）；环内大数字 homeTotal 键保留（SB-004 回归，值为跑道月数 1 位小数 tabular+"个月"单位）；金句 heroVerdict（有目标 nextLadderHint/有可动用 equivalentOf/否则"记下第一笔，开始攒跑道"，全得到框架零亏欠）；公式 heroFormula（"可动用 ¥X ÷ 刚性 ¥Y/月"，formatFen 原口径无千分位）；今日/其他占比 dashOtherShare+故障态双键全保留。
4. `home_page.dart`（+22 行）：goalName 透传；ListView 底加浅灰水印 homeWatermark（"示例数据"，bodySmall+inkSecondaryText 降淡 55%，不用 inkSecondary 守 §2.1 禁做小字）+底部 80 安全垫（FAB 不压字）。
5. 新单测 `app/test/progress_ring_test.dart`（8 例）：fraction 四态 0%/50%/100%/溢出+显示/符号函数+三桶口径实算（m0=5000/m1=12000/m2=10000→可动用 14000/分母 12000/跑道 1.1667/"1.2"/"+1.2"）+空态全零+hero widget 四键+空态标题回落/水印+深色渲染+溢出弧满。

验收对照（卡 SB-029）：
1. 实拍前后对照+审美审计——builder 无模拟器自动驾驶驱动（SB-027 三连裁①合入前删除，本轮未重建，避免驱动残留重蹈 21:0x 崩溃）；代以 golden 新旧对照（md5/字节见测试节）+本单审美审计小节，请监工按 A 口径模拟器实拍补验（缺口如实申报）。
2. golden 更新+肉眼过审+环形四态单测——达标：sb006×4+sb012 首页×2 再生，builder 目审变更仅 hero 区（环/琥珀行/金句/公式）+页底水印两处；其余卡片/列表零像素漂移（Top5 条/预算区/记录行与旧基线同位）；425/425 绿含新 8 例。
3. 深色同验+四闸门——达标：hero 深青渐变双模式同一套（无 isDark 分叉，dark golden 目审在位）；`tool/ci.sh` ALL GREEN（format/analyze/smoke/macOS+apk 双构建）+hygiene OK。

测试：全量 425/425 绿（基线 417+本轮 8）；`dart format` 0 改动；`flutter analyze` No issues；golden：dashboard_light_data 7725c45d（303240B）、dashboard_dark_empty fb2a1778（228452B）、dark_data/light_empty/sb012 首页双色 md5 见 commit（sb012 首页与 sb006 同页同值：dark fd1d48ea/light 7725c45d）。

审美审计小节（hallmark/taste 技能本仓缺位，直引 DESIGN_SYSTEM §1 六原则逐条结论）：
1. 地面与浮起——hero 仍 r22 深青主卡悬浮浅灰蓝地面，无通栏直角，过。
2. 形状三档——新增环（圆，§5 规范形状）+r22/r16/r10 原样，纪念碑式数字仍在环内，无第四种，过。
3. 留白阴影——hero 内环文间距 12/16，行分隔未新增线框，过。
4. 数字一等公民——环内 28pt+公式/对比行全 tabular；主数字与其下公式行差 16pt（28 vs 12）≥12pt，过；公式无千分位分隔，tabular 下等宽对齐仍成立，弱项留后续。
5. 动效因果——环入场 260ms emphasized 扩张（从哪来到哪去），成就过冲未动用，过；count-up 数字滚动未做（静态数字+弧动画），弱项申报。
6. 装饰可见性+单强调——轨道 18%/弧高亮可见；高饱和仅琥珀对比行一处（verdict 白字/公式次白字不抢），过。

偏差声明（如实申报）：
① 用户角色覆盖未接入 hero 刚性（BudgetZone 系独立流，hero 用默认映射；偏差面小：默认覆盖 6 短名全表，自定义角色用户刚性口径待后续卡接流）。
② 金额无千分位（沿用 formatFen 原口径；demo "¥36,120"式分隔待 DESIGN 收敛条款，单开 token 外事项，不擅自造格式函数）。
③ 满环=12 个月为展示尺度（一年跑道满环；非金融断言，公式行数字照实）。
④ 模拟器实拍缺（见验收 1），golden+md5 先行，补拍与否请监工拍板。
⑤ 金句"撑过 N 次急诊"式未采用（急诊单价无真相源不编造；用 nextLadderHint/equivalentOf 现行文案）。

文件约束：业务 3 改+2 新=5≤10（dashboard_stats/dashboard_cards/home_page/progress_ring/progress_ring_test）；golden×6 按 DEV §2 豁免计数；单文件≤400 行（最大 dashboard_cards 377 实测）；无 pubspec；无 tokens；无 schema 迁移；未推送；真实账目 0；禁词零新增；_LOCK 本轮退场即删。

状态：待审查（2026-10-14 00:3x builder S2 首轮提审·SB-029；feat 分支未合入）
