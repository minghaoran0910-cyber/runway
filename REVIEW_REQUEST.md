# REVIEW_REQUEST — SB-004 三秒记一笔（第 2 轮 · 返工第 1 轮问题 1+2）

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-004-quick-add`（未merge、未push、无remote，合规）
任务卡：`docs/tasks/SB-004.md`
commit：`1bf8f73 fix(quick-add): REVIEW第1轮两项返工 [SB-004]`（本轮 2 文件：`app/lib/ui/home_page.dart`、`app/test/widget_test.dart`）

问题对照（REVIEW.md 2026-10-10 SB-004 第 1 轮）：
1. 删除或重写 `app/test/widget_test.dart` 旧计数器测试 —— ✓已重写：旧「Counter increments smoke test」删除，改为两条主屏真实测试（空态冒烟 + 编辑→改类目→保存落库，合成数据+内存库）。`flutter test` 全量 27 项全绿（含本文件 2 条）。
2. `_edit` 类目选择即时回显 + 补 widget 测试 —— ✓ `home_page.dart` `_edit` 对话框包 `StatefulBuilder`，`onSelected` 走 `setDialogState`，点选即时高亮；widget 测试断言切换后 `ChoiceChip.selected==true` 且保存后落库类目为新值。另顺手落定非阻塞留观项之一：`note` controller 加 `try/finally dispose`。

验证：
- `flutter test` 全量绿（27/27，EXIT=0；含 entry/quick_add/golden/tokens/smoke/widget）
- `tool/ci.sh` 四闸门全绿（format 0 changed / analyze No issues / smoke pass / build macOS+APK 双产出，ALL GREEN）
- `tool/check-repo-hygiene.sh` OK；`lib/` 与 `test/` 零真实账目数据（合成 fixture 仅 test/）
- 文件约束：本轮改 2 文件，`home_page.dart` 187 行、`widget_test.dart` 约 100 行，无超限、无依赖变更、无 docs 规范改动

偏差声明（测试环境实测结论，请监工知悉）：
- T1：同环境 `await db.close()` 在 watch 订阅过后挂起不返回（HomePage 的 `watchAll` 流所致，非业务 bug；生产端开/关库路径不变）。本文件 widget 测试故不调 `close`（内存库随进程退出释放）。
- T2：unmount 卸载 watch 订阅时 drift `markAsClosed` 排零时长 Timer，须 unmount 后多 pump 几帧消化（`_unmountAndFlush`），否则 test 结束 invariant 报 pending timer。原理与调用栈已记 widget_test 文件头注释。

请审计后结论写 `REVIEW.md`（PASS 或 REQUEST_CHANGES，本卡第 2 轮/上限 3 轮）。
