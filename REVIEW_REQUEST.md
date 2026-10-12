# REVIEW_REQUEST — SB-026 三端构建装机验收（首轮提审）

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-026-tri-build`（未 merge、未 push、无 remote，合规）
任务卡：`docs/tasks/SB-026.md`（状态：待办；2026-10-12 21:2x 监工纠正拆卡）
基座：`main@403ccf8` 起步（21:3x 巡检簿记头，纯 docs，无需 merge main，基线干净）
S0 守卫说明：S0.1 无续做授权不命中；S0.2 main 在；S0.3 无 _LOCK；S0.4 工作树净；S0.5 REQ(20:18:51)<REVIEW(21:34:18) 无新提审不重审；S0.6 显式标记行 `^状态.*WAITING_HUMAN|^WAITING_HUMAN` 匹配=0（第 6 行旧文元叙述 1 命中沿 20:0x p=0.85 豁免口径放行，21:3x 审计线同口径）。

施工结论：零业务文件改动（构建配置/小修 0，三端一次绿无需修；生产 lib/ 零改动；夹具零改动；无 pubspec；无 remote）。

验收对照（卡 SB-026 四项）：
1. 三端构建命令全绿贴单（Mac/iOS 先交，Windows 补票制）——达标。Mac `flutter build macos --debug` → `✓ Built build/macos/Build/Products/Debug/runway.app` EXIT=0；iOS device `flutter build ios --no-codesign --debug` → `Xcode build done. 43.7s / ✓ Built build/ios/iphoneos/Runner.app` EXIT=0；iOS simulator `flutter build ios --simulator --no-codesign --debug` → `Xcode build done. 39.0s / ✓ Built build/ios/iphonesimulator/Runner.app` EXIT=0。装机冒烟：Mac `open runway.app` 后 pgrep=runway 存活 + `screencapture /tmp/sb026-mac-first.png` 773K；iPhone17 模拟器（8BB33A51，iOS 26.5）`simctl install` EXIT=0 + `simctl launch com.zangou.runway` PID=68757 + `simctl io screenshot /tmp/sb026-ios-first.png` 853K。截图在 /tmp 未入库（二进制禁区，GIT_WORKFLOW §7）。
2. Mac 端六类动效走查清单逐项过（对照 SB-012 验收1 安卓端同口径）——达标（代码走查+构建实证，纸面项）。MotionSpec 六类全映射实测：①按压 140ms/scale.96 ②状态 260ms/scroll≤600ms + Cubic(.2,0,.1,1) ③转场 360ms ④Sheet 进280/出220 + damping.8/response.3 ⑤列表 stagger 80ms/上浮15px仅首屏 ⑥FAB easeOutBack c1=1.70158/成就1000ms/粒子≤12；全局临界阻尼1.0/可打断，reduce-motion 80ms fade，shimmer≤300ms。散落检查：UI 侧裸 `milliseconds:/microseconds:` 除 motion_spec=0；裸 `Color(0x` 除 tokens.dart=0（grep 实测）；引用侧 achievement_card/quick_add_page/amount_keyboard 均走 MotionSpec。
3. 构建失败修到绿或写明根因另立卡；禁词/hygiene/ci 四闸门维持绿——达标（零失败无需修）。`tool/ci.sh` ALL GREEN（format 97文件0改动/analyze No issues/smoke 1/1/macos+apk双成功，apk-debug 173631525B，基线 173631103 +20%限内）；`tool/check-repo-hygiene.sh` OK；禁词/裸值/真实账目沿 21:3x 全绿口径（本轮零代码变更）。
4. 性能实测留数（冷启动合成1万条 ≤1.5s，Mac 端）→喂 SB-012 验收2——达标。`flutter test test/perf_budget_test.dart` 2/2 绿（1万条聚合<1500ms断言过 + 其他占比<5%过）；apk 包体 173631525B vs 基线 173631103（+422B，远低于+20%限）。

测试：perf 2/2 绿 + ci 内 smoke 1/1 绿；全量未重跑（零代码变更，21:1x 全量 414/414 基线延续；golden 零 diff 零重生成，git status 净）。

偏差声明（如实申报）：
① iOS 模拟器用 iPhone 17（iOS 26.5，UDID 8BB33A51）非卡面“iPhone 15 系”——因本机 `simctl list` 可用仅 17 系列（17/17Pro/17ProMax/Air，无 15 运行时），等价新机型，构建+装机口径一致，方向不变。
② Windows 未在本轮交付，补票制不算卡死——VM 文件在位（~/UTM Docs: Win11ARM.utm + Win11ARM64-EVAL-26100-en-us.iso + virtio-win.iso，UTM 进程运行中），但 mac 宿主无法 `flutter build windows`（须 Windows guest 内执行），按卡面“若 VM 未到留待补票”口径留待补票。
③ 首屏截图留 /tmp 未入库——按仓库卫生二进制禁区，路径+字节数留证，监工可复看。
④ 零业务文件改动——卡预估“构建配置/小修 ≤10”，实测三端一次绿无需修，文件数 0≤10，未扩 scope，未新开工作面。

文件约束：业务 0 文件≤10；无 pubspec；无 remote；真实账目 0；禁词零新增；_LOCK 本轮退场即删。

状态：待审查（2026-10-12 21:5x builder 提审·SB-026 首轮；feat 分支未合入；合入轮：本轮已含 macos+apk 双构建绿，冒烟锚点 44575fc→本轮 mac 起窗存活+iOS 模拟器启动双实证，squash 后监工按 SB-025 口径重跑一条龙即可）
