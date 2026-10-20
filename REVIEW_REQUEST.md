# REVIEW_REQUEST — SB-047 账本页信息结构修复（提审·首审）

- **卡**：docs/tasks/SB-047.md ｜ **分支**：feat/SB-047-ledger-info@baafdd1（基于 main@b2f611d）｜ **性质**：报修卡（浩然 14:50 主 session 反馈①），角色三选为规则引擎输入不可删，纯展示层修复。
- **缘起**：零记录下整页=角色选择题墙（6 卡×3 chip=18 个点击目标，全 ¥0），占比只有数字无视觉。

## 改动→验收对照
- **页首占比可视化**：hero 改 Row，右置复用首页 `ProgressRing`（`elasticRing`，fraction=本月能省占比）；副句 `elasticHint` 由 bodySmall 提级 bodyMedium（可读主文案，颜色仍 RunwayHero.sub）。
- **空态重设计**：零记录时只出一张引导卡（`emptyCatHint`=「去记一笔，占比与角色在这里等你」+副行），角色墙与近期记录隐藏；记录>0 恢复。
- **角色墙默认折叠**：新组件 `category_role_wall.dart`（`CategoryRoleWall`，ExpansionTile，initiallyExpanded=false）；墙头「N 类待选」+红点（`roleRedDot`）；人话三行（`roleExplain-*`：要花的=刚需不压；能省的=预算与冷静期压它；固定的=房租贷款弹性之外）；未选行红点（`roleDot-$c`）+原红字提示保留（`rolePrompt-$c`）。
- **DEBUG 水印**：全库 grep `DEBUG` 零命中（app/ tool/），无事可做，见偏差。

## 验证
- 自检三件套：`dart format` 0 改动 + `flutter analyze` No issues + 相关测试 4/4（category_page 新增 SB-047 折叠/解释/红点/占比环用例）。
- 全量：487 All tests passed（486 基线 + 1 新增）。
- `tool/ci.sh` 四闸绿 + `bash tool/check-repo-hygiene.sh` OK + macOS/app-debug 双 build 绿。
- 金样联动（声明）：sb005 category_light/dark + sb019 role_light/dark 各翻新（折叠墙+占比环布局变化）；其余金样零动。
- 模拟器实拍：无（布局变化由金样 4 帧 + 单测锁定，合入轮请监工走查补拍，沿 SB-046 先例）。

## 偏差声明（如实报，未修无隐瞒）
- 卡面补据图证目录 `runway-shots/2026-10-20-feedback/` 盘上不存在（builder 侧三次补据未落盘或在主会话侧），未按实拍走查，改由金样+单测锁定。
- DEBUG 水印：全库零命中，正式版/试装期无差异可去，记零改动。
- 文件计数 4≤10 合规：lib 2（category_page.dart 288 行、category_role_wall.dart 140 行，均≤400）+ test 2（category_page_test、golden_role_test）；golden 4 按 DEV §2.2 不计数；依赖变更 0；不碰禁区（tokens/pubspec/schema/规范/CI）。
- R1 申报：本卡首审。
