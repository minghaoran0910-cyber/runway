# REVIEW_REQUEST — SB-051 §6动效体系四页落地（重开首审 · 轮次归零后第1轮）

**卡**：docs/tasks/SB-051.md ｜ **分支**：feat/SB-051-motion@2dbb133（基于 main@860ca57干净重切；旧 feat 已删，归档 archive/SB-051-motion-r3@acb24ce 只读参照）｜ **性质**：浩然裁B重开（R141/票352），前三次RC作废不计熔断。
- **执行体说明**：wake守卫全过（main/无锁/树净/REV新于REQ）后建锁施工，一卡一轮。`_LOCK`起步find=0，退场删锁。

## §6清单逐项落点/豁免

- **按压反馈120–160ms scale .96**：`MotionPressable`（MotionSpec.press/emphasizedDecelerate＋.light触觉，pointer-down即响应）→ 目标页换算卡（key goalPricePick由GestureDetector移至MotionPressable，tap透传）、实验页chip选择。
- **状态变化/数字滚动220–320ms**：`MotionCountUp`（MotionSpec.state＋emphasizedDecelerate，tabular随style透传）→ 实验打卡进度（key experimentProgress保留）、类目hero弹性占比；环扫与数字同帧沿用ProgressRing同一进度函数。
- **页面转场320–400ms shared-axis Z＋轻视差**：`MotionTabSwitch`（淡入＋15px上浮视差＝MotionSpec.listRise，四端同一语言；child透传IndexedStack保状态、动效不阻塞输入）。完整shared-element豁免：三tab无跨页共享元素，淡入＋视差为约定简化版。
- **Sheet/弹层进280出220**：豁免——本卡未新增弹层，GoalDialog沿原生，MotionSpec.sheetIn/Out常量在位无散落参数。
- **列表入场stagger 80ms/行＋上浮14–16px仅首屏**：`MotionStagger`（MotionSpec.stagger/listRise，index>6截断延迟）→ 目标/类目/设置/实验区。
- **FAB/成就卡easeOutBack唯一过冲＋成就900–1200ms粒子≤12**：沿用achievement_card现有实现，本卡零新增过冲。
- **spring全局临界阻尼可打断**：AnimatedScale/Opacity/Slide均可从当前值打断重定向，不锁输入。
- **reduce-motion降级80ms fade**：四构件全分支MediaQuery.disableAnimations（无位移无过冲无触觉）；Stagger用可取消Timer，测试teardown零残留。
- **触觉**：新增选择回弹.light；记一笔/存目标.light、达标.medium沿SB-044先例。
- **shimmer≤300ms**：豁免——本卡无新增加载骨架。

## 与归档r3的差异（重开干净度声明）

- r3分支含越界改动（RunwayIcon→Material Icons替换、SB-049推荐折叠/预览条删除、docs卡归档搬移、golden PNG重刷）。本轮**全部剔除**：图标体系/SB-049/SB-050/既有golden基线零触碰，纯动效落点。
- motion_kit.dart与sb051_motion_test.dart内容同r3实证版（8/8已验），属新文件重建；五页改动基于当前main（含SB-049/050）手工重落，非cherry-pick。

## 五页落点

- 目标页goal_page：hero/换算卡/时间线/实验/预算区stagger 0–4＋换算卡Pressable（key goalPricePick保留透传）。
- 实验experiment_card：chip选择Pressable回弹＋打卡进度CountUp（key experimentProgress保留；SB-049推荐/折叠/预览条原样保留）。
- 类目category_page：hero stagger＋占比CountUp（round值与原toStringAsFixed(0)等值）＋角色墙/近期记录stagger。
- 我的settings_page：两卡stagger 0–1。页转场root_shell：MotionTabSwitch包IndexedStack。

## 自检三件套＋全量＋ci记录

- dart format --set-exit-if-changed ＝ 0改动 ｜ flutter analyze --fatal-infos --fatal-warnings app ＝ No issues ｜ tool/check-repo-hygiene.sh ＝ OK
- 新回归 app/test/sb051_motion_test.dart ＝ **8/8绿**（Spec值域/CountUp收敛/reduce直显/Pressable回弹/Stagger首尾/reduce无位移/TabSwitch切换/常量约束）
- 全量 flutter test ＝ **512/512绿**
- tool/ci.sh四闸门 ＝ **EXIT=0 ALL GREEN**（format/analyze/smoke/macos debug＋apk debug ✓）

## golden基线变更清单

- **零文件变更**：既有基线一次过（终态截图）。app/test/golden_home_budget_test.dart：_settle 300→800ms（首屏最大延迟4×80＋入场260＝580ms覆盖），注释已标SB-051。

## 审美复审与动效audit截图（偏差申报）

- 偏差①（audit截图）：卡要求四页各2帧动效audit截图——builder无设备在册（沿票279/281/316口径，本轮仍缺实拍），动效验收需24fps reel静图不可代，headless不可达。本次以8例widget回归＋golden终态一次过为证替代，**按重开令明示「截图待SB-052管线授权」，请监工随补拍轮一条龙补实拍**（同一待裁事项，不新起呈报；预计仍判REQUEST_CHANGES第1轮·重开，等裁①/豁免即合）。
- 偏差②（hallmark/taste）：未调用外部审美skill；复审为DESIGN_SYSTEM §1六原则自查：形状仅r16内容卡无第四形状、颜色零新增tokens、强调色无新增、高饱和≤1、数字tabular、hairline仅既有分隔——通过。
- 偏差③（key语义）：goalPricePick由GestureDetector移至MotionPressable（tap透传，sb040/sb048测试绿）；环中心Text→MotionCountUp等值替换。
- 不merge、不动main、不push origin；docs/tasks/SB-051.md未动。
- 文件数8≤10（app/lib/ui/widgets/motion_kit.dart新208行＋5页修改＋test新127行＋golden测试口径1行；golden png零计数；单文件最大376行≤400；零禁区tokens/pubspec/schema/CI；依赖变更0）。

**R申报**：SB-051重开首审，请求按卡检查项验收（§6清单落点/豁免＋测试＋golden终态）。
