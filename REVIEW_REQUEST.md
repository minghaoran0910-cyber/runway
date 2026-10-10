# REVIEW_REQUEST — SB-005 规则引擎自动归类

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-005-rule-engine`（未merge、未push、无remote，合规）
任务卡：`docs/tasks/SB-005.md`
commit：`fa029f8 feat(rules): 规则引擎自动归类+类目管理页 [SB-005]`（8 源码/测试文件 + 2 golden 基线图，共 10 文件；单文件 ≤253 行）

验收对照（任务卡 5 项）：
1. 内置默认类目表（食/行/居/玩/用/其他）+ 规则匹配单测 ≥20 样例 —— ✓ `logic/category_rules.dart`（179 条：关键词/商户同口径 + 6 条 latin 商户别名 + 苹果金额区间消歧对）；单测 22 个关键词样例 + 商户/金额专项，`ruleCategories` 即六标准名。
2. 纠正回写：同类商户/关键词第二次命中纠正后类目 —— ✓ `logic/category_feedback.dart`（商户键优先+归一化大小写/空格）；单测覆盖覆盖规则/商户优先/归一化/空键；类目页纠正入口经 `PopupMenuButton` 回写 DB + 同步学习（页测断言落库 + `lookup` 命中 + Snackbar）。
3. "其他"占比可查询 —— ✓ `CategorySummary`（otherShare/otherFault，>5% 严格大于）+ `data/category_stats.dart`（Transactions 行 → 汇总，含旧名归一）；类目页 Hero 卡展示占比 + 故障/健康态（页测断言 10.0% 故障态与 0.0% 空态）。
4. 引擎纯 Dart 无 Flutter import + 1 万条 <500ms —— ✓ 两 logic 文件零 flutter import（analyze 佐证）；性能单测实测通过（本机约数十 ms 量级）。
5. 四闸门全绿 + hygiene OK —— ✓ `tool/ci.sh`（format/analyze/test/build macOS+APK，ALL GREEN）+ `check-repo-hygiene.sh` OK；全量 `flutter test` 47/47 绿（含 SB-004 回归 27 项）；golden `sb005/category_{light,dark}.png` 新建并比对通过；对比度闸门绿。

验证：
- `flutter analyze --fatal-infos --fatal-warnings app`：No issues
- 文件约束：10 文件（lib 4 含 home_page 1 处 AppBar 入口编辑、test 3、golden png 2），无依赖变更（pubspec 0 改动）、无 schema 变更（只读 transactions）、无 docs 规范改动

偏差声明（请监工知悉）：
- D1：纠正表为会话级内存存储，跨重启不持久。卡未要求持久化，引擎 API（record/lookup 注入）已为文件/表持久化预留；建议 G4 前落地。
- D2：备注为空的记录纠正时只改库不学习（无键可存）；影响限于空备注行。
- D3：新旧类目名并存：引擎标准名为短名（食/行/居/玩/用/其他），SB-004 旧长名经 `legacyCategoryAlias` 在统计层归一；QuickAdd 默认类目与主屏编辑框未动（防 SB-004 回归），全量短名统一待后续卡。
- T1：widget/golden 页测沿用 SB-004 实测结论（watch 流 unmount 零时长 Timer → `_unmountAndFlush`，不调 `db.close`），原理见测试文件头注释。

请审计后结论写 `REVIEW.md`（PASS 或 REQUEST_CHANGES，本卡第 1 轮/上限 3 轮）。
