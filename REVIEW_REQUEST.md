# REVIEW_REQUEST — SB-019 分类角色轴

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-019-role`（未 merge、未 push、无 remote，合规）
任务卡：`docs/tasks/SB-019.md`（排期注 SB-015/017 之后；两者已合入，前置满足；SB-012 前置 019/020 之其一）
基座：`main@e004fce`（SB-018 审结 PASS 后；预建空分支与 main 同点零差异起步）
提交：`71ca614 feat(role)`（本轮业务+测试+golden 单 commit）

改动清单（业务 10 文件 ≤10，手写单文件最大 398 行 ≤400；golden png 不计）：
- `app/lib/logic/role_resolver.dart`（新建，133 行）：CategoryRole 必要/弹性/固定 + 默认映射（食/行/用必要，居固定，玩/其他弹性；其他归弹性=未知即暴露为可优化）+ 旧名归一（餐饮/交通/购物/居住/娱乐）+ 覆盖优先 + 未知兜底弹性（永无未映射态）+ validateRole（新建/编辑必选）+ isDiningSplitCandidate（食+聚餐，只引导不强制）+ summarizeRoles/elasticShareText（类目页头部供数）+ 禁词复用 achievementBannedWords
- `app/lib/data/category_role_store.dart`（新建，15 行）：RoleOverrides 表（category 唯一，role=必要/弹性/固定；表类取名避 logic 层 CategoryRole 枚举名冲突，见偏差 D4）
- `app/lib/data/category_role_dao.dart`（新建，81 行）：list/watch/roleOverrideMap/setCategoryRole（有行更新无行插入）+ ensureDefaultRoles（幂等补齐，已有覆盖不动）+ rollbackCategoryRolesToV10
- `app/lib/data/app_db.dart`（改，398 行）：import + RoleOverrides 入表 + schemaVersion 10→11 + onUpgrade from<11 建表 + 回滚索引；注释压缩让行 3 行（devKey 注 + try/catch 空块化，零语义改动）
- `app/lib/data/app_db.g.dart`（改）：build_runner 重生成（含 RoleOverride）
- `app/lib/ui/category_page.dart`（改，326 行）：头部本月弹性占比 hero（elasticShare/elasticHint，首页不放）+ 聚餐引导卡（diningGuide/diningCount，有候选才出现）+ 每类目角色三选 ChoiceChip（role-<类>-<角色>，落库覆盖）+ 自定义无覆盖必提示（rolePrompt-<类>，error 色）+ 原其他占比/规则/纠正区零改动
- `app/lib/ui/budget_card.dart`（改，365 行）：BudgetZone 外包角色流，transactions 先按角色过滤仅弹性，再复用 suggestBudget/computeBudgetSaved 原公式（禁第二套）；基线文案缀「· 仅弹性」；_BudgetBody 原聚合逻辑逐行未动
- `app/lib/ui/cooloff_card.dart`（改，326 行）：阈值 flows 先按角色过滤仅弹性，再复用 dailyAverage/cooloffThreshold 原公式（自定义仍优先）；候选加弹性过滤（固定账单不触发）；卡 UI 零改动
- `app/test/role_test.dart`（新建，24 条）：默认映射/旧名归一/兜底/覆盖优先/编解码互逆/validateRole/聚餐候选三态/聚合口径（30%/空/覆盖改写）/elasticShareText两态/预算联动（弹性中位数+固定不固化）/冷静联动（弹性日均×3+自定义优先）/DAO 幂等（6/0）/覆盖不动/更新语义/v11回滚/零禁词
- `app/test/golden_role_test.dart`（新建，6 条）：widget 3（弹性头行 25.0%/未选提示→选中消失+落库/聚餐引导不强制）+ golden 2（sb019 角色选择 Light/Dark）+ 对比度闸门
- golden（不计文件数）：新建 `golden/sb019/` 两图；重生成 `golden/sb005/` 两图（页新增弹性头+角色区，~24% 即新增区块）；重生成 `golden/sb014/` 周报两图（预算基线行缀仅弹性，422px）

验收对照（SB-019 卡 §验收 1~6）：
1. 全类目角色完整：默认 6 全覆盖 + 未知兜底弹性，resolveRole 永不 null；存量迁移 ensureDefaultRoles 幂等（首轮补 6、次轮 0）+ 可改（set overlay）
2. 本月弹性占比头行放类目管理页头部（elasticShare），首页零新增（home_page 未动，grep 验证）
3. 预算基线仅弹性（BudgetZone 过滤后复用原公式，单测锁定）+ 冷静默认阈值=弹性日均×3（复用原公式，自定义优先；固定账单候选过滤）
4. 聚餐拆分：isDiningSplitCandidate + 一次性引导卡（有候选才现，不强制改类；食仍解析必要，单测锁定）
5. 单测 ≥12：24+6=30 新，全量 360/360 绿（330 继承+30 新）
6. golden 两组 Light+Dark（sb019 选择/提示态）+ `tool/ci.sh` ALL GREEN（format/analyze/smoke/双构建）+ `tool/check-repo-hygiene.sh` OK

文件约束：业务 10 文件 ≤10；单文件最大 398 行（app_db）；无 pubspec 变更；无 remote；测试全合成 fixtures，真实账目=0（美团|工资|房贷 grep 零命中）；裸 Color(0x)/裸 Duration=0；探针零使用（未写 /tmp，未建 probe 文件）。

偏差声明（请监工裁决）：
1. schema v11 vs 卡注 v7：卡下发时 schema 为 v6（v7 系当时下一号），SB-016/017/018 连发后实际 v10→v11；迁移+回滚齐备，SB-015 同型先例（卡注 v5→实际 v6→v7，决策 p=0.79 按判接受）。
2. 新建类目无独立表单：全应用无创建类目入口（QuickAdd 固定表、类目页历来无新建），新类目=交易中新名出现即提示必选（validateRole 锁定 + rolePrompt UI + 单测覆盖）；独立新建表单随后续卡补（SB-018 D2 自设 UI 延后同型，p=0.72 灰区先例）。
3. golden 连带重生成：sb005（页新增区块 ~24%）+ sb014 周报（预算行后缀 422px）；CHANGELOG 随 SB-012 统一补（既有结论不三提）。
4. 表类取名 RoleOverrides（行 RoleOverride）：drift 单数化 CategoryRoles→CategoryRole 与 logic 枚举重名，改名避冲突；DB 表 role_overrides，v11 未发布前无兼容问题。

状态：待审查（2026-10-11 09:2x builder 提审·SB-019）
