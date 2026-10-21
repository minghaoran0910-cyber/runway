# REVIEW_REQUEST — SB-049 月度小实验语义收口（首审）

**卡**：docs/tasks/SB-049.md ｜ **分支**：feat/SB-049-experiment-copy@3b717f2（基于 main@af62e12）｜ **性质**：报修卡·浩然同批反馈③（监工票232落卡，SB-047/048 同批）。
- **执行体说明**：wake 守卫全过（main/无锁/树净/REQ 已审版）后建锁施工，一卡一轮。`_LOCK` find=0 起步，退场删锁。

## 卡 → 落地对照（采用卡内 14:50 勘正后方案，原监控指标 chip 清单失实已弃）

- **① 页首一句话解释**：`experimentIntro`——“选一个 7 天小实验，每天 3 秒打个卡，断卡不罚——省多少到时候按你实际打卡天数算给你看”（7 天制/3 秒打卡/断卡不罚/按实际打卡天数算，四机制全点名）。
- **② 日省额微提示**：`experimentDailyHint`——“日省额是建议值，可改”（仅提示语，不动计价逻辑；引擎 `dailySaveFen` 口径未动）。
- **③ 推荐置顶+折叠**：`recommendedExperimentIds`=[无奶茶周/自带午饭/不点外卖周] 默认常显 3 chip（≤4），其余 5 折叠进「看全部 8 个」/「收起推荐」（同 key `experimentShowAll` 复用 SB-048 控件规格口径）；选中项在折叠区时自动展开，避免选中态不可见。
- **④ 7 天打卡预览条**：开始钮上方 `experimentPreviewLabel`+`experimentPreview`（Row 7 段 Expanded，首段 accent 系高亮、后 6 段 surface2 灰；圆角走 `RunwayRadius.control`，颜色走 tokens 明暗两套；零动画=零裸 Duration/Curves，SB-018 动效审计用例仍绿）。

## 自检三件套 + 全量 + ci.sh 记录

- dart format --set-exit-if-changed . = 0 改动 ｜ flutter analyze --fatal-infos --fatal-warnings app = No issues ｜ tool/check-repo-hygiene.sh = OK
- 新回归 app/test/sb049_experiment_copy_test.dart = **7/7 绿**（解释句四关键词/建议值提示/默认3 chip+点开展示8/折叠区选中自展/预览条7段/开始钮在位/新增文案零禁词零说教）
- 全量 flutter test = **500/500 全绿**（基线 493 + 新增 7）
- tool/ci.sh 四闸门 = **EXIT=0 ALL GREEN**（format/analyze/smoke test/macos debug+apk debug 双 build ✓）

## golden 基线变更清单（10 帧，均系本卡选择卡改版所致）

- golden/sb018/experiment_light_select.png + experiment_dark_select.png（选择态：解释句/3 chip/提示/折叠入口/预览条/开始钮，目检无截断无溢出）
- golden/sb007/goal_light_empty+dark_empty+light_data+dark_data+light_done+dark_done.png（目标页内嵌 ExperimentZone 同步变化）
- golden/sb012/budget_home_light+dark.png（预算首页内嵌实验区同步变化）
- 成因链：改前 main 基线 `golden_goal`+`golden_home_budget` 实测全绿（stash 验证），排除预存红；新基线已逐张目检（选择态单卡+目标空态整页）：中文 tofu 系无字体测试环境常态，布局=标题/解释/3 chip/提示/折叠入口/预览 label+7 段条/开始钮依次排布，无贴边裁切。

## 声明

- 不 merge、不动 main、不 push origin；docs/tasks/SB-049.md 未动（沿 5093505 先例=提审不动卡）。
- 文件数 2≤10（app/lib/ui/experiment_card.dart 改 276→367 行≤400 + app/test/sb049_experiment_copy_test.dart 新 125 行；golden 10 帧按 D1 裁决不计数）；零禁区（tokens/pubspec/schema/规范/CI 配置均未碰）；依赖变更 0。
- 偏差申报：卡验收“用户能用一句话复述”需真人验证，测试以四关键词断言代替，请监工走查时复核；卡“开跑表单控件沿 SB-048 规格”——本卡选择页控件 key/ChoiceChip/中文断言口径与 SB-048 同法，折叠用 TextButton（SB-048 用 ExpansionTile 处为进阶表单，本卡为列表折叠，形态差异已在对照③说明）。

**R 申报**：SB-049 首审，请求按卡检查项验收。
