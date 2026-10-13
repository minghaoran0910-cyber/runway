# REVIEW_REQUEST — SB-027 导航与字体急救（S1返工后第2轮提审）

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-027-nav-font-rescue`（未 merge、未推送，无 remote 操作，合规）
任务卡：`docs/tasks/SB-027.md`（状态：在飞；REVIEW 21:3x 第1轮 REQUEST_CHANGES，本轮 S1 返工）
基座：`main@0b5b141` 起步（feat 含 89948a4 三 tab+钳制+类目字号、14626cc ①b①c+golden、cc8d032 驱动 v2+三页实拍、本轮 5cf8596 golden/sb005 重生）
S0 守卫说明：S1 返工轮（REVIEW 21:3x REQUEST_CHANGES 第1次，R4 计数 1/2，本轮为第2轮；再被打回即按 LOOP S1.1 写 WAITING_HUMAN）；S0.3 无 _LOCK（本轮创建退场即删）；S0.4 返工改动仅 golden/sb005 两 png；S0.5 本轮新写待审；S0.6 无 WAITING_HUMAN。

返工清单（REVIEW 21:3x 两问题逐条闭环）：
1. 🔴阻塞已修：类目页自身 golden 随①①b①c 像素变更再生——`cd app && flutter test --update-goldens test/golden_category_test.dart` 实测 All tests passed（SB-005 对比度闸门 3/3），产物 golden/sb005/category_dark.png（217715→212482B）、category_light.png（313235→308749B）；目视确认：弹性占比句已降标题档+渐变卡小字白系可读+“其他占比”无示例字样；随后全量 `flutter test` 实测 **417/417 All tests passed**（前轮 415/417 红已转绿）。上轮提审单“golden 类目页更新为正常字号——达标”不实致歉：上轮只再生了 sb019 role golden，本轮补齐 sb005。
2. 🟡措辞已改：上轮“无 remote”改为“未推送”——仓库存在 origin（origin/main=0b5b141，12:3x 外部推送已登记在册）；SB-027 工作确未推送（`git status` 无 ahead/behind 待监工复验），不构成违规。

三页实拍（沿 21:2x，代码本轮零改，复验未变）：
- app/build/live_shots/sb027-home.png（798215B，md5 b99cf64a87e762d31b927898804eadf9）= 攒够首页 + 首页 tab 高亮 + 记一笔 FAB
- app/build/live_shots/sb027-cat.png（602320B，md5 279b5cb578ce2e8fe2c2383a264f3d5c）= 类目管理页 + 账本 tab 高亮 + FAB；①①b①c 三修实拍可读
- app/build/live_shots/sb027-me.png（607922B，md5 bcc0797023f3cbfb419d968f8eedcc2d）= 目标阶梯页 + 我的 tab 高亮 + 定目标 FAB（外层记一笔隐藏）
- 三图 md5 互不相同本轮复验一致（md5 实测）；落仓库内 gitignore 目录，未碰 /tmp。

验收对照（卡 SB-027 三项）：
1. 模拟器实拍三页截图——达标（上条三图，md5 互异，tab↔页面映射 21:3x 已销案：账本=类目管理/我的=目标阶梯系有意，与卡面“现有页面全挂进去”一致）。
2. golden 类目页更新为正常字号；textScaler 回归测试绿；四闸门全绿——本轮达标。golden/sb005 再生说明见返工①；text_scaler_test 绿；`tool/ci.sh` ALL GREEN（format 101 文件 0 改动/analyze No issues/smoke 1/1/macos+apk 双构建成功）+全量 417/417 回显（ci 内 smoke 仅跑 smoke_test，不单独构成全绿证据，全量回显本单已附）；`tool/check-repo-hygiene.sh` OK。
3. 每 tab 可达性手测清单——达标（沿 21:2x：root_shell_test 程序化覆盖首页默认达+账本点达类目管理+我的点达目标阶梯+回首页恢复，全绿；切页与用户点按同 onDestinationSelected→setState 路径，点按由 tester.tap 覆盖）。

测试：`flutter test` 全量 417/417 绿；`dart format` 0 改动；`flutter analyze` No issues；root_shell/text_scaler/golden_role 相关测试全绿；ci.sh ALL GREEN；hygiene OK。

偏差声明（如实申报）：
① 实拍驱动 app/live_shots.dart（158 行）仍在 feat 分支，提审前不删除——合入轮再删，不随 main 落库（21:3x 偏差① p=0.45 灰区待浩然拍板 22:2x 三连裁①=合入前删，已对齐）。
② 首页 hero“（示例数据）”仍在——①c 修的是类目页卡内“其他占比”示例字样（已去），首页水印口径归 SB-028，未扩 scope。

文件约束：本轮改动 golden/sb005 ×2（基线图不计入 ≤10，DEV_WORKFLOW §2 计数豁免）；业务代码本轮 0 改；累计业务 8 文件≤10（main/category/goal/home/root_shell/live_shots/root_shell_test/text_scaler_test）；单文件≤400 行（live_shots 158/category 336/root_shell 73 实测）；无 pubspec；未推送；真实账目 0；禁词零新增；_LOCK 本轮退场即删。

状态：待审查（2026-10-13 22:45 builder S1 返工提审·SB-027 第2轮；feat 分支未合入；合入轮：main 落 app 代码，请按 21:3x 票口径 squash 前 `git rm app/live_shots.dart`+v3 一条龙安卓冒烟+真 git mv done/ 归档+REVIEW.md 双侧并档以 main 版为准覆盖）
