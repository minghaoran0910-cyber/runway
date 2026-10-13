# REVIEW_REQUEST — SB-030 目标时间线+周报折线（第2轮返工提审·应答 01:2x RC）

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-030-timeline-trend`（未 merge、未推送，无 remote 操作，合规）
任务卡：`docs/tasks/SB-030.md`（状态：在飞；R4=SB-030 第1轮RC，本轮第2轮未达 WAITING_HUMAN 线）
基座：`main@4ebf224` 起步（本轮返工 commit 一笔 2 文件，见文件约束）
S0 守卫说明：S1 返工轮（REVIEW 01:2x 结论 REQUEST_CHANGES 第1轮，S2 不触发；SB-012 真人闸门在飞/SB-021 挂起 v0.2 与本卡无关）；S0.3 _LOCK 本轮创建退场即删；S0.4 工作树本轮改动外干净；S0.5 REVIEW 01:3x 巡检段后无新审查；S0.6 无显式 WAITING_HUMAN 标记行。

返工清单（01:2x 问题列表逐条）：
1. 🔴 P1 trend_line.dart shouldRepaint 长度代理判等致折线冻结——已修：`old.values.length != values.length` → `!listEquals(old.values, values)`（+`package:flutter/foundation.dart` import，一行修，生产码零裸值，line 比对保留）。
2. (m) 达成态双 ✓ 冗余——未动，留后续打磨卡。
3. (m) 达成态无像素证据——未动，留后续打磨卡。
4. (m) 编辑/删除图标行左置——未动，留后续打磨卡。

测试：全量 439/439 绿（基线 438+本轮 1）；`dart format` 0 改动；`flutter analyze` No issues；新增「SB-030 折线同长度新数据触发重绘」widget 测试（同长异值 pump 两次断言 shouldRepaint=true，同值重泵断言 false，直覆 P1 回归）；`tool/ci.sh` ALL GREEN（format/analyze/test/macos+apk 双构建）+hygiene OK。

偏差声明：偏差①（N 周口径）②（折线=支出非省出）沿 01:2x 决策 p=0.80/0.77 按判受，本轮未动；偏差④实拍缺=01:2x 监工 A 口径已补拍，本轮纯逻辑修无新视觉变更不需重拍；偏差⑤沿 00:4x 挂浩然。

文件约束：业务 1 改+测试 1 改=2≤10；单文件≤400 行；无 pubspec；无 tokens；无 schema 迁移；未推送；真实账目 0；禁词零新增；_LOCK 本轮退场即删。

状态：待审查（2026-10-14 01:4x builder S1 第2轮提审·SB-030；feat 分支未合入）
