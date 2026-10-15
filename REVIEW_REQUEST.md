# REVIEW_REQUEST — SB-038 首页大扫除（裁A 返工·监工手动接管·第3轮提审）

- **卡**：docs/tasks/SB-038.md ｜ **分支**：feat/SB-038-home-cleanup@1714787（业务体单提交；未 merge/未 push，main/origin 零触碰）
- **执行身份**：监工手动接管返工（交接预案①：builder 10:45/11:15 两拍撞双墙未接单）。wake 88a8e128 维持 disabled，builder 拍次零消耗，无并发冲突。

## 裁A 四项逐条交付

- ① **修导航断线**：断因实测=ListView 懒构建下，搬家区四卡把 goalToWeekly/goalCount/goalTimeline 推出构建窗（Found 0 widgets=真断线，非接线断裂）。修复=搬家块（每日收口/大额冷静/月度小实验/预算观察）整体移至目标时间线之后；**时间线以上区域与 main 净差异=0**（单变量重排：git diff main 仅 +4 imports + 搬家块落尾）。
- ② **10 项断线测试按新布局更新**：SB-016/017/018 三「首页集成」案改 pump GoalPage 并更名「我的页集成（SB-038搬家后）」（scrollUntilVisible 保留）；三 DAO 案定性=前置案失败级联污染（隔离复跑全绿实证），零改动随前置修复自然转绿；SB-030/SB-014 随①布局恢复零改动转绿。
- ③ **golden 重生成**：golden/sb007/goal_* 6 帧 + golden/sb012/budget_home_* 2 帧（--update-goldens 后复跑全绿；目检=首屏顺序同 main、搬家区落位时间线下、零溢出乱码）。
- ④ **三页实拍**（模拟器 runway_api36·分支 debug APK·am start 后 PID 存活·FATAL=0）：
  - /Users/dada561/Documents/runway-shots/2026-10-15-manual38/01_home.png —— 首页：环形图+「今天攒出」常驻行在位+四区已不出现（硬约束实证）
  - 同目录 02_goal_top.png —— 目标页首屏：余粮区+「看本周周报」入口首屏可见（断线修复实证）
  - 同目录 04_goal_zones.png —— 目标页下滑：冷静/月度小实验（8 chips）/预算观察全挂载（只搬家不删除实证）
  - 同目录 05_weekly.png —— 周报页：经入口 1 跳到达（≤2 跳契约实证）

## 质量证据

- **全量套件 realexit=0**：+460 All tests passed（基线 10 失败→0；基线复现 /tmp/sb038_baseline_test.log，返工后 /tmp/sb038_full2.log，均 `>file; echo $?` 真实退出码口径）。
- **闸门**：dart format --set-exit-if-changed=0 ｜ flutter analyze --fatal-infos --fatal-warnings=0 ｜ tool/check-repo-hygiene.sh=OK。
- **文件数**：业务 1（goal_page.dart）+测试 3=4 ≤10 ✓（金样 8 帧另册，沿 041 口径）。
- **硬约束**：首页「今天攒出」常驻行保留（47a9626 资产零改动，实拍 01 为证）；口径零改；禁区零触碰；真实账目零接触（设备 pm clear 空态）。

## R4 申报

本单为第 3 轮审查（历史 RC×2：17:3x 缺实拍／02:3x 全量十失败）。本轮=裁A 授权返工，非自然 RC+1；已知悉 12:3x 票约束「若本轮再审仍 RC 则即刻停手呈 WAITING_HUMAN 不再放第三轮」。

## 队列现状

done/=34；038 过审后链序 039→040→041 rebase 逐个合入+每合一卡翻冒烟锚点（现锚点 8830d1c）；SB-042 已归档（03:5x）；wake 冻结+A/B/C+worktree×5/vC 清理仍待浩然。
