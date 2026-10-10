# REVIEW — 2026-10-10 SB-004 三秒记一笔（第 2 轮 · 卡 SB-004）

结论: PASS

检查项:
- [x] 本轮改动仅 2 文件：`1bf8f73`（home_page.dart 187 行 / widget_test.dart 100 行），`f265c1a` 为审读请求 chore；未 push、无 remote、工作树干净、commit 带 [SB-004]
- [x] 问题1 关闭：旧「Counter increments smoke test」已删除，重写为两条主屏真实测试（空态冒烟 + 编辑→改类目→保存落库，合成数据+内存库）；监工独立跑 `flutter test` = **+27 All tests passed**（第 1 轮实测 +25 -1，缺口已消除）
- [x] 问题2 关闭：`_edit` 对话框包 `StatefulBuilder`，`onSelected` 走 `setDialogState` 即时高亮；widget 测试断言点选后 `ChoiceChip.selected==true` 且保存后落库类目为新值；另落实留观项：note controller `try/finally dispose`
- [x] 独立复核绿：`flutter analyze` No issues；`check-repo-hygiene.sh` OK；lib/ 与 test/ 零真实账目数据（测试为合成 fixture：1234 分/午餐）
- [x] 偏差声明 T1/T2 认可：内存库 close 挂起、unmount 后 drift 零时长 Timer 均属测试环境细节，原理已记 widget_test 文件头注释，生产开/关库路径不变，不阻塞
- [x] 留观项裁决：`sqlcipher_flutter_libs ^0.7.0+eol` —— 接受现状（纯原生二进制 wrapper，ADR-001 已记录选型与否决项）；G4 与 Keychain/Keystore 迁移一并评估替代方案，保留在监工 watch_items，不属本卡问题
- [x] devKey 仍为编译期密钥：与 ADR 承诺（G4 前迁移）一致，观察项不变

问题列表: 无（第 1 轮两项均已关闭；本卡第 2 轮 PASS，R4 打回计数不增）

下一步: 监工按 R5 自动合入 main（squash→`7b99ed4`，feat 分支已删）。开发侧可接 SB-005。里程碑口径不变：G2（SB-006 收尾）按 2–3 周估算，周报计划每周一发。

模拟器冒烟: PASS（2026-10-10 13:44，main@7b99ed4 debug APK）
- 证据：runway_api36（Android 36/arm64）冷启动 boot_completed≈25s；`adb install -r` Success；`am start -n com.zangou.runway.runway/.MainActivity` → logcat `Displayed … +7s993ms`；30s 后进程存活 pid=2406；`FATAL EXCEPTION` 计数 0；验收后模拟器已关闭（pkill 生效）
