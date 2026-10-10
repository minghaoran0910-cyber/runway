# REVIEW_REQUEST — SB-013 applicationId 归一（com.zangou.runway）

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-013-appid`（未 merge、未 push、无 remote，合规）
任务卡：`docs/tasks/SB-013.md`（包名拼重归一，浩然 2026-10-10 批准，建议先于 G5 冻结执行）
基座：`main@3cc285b`（SB-011 结案+G4 达成后；本分支系 03:47 wake 预建空分支，tip 与 main 同，零冲突）

改动清单（业务 6 文件 ≤10，手写单文件最大 112 行 ≤400）：
- `app/android/app/build.gradle.kts`：`namespace` + `applicationId` → `com.zangou.runway`
- `app/android/app/src/main/kotlin/com/zangou/runway/runway/*.kt` → `.../com/zangou/runway/*.kt`（git mv 目录上移）：`MainActivity.kt`（package 声明 + `ACTION_PENDING` 广播串 → `com.zangou.runway.PENDING_PUSH`）、`PendingListenerService.kt`（package 声明）
- `app/ios/Runner.xcodeproj/project.pbxproj`：6 处 `com.zangou.runway.runway` → `com.zangou.runway`（主 3 + RunnerTests 3 同步为 `com.zangou.runway.RunnerTests`）
- `app/macos/Runner/Configs/AppInfo.xcconfig`：主包 `PRODUCT_BUNDLE_IDENTIFIER` → `com.zangou.runway`（卡点名 iOS，macOS 同样拼重按同口径一并归一）
- `app/macos/Runner.xcodeproj/project.pbxproj`：3 处 RunnerTests 同步归一
- `golden/sb013/launch_new_pkg.png`：新包启动实拍（验收证据，非测试基线，不计文件数）

验收对照（SB-013 卡 §验收 1~4）：
1. Android `applicationId` 与 `namespace` 均为 `com.zangou.runway`（gradle 实读）；iOS bundle id `com.zangou.runway`（pbxproj 3 主配置实读）；macOS 主包同步 `com.zangou.runway`。
2. `flutter build apk --debug` 成功；`aapt dump badging` 回显 `package: name='com.zangou.runway' versionCode='1' versionName='1.0.0'` + `launchable-activity: name='com.zangou.runway.MainActivity'`。
3. 模拟器 runway_api36（本轮 builder 实测）：新包 `adb install -r` Success；`am start -n com.zangou.runway/.MainActivity` → 35s 后 pidof=2577 存活、`topResumedActivity=com.zangou.runway/.MainActivity`、logcat FATAL=0；截图 `golden/sb013/launch_new_pkg.png`。**同机覆盖升级结论**：旧包 `com.zangou.runway.runway` 与新包视为不同应用并存（pm list 双包在位、codePath 各异），无直升路径；v0.1 未发布零真实用户，升级路径=卸旧装新，无数据迁移义务。
4. `tool/ci.sh` ALL GREEN（format 0 改动/analyze No issues/smoke 绿/macos+apk 双构建成功）；`tool/check-repo-hygiene.sh` OK；全量 `flutter test` 178/178 绿（与 SB-011 结案数持平，既有 golden 零漂移）；`dart format` 0 改动。

文件约束：业务 6 文件 ≤10；无 pubspec 变更；无 remote；测试全合成 fixtures，真实账目=0；探针仅仓内 `_inbox/emulator_sb013.log` 且已删，未碰 `/tmp`。

偏差声明：
- `CHANGELOG.md` 本仓从未建立（历卡未建），本卡未新建以免 scope creep；待 SB-012（G5 冻结卡验收含 CHANGELOG 补全）统一补。
- macOS 主包+三端 RunnerTests 同步归一系卡文「同样拼重一并归一」口径的自然延伸，非新增工作面。
- 本轮模拟器冒烟由 builder 执行（监工真机走查可在审查轮复验）；`ACTION_PENDING` 广播串新旧不互通，预发布阶段无影响。

请审计后结论写 `REVIEW.md`（PASS 或 REQUEST_CHANGES）。
