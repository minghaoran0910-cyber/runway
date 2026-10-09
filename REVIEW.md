# REVIEW — 2026-10-09 SB-003 设计token落地（第 1 轮 · 卡 SB-003）

结论: PASS

检查项:
- [x] 分支/提交合规：`feat/SB-003-tokens`@1b15166，未 merge 未 push 无 remote，工作树干净，commit message 含卡号
- [x] tokens.dart 与 DESIGN_SYSTEM §2 逐字比对一致：Light/Dark 各 12 组命名与值全对；hairline rgba→ARGB 换算正确（.08→0x14、.09→0x17）；阴影/光晕/内高光 alpha 换算正确
- [x] 字号阶梯 9.5–34、字重 400–800、间距 4/8 网格、圆角三档+胶囊、负字距 -0.5（区间中值）均落 §2.2
- [x] Hero 主卡（§3）：142° 三段 stop0/stop1@58%/stop2、r22、四层文字 alpha（74%/100%/62%/暖金 EAD9B4）全对
- [x] motion_spec.dart（§6）六类全覆盖：按压 140ms/.96、状态 260ms+cubic(.2,0,.1,1)、转场 360ms、Sheet 280/220+damping.8/response.3、stagger 80ms/14–16px、FAB easeOutBack c1=1.70158+成就 900–1200ms/粒子≤12；全局临界阻尼 1.0、reduce-motion 80ms、shimmer≤300ms 均在
- [x] app_theme.dart 装配 ThemeData light+dark，main.dart 挂接 `AppTheme.light()/dark()`，tokens/theme 外零裸 hex（监工 grep 复核：`Color(0x` 除 ui/theme 外零命中）；UI 零裸时长/曲线
- [x] 监工独立跑绿：`flutter analyze` No issues / `dart format` 0 changed / `flutter test` 13 项全绿（含 golden 不带 --update-goldens 重跑 2/2 通过=可复现）/ `check-repo-hygiene.sh` OK
- [x] 对比度闸门代码内计算达标（Light 小字≥4.5 四组合、大字≥3.0 两组合、Dark 四组合，实测通过）
- [x] golden/sb003/tokens_light.png + tokens_dark.png 已入库
- [x] 红线合规：纯主题代码，无任何真实账目数据
- [x] 偏差裁决 D1：gold-hi Light 文档记"—"，实现复用 gold(0xFFC08A3E)+注释，未编造新值 → 接受
- [x] 偏差裁决 D2：demos/tokens.css 缺失，以 §2 表格为真相源逐字映射；CI 禁区未动 → 接受

问题列表:
（无阻塞问题；两条非阻塞观察，留 G2 页面实现时消化）
1. main.dart 仍为脚手架计数器 demo，AppBar 用 colorScheme.inversePrimary（非 token 名）——占位页可容忍，G2 换真实页面时应清除
2. AppTheme.ground() helper 已提供但 scaffold 背景暂用 surface1 纯色（非纯白，合规）；ground 渐变应在 G2 首页真正用起来

下一步: 已按附录第 5 条自动合入（squash → main@7d894ee，feat 分支已删）。G1 达成，环转 SB-004（G2 第一批已下发，无需监工补排）。

模拟器冒烟: PASS — main@7d894ee（SB-003 合入后）：`flutter build apk --debug` ✓（Gradle 6.9s，APK 160MB）→ runway_api36 headless boot（sys.boot_completed=1）→ `adb install -r` Success → `am start -n com.zangou.runway.runway/.MainActivity` 启动 → 32s 后 pid=3494 存活 → logcat FATAL EXCEPTION=0 → screencap 53KB 截图复核：AppBar「Runway」/计数器文案/数字 0/FAB 均正常渲染（主题挂接生效）。模拟器已 pkill 关闭。
