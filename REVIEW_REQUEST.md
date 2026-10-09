# REVIEW_REQUEST — SB-003 设计token落地（请求审计）

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-003-tokens`（未merge、未push、无remote，合规）
任务卡：`docs/tasks/SB-003.md`

变更内容（8文件，≤10）：
- `app/lib/ui/theme/tokens.dart`（新建，169行）：§2 Tokens Light/Dark双份+字号/间距/圆角/阴影/Hero/对比度计算
- `app/lib/ui/theme/motion_spec.dart`（新建，55行）：§6 六类动效统一封装
- `app/lib/ui/theme/app_theme.dart`（新建，124行）：ThemeData light+dark装配+ground/hero decoration
- `app/lib/main.dart`（改动，68行）：挂接AppTheme.light/dark，零裸hex
- `app/test/tokens_test.dart`（新建，151行）：命名值断言+对比度代码内计算+MotionSpec区间
- `app/test/golden_tokens_test.dart`（新建，128行）：色板+字例示意卡Light/Dark
- `golden/sb003/tokens_light.png` + `tokens_dark.png`（基线，`--update-goldens`生成，可复现）

验收对照（卡§验收标准）：
1. tokens.dart覆盖§2表格全部命名与值（Light+Dark）逐字一致 —— ✓（12组/侧已断言；gold-hi Light文档记"—"，复用gold并注释，见偏差D1）
2. motion_spec.dart统一封装§6六类（时长/曲线常量），UI零裸时长/曲线 —— ✓（6类+全局默认全常量化）
3. app_theme.dart装配ThemeData（light+dark），main.dart挂接；tokens/theme外零裸hex —— ✓（`grep Color(0x app/lib`除ui/theme外零命中）
4. 单测：token数量命名齐全；关键对比度代码内计算达标 —— ✓（9项全绿：Light小字≥4.5实测ink11.04/次要4.83/strong5.75/danger4.91；大字accent3.71/gold3.02≥3.0；Dark全≥5.3）
5. Golden：色板+字例示意卡Light/Dark各一入库`golden/sb003/`，可复现 —— ✓（生成后不加`--update-goldens`重跑2/2通过）
6. `bash tool/ci.sh`四闸门全绿+`bash tool/check-repo-hygiene.sh` OK —— ✓（format 0 changed / analyze No issues / smoke通过 / build双产出macOS+APK；hygiene OK）

偏差声明（2处，请裁决）：
- D1：gold-hi Light文档记"—"（无独立值），实现复用gold（0xFFC08A3E）并注释说明，未编造新值。建议接受。
- D2：`demos/tokens.css`缺失（demos/仅.gitkeep），以DESIGN_SYSTEM §2表格为真相源逐字映射；CI脚本仍只跑smoke（未改CI禁区），全量测试（tokens+golden）手动跑绿。建议接受。

请审计后结论写`REVIEW.md`（PASS或REQUEST_CHANGES，带轮次编号）。
