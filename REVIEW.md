# REVIEW — 2026-10-10 SB-004 三秒记一笔（第 1 轮 · 卡 SB-004）

结论: REQUEST_CHANGES

检查项:
- [x] 分支/提交合规：`feat/SB-004-quick-add`@d540d56+803ecd8，未 merge 未 push 无 remote，工作树干净，commit 带 [SB-004]
- [x] 禁区授权链完整：schema v1 为卡内显式授权；`docs/adr/ADR-001-存储选型.md` 先于依赖落地，选型/否决项记录规范
- [x] 分层合规：`logic/entry.dart` 零 flutter import；data/logic/ui/main 四层方向正确；金额以分存整数、上限防误触
- [x] 监工独立跑绿：`tool/ci.sh` 四闸门 exit 0（format 0 changed / analyze 零告警 / smoke / build macOS+APK 双产出）；`check-repo-hygiene.sh` OK
- [ ] 全量测试不绿：`flutter test` 实测 **+25 -1**，红在 `app/test/widget_test.dart`「Counter increments smoke test」——main.dart 占位计数器已退役，该旧测试未删未改。ci.sh 闸门只跑 smoke_test.dart 恰好掩盖。违反 DEV_WORKFLOW §2.5「自检三件套提交前本地跑绿」
- [ ] 编辑交互不可信：home_page.dart `_edit` 对话框类目 ChoiceChip 的 onSelected 只改局部变量、无 StatefulBuilder/setState，点选后高亮不更新，用户看不到选中态；编辑流零 widget 测试。违反卡验收 3（可改须可用）
- [x] 验收 1（≤3 秒）：三步流 widget 测试覆盖成立，录屏缺口认可 D3——合入后由监工模拟器走查补证
- [x] 偏差裁决 D1：去 sqlite3_flutter_libs 防 .so 符号冲突，ADR-001 已留痕 → 接受
- [x] 偏差裁决 D2：文件数 10 手写+生成/副作用豁免（.g.dart 642 行不手改，golden/锁文件/cmake 合规）→ 接受
- [x] 红线合规：grep 复核 lib/ 与 test/ 零真实账目数据，测试全合成 fixture；SQLCipher pragma+TODO(G4 迁 Keychain) 与快照 watch_items 一致
- [x] 样式合规：UI 零裸 hex、动效全走 MotionSpec；仅少量裸间距（8/12/24）在 §2.2 网格上，暂不阻塞

问题列表:
1. 删除或重写 `app/test/widget_test.dart` 旧计数器测试（它测的对象已退役），保证 `flutter test` 全量绿——建议顺手改成主屏真实冒烟。
2. `_edit` 对话框类目选择须即时回显（StatefulBuilder 或等价方案），并补一条「编辑→改类目→保存」widget 测试。

下一步: 返工后重发 REVIEW_REQUEST（本卡第 1 轮/上限 3 轮）。非阻塞留观：`_edit` 的 TextEditingController 未 dispose；Hero「本月已记（示例数据）」实为全部记录求和，文案与口径二选一修正在 G2 后续卡消化亦可。

模拟器冒烟: 未做——main 无新合入（仍@91b24be=快照 last_smoke_commit），SB-004 未过审不合入；返工 PASS 后监工走查含 D3 三秒流补证。
