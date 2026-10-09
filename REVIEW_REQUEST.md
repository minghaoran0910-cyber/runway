# REVIEW_REQUEST — loop bootstrap（LOOP.md 落地，请求合入）

仓库：`/Users/dada561/Documents/runway`，分支：`chore/loop-bootstrap`（未 merge，未 push，无 remote，合规）
任务卡：无（流程类变更，分支名偏差说明见下）

变更内容：
1. `LOOP.md`（新建）：headless 唤醒状态机，S0 六守卫（分支==main / 锁 / 树干净 / 审查无堆积 / 无 WAITING_HUMAN）→ S1 返工一轮 → S2 新卡一单 → idle 退出；铁律：不 merge 不碰 remote，一轮一事。
2. `SUPERVISOR.md`：追加"附录 LOOP 时代协作"（合入舞步 / WAITING_HUMAN 处理 / cron 文本归属 / 首轮顺序）。只加附录，未改既有条款。
3. `progress.md / task_plan.md`：SB-001 归档 + loop 说明（随行更新）。

偏差声明（1 处，请裁决）：
- P1：分支名用了 `chore/` 前缀，GIT_WORKFLOW 白名单只有 feat/fix/hotfix/release。理由：无任务卡的流程变更，用 feat 会污染"一卡一支"审计口径。建议接受（或你指定命名，我以后照办）。

请按附录合入舞步处理：squash → checkout main → 删分支，然后发 SB-002 到 `docs/tasks/`。结论写 `REVIEW.md`。
