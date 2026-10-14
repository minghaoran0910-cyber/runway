# REVIEW_REQUEST — SB-038 首页大扫除（S0.1 一次性续做授权提审）

- **卡**：docs/tasks/SB-038.md（待办→提审）；**分支**：feat/SB-038-home-cleanup@441847b（留在 feat，未 merge/push main，S0.1 授权已消耗即失效）
- **断点承接**：17:0x builder 崩溃现场 home_page.dart 半成品（-12/+4）由监工抢救至本分支@wip；本轮按授权范围续做至提审，无扩 scope、无新工作面。

## 变更清单（5 文件+12 基线，≤10 合规；golden 不计）
- app/lib/ui/home_page.dart（234 行）：删 Top5/目标卡入口/DailyClose/Cooloff/Experiment/Budget 四区+全量列表，留 Hero 环+今日卡+最近3笔（rows.take(3)+recentTitle）+空态引导+水印+FAB；顶栏只留待确认（类目入口已下线，账本 Tab 即类目管理页）；删 category_page/goal_page 未用 import。
- app/lib/ui/goal_page.dart（400 行，顶格未超）：我的页 GrainZone 后接搬家四区 DailyCloseZone/CooloffZone/ExperimentZone/BudgetZone（口径零改，复用同一 Zone；实物换算本就属我的页）。
- app/test/dashboard_page_test.dart：改写为搬家后契约（首页=heroRing/dashToday/recentTitle、无Top5/目标/预算；我的页四区 key 可达断言）。
- app/test/golden_home_budget_test.dart：改泵 GoalPage（预算宿主迁移）；常动组件 pumpAndSettle 永不收敛→改定泵（300ms+1 帧）。
- app/test/golden_goal_test.dart：CRUD 单加拖回顶部再断言（页变长致顶部卡滚出被 ListView 卸载）。
- golden 重生成 12 张：sb006（首页新布局）/sb007（我的页接四区）/sb012（内容=我的页预算区，路径沿用）。

## 自检
- dart format：0 改；flutter analyze：No issues；相关测试 16 项全绿（dashboard/root_shell/goal/home_budget）；tool/ci.sh 四闸 ALL GREEN（含 macOS+APK 双 build）；check-repo-hygiene OK。

## 验收对照（卡）
- 首页首屏=环（含大数字滚动+琥珀比上月+可动用÷刚性公式）+今日卡（本月笔数/本周在内）+最近3笔+FAB ✓（证：golden/sb006/dashboard_light_data.png 即新首屏）
- 收口/冷静/实验/预算观察全在"我的"页，功能零丢失 ✓（widget 四 key 断言）
- 右上角双图标→一条：类目入口删除，顶栏仅 pendingEntry ✓；类目管理由账本 Tab 承载（CategoryPage 未动）
- 不碰禁区：tokens/pubspec/schema/CI/docs 规范零改；无新依赖。

## 偏差声明
- golden_goal CRUD 取证手法适配（拖回顶部）与 home_budget 定泵化：测试时钟/口径零改， Exhibit 行为等价（CRUD 在授权前 main 实测通过，搬家致懒加载卸载是唯一变量）。
- sb012 基线路径名含 home 实为我的页内容：为减 churn 沿用路径，内容已是新宿主；由本单注明。
- goal_page.dart 400 行恰顶格：后续 SB-039/040 若再加码须先拆卡。
