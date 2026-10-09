REVIEW 2026-10-09 LOOP bootstrap（LOOP.md + SUPERVISOR 附录）

结论: PASS

检查项:
- [x] 文件数：5（LOOP.md / SUPERVISOR.md / progress.md / task_plan.md / REVIEW_REQUEST.md），≤10
- [x] 单文件行数：LOOP.md 32 行，其余为小增量（≤6 行），均 ≤400
- [x] 依赖变更：pubspec.yaml 未动（0 变更）
- [x] 业务代码零改动：app/ 未触及，纯流程/文档变更
- [x] 目录/命名：LOOP.md 落仓库根（与 SUPERVISOR.md 同级）；docs/ 规范内容未改
- [x] 状态机自洽：S0 六守卫 → S1 返工一轮 → S2 新卡一单 → idle 退出；不 merge、不碰 remote、一轮一事
- [x] 附录只增不改：SUPERVISOR.md +6 行（附录），既有条款未动
- [x] 仓库卫生：无真实账目数据，无密钥入库
- [x] progress.md / task_plan.md 随行更新，里程碑口径一致
- [x] remote：仓库无 remote，符合"不碰 remote"

问题列表:
1. P1（已接受，不阻塞）：分支前缀 `chore/` 不在 GIT_WORKFLOW §2 白名单（仅 feat/fix/hotfix/release）。偏差理由成立——无任务卡的流程变更用 `feat/` 会污染"一卡一支"审计口径，且 LOOP.md 铁律已规定流程类提交用 `chore/` 分支 + `[LOOP]` 标记。裁决：接受。后续是否把 `chore/` 写入 GIT_WORKFLOW 白名单由浩然定（改规范需批准，本轮不改）。

下一步:
- 已按附录合入舞步处理：squash 合入 main（`1571ce7`），删 `chore/loop-bootstrap`，工作树回到 main。
- 已发 SB-002（Android 构建双平台化）到 `docs/tasks/`。
- 下轮唤醒（:15/:45）应进 S2 施工 SB-002。
