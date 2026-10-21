# REVIEW_REQUEST — SB-048 设目标表单控件修复（重提审·票262 打回后二审）

**卡**：docs/tasks/SB-048.md ｜ **分支**：feat/SB-048-goal-editor@b7dcfd2（基于打回点 2d920bc 的修复提交）｜ **性质**：票262 REQUEST_CHANGES 双 P1 修复重提审（报修卡·浩然同批反馈②）。
- **执行体说明**：builder 打回后 16h 盘上零产出（2d920bc 后无新提交、无新 REQ），浩然催办，监工悬钟（今晚 19:5x）前由代偿执行体接管修复+重提审。接管前 _LOCK find=0、porcelain=0、零并发实证。

## 票262 P1 → 修复对照

- **① showDatePicker 全英文（P1）**：根因按票面=main.dart MaterialApp 无 localizationsDelegates/supportedLocales、pubspec 未引 flutter_localizations。修复=pubspec 增 `flutter_localizations: {sdk: flutter}`；main.dart 具名导出 `runwayLocalizationsDelegates`（Global Material/Widgets/Cupertino 三 delegate）+ `runwaySupportedLocales: [zh_CN]` 挂入 MyApp，并供测试复用同一组。回归=新用例「SB-048 日历弹层中文」：点 `goalDeadlinePick` 开弹层，断言「选择日期/确定/取消」各恰一命中、「OK/Cancel/Select date」零命中，点确定后期限字段回填 `^\d{4}-\d{2}-\d{2}$`——「零数字键入+人话」验收口径进测试固化。
- **② golden_price_test 全量红（P1）**：实测红项非 light/dark 像素不符，而是交互用例「SB-020 目标单价跟随常买中位数（手改优先）」Bad state: No element——2d920bc 把 `goalFollowKey` 移进默认折叠「进阶」ExpansionTile，旧测试未展开即 enterText（栈顶 WidgetController.state→enterText≈155 行）。最小修复=进 sheet 后先 `scrollUntilVisible`+tap `goalAdvanced` 展开再操作（沿册 sb048 用例同法），不碰 lib 业务码；golden light/dark 经 `--update-goldens` 重渲染与盘上基线字节一致（git status golden/=0 变更），基线两图已肉眼复核中文文案无截断无破损。
- **③ initialDate 越界（P2 建议随修）**：`_pickDeadline` 的 initial 改 clamp 进 [firstDate,lastDate]（替代仅挡 DateTime(2000) 的旧防护），手输越界日期不再触发 debug assert。
- **④ P3 登记项不动**：goalTargetPresets 派生自 defaultLadder+chipGap token 曾实现，按最小改动原则回退，仍留票面登记待后续。

## 自检三件套 + 全量 + ci.sh 记录

- dart format --set-exit-if-changed . = 0 changed ｜ flutter analyze --fatal-infos --fatal-warnings app = No issues ｜ tool/check-repo-hygiene.sh = OK
- 目标测试 sb048_goal_editor_test + golden_price_test = 13/13 绿（含新增中文弹层回归）
- 全量 flutter test = **493/493 全绿**
- tool/ci.sh 四闸 = **EXIT=0 ALL GREEN**（format/analyze/smoke test/macos debug+apk debug 双 build ✓）

## 实拍附页

runway-shots/2026-10-21-sb048-fix/（runway_api36 无头模拟器实测）：01_home 首页 / 02_editor 定一个目标 sheet（核心三项常显+预设 chips+期限日历钮+进阶折叠，全中文）/ 05_picker_try3 表单稳态。
**偏差如实申报**：中文日期弹层开屏实拍未竟——模拟器连发两轮 ANR 对话框（runway/System UI isn't responding，swiftshader 负载）处置后恢复，第三轮点按后 emulator 进程被 SIGKILL，未再重启（避免继续烧悬钟前时间窗）；弹层中文效果以新回归用例断言（选择日期/确定/取消+英文零命中）为证，请监工下拍补拍复核。

## 声明

不 merge、不动 main、不 push origin；docs/tasks/SB-048.md 未动（沿 5093505 先例=提审不动卡）。改单曾称「picker 中文化已在 2d920bc」——与盘上事实不符（2d920bc 的 main.dart 无 delegates、pubspec 无 flutter_localizations，票262 P1① 判的正是它，监工票263~269 七轮均记「修复在途未重提审」），本单以票面为准完成修复。

**R 申报**：SB-048 重提审（二审），请求按票262 检查项复审。
