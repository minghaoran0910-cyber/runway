# REVIEW_REQUEST — SB-011 续做授权应答提审（应答 01:4x CONTINUE_PERMIT · S0.1）

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-011-bill-import`（未 merge、未 push、无 remote，合规）
任务卡：`docs/tasks/SB-011.md`（账单文件导入，批次 G4 第 2 张）
基座：WIP 保全提交 `5f5ab9e`（数据层/解析/去重/批次撤销/性能/单测7绿/golden 四图）+ 本轮修复 commit（待审查轮核验 tip）

本轮范围（授权内最小 diff，只修测试红，不推倒重来）：
- 唯一改动：`app/lib/ui/bill_import_page.dart` 1 行——`_parseFile` 内 `if (!await f.exists())` → `if (!f.existsSync())`。
- 根因：旧代码先 `setState(_notice='')` 再 `await` 文件存在检查，`pumpAndSettle` 不等该 Future，测试在空窗期断言『文件不存在』得 0 命中（probe 实证：tap 后 notice count=0，修后=1 且文本『文件不存在』在位）。同步检查消空闪，真机亦是即时反馈优化。
- 禁区遵守：数据层/解析/去重/撤销逻辑零触碰；golden 基线未动（preview/result 四图本轮实测零回归，免重生成）；探针仅写仓内 `app/test/probe_sb011.tmp.dart` 且已删（`ls probe*` 无命中），未碰 `/tmp`；无 pubspec 变更；无 `docs/` 规范改动（`docs/ios-shortcuts.md` 系 WIP 既有交付物，非本轮新增）。

验收对照（SB-011 卡 §验收 1~5）：
1. 合成 fixture 解析正确+失败行行号原因：`bill_import_test` 支付宝 3 成功/2 失败（第4行金额无效/第6行非成功状态）+微信 ￥单位/对方为空失败行均绿；页面预览『可入账 2 笔·失败 1 行』+`failRow-4` widget 绿。
2. 去重+批次撤销：同账单两次导入 inserted 3→0/skippedDup 3、落库 3 条；确认入账→结果→撤销本批 widget 绿；`revokeImportBatch` 整批删除绿。
3. 性能：1 万行合成 parse≈159ms、total≈270ms <5s（本轮实测回显 `SB-011 perf` 行）。
4. 原文件不留副本：`importBillFile` 读后即删单测绿；批次表列名无原文列断言绿。
5. golden 四组+对比度：preview/result × Light/Dark 四图本轮全绿（零重生成）；对比度闸门绿；`dart format` 0 改动；`flutter analyze` No issues；全量 `flutter test` 178/178 绿；`tool/ci.sh` ALL GREEN；`tool/check-repo-hygiene.sh` OK。

文件约束：业务 9 文件（app_db.dart 399/app_db.g 生成除外/bill_import 269/import_batch 47/dao 98/page 338/单测175/页测193/ios-shortcuts 27）≤10，手写单文件最大 399≤400；无 remote；测试全合成 fixtures，真实账目=0。

偏差声明：无新增偏差。`existsSync` 为实现细节（语义与 `exists` 一致，仅消 async 窗），注释未增（单行同义替换，卡文义+DESIGN_SYSTEM 令牌无影响）。

失败出口未触发（已修好）。请审计后结论写 `REVIEW.md`（PASS 或 REQUEST_CHANGES）。
