# LOOP.md — runway 自动施工循环（headless 唤醒入口）

> 本文件是 `opencode run` 每次被唤醒后的唯一指令来源。不依赖上轮记忆，一切以文件为准。
> 期望的唤醒语（openclaw 侧 cron 拥有，备查）：`读 LOOP.md，按状态机只做一件事，做完就退出；_LOCK 存在则直接退出`，工作目录 `/Users/dada561/Documents/runway`。

## S0 守卫（任一命中 → 直接退出，exit 0，不动任何文件）
1. `LOOP.md` 不在工作树 → 退出（环未就绪）。
2. 当前分支不是 `main` → 退出（等监工合入，见 SUPERVISOR.md 附录合入舞步）。
3. `/tmp/runway-loop.lock` 存在且 PID 存活 → 退出（另一轮在跑）；PID 已死 → 删锁继续。
4. 工作树脏（`git status --short` 非空）→ 退出（有人在干活，不抢）。
5. `REVIEW_REQUEST.md` 的 mtime 新于 `REVIEW.md` → 退出（等监工审查）。
6. `REVIEW_REQUEST.md` 含 `WAITING_HUMAN` → 退出（等人工裁决，唤醒任务应已被监工暂停）。

通过守卫后：创建 `/tmp/runway-loop.lock`（写 PID+时间），全程 `trap` 保证退场删锁。

## S1 返工（REVIEW 结论为 REQUEST_CHANGES → 修一轮）
1. 按 REVIEW.md 问题列表逐条改（DEV/GIT 规范全遵守：`feat/SB-nnn-slug` 分支、文件数 ≤10、单文件 ≤400 行、不碰禁区）。
2. 跑 `tool/ci.sh` 全绿 + `tool/check-repo-hygiene.sh`。
3. commit（格式 `type(scope): 描述 [SB-nnn]` + trailer `Agent: opencode`），更新 REVIEW_REQUEST.md，留在 feat 分支，解锁退出。
4. 同一 SB 卡累计返工到第 3 轮仍未过 → 不再硬磨：REVIEW_REQUEST 写 `WAITING_HUMAN`（说明卡或规范可能有问题），解锁退出。

## S2 新卡（有任务卡且 REVIEW_REQUEST 未覆盖 → 做一单）
1. 新卡定义：`docs/tasks/SB-*.md` 存在，且其编号未出现在 REVIEW_REQUEST.md 和 `progress.md` 的 done 记录里。
2. 从 main 切 `feat/SB-nnn-slug`，按卡施工（自检三件套：`dart format` + analyze 零 warning + 相关测试）。
3. `tool/ci.sh` 全绿后 commit，写 REVIEW_REQUEST.md（含验收对照+偏差声明），更新 `progress.md`（SB-nnn done），留在 feat 分支，解锁退出。
4. 无新卡 → 解锁退出（idle，不烧 token）。

## 铁律（违反=监工直接打回）
- 不 merge、不 push、不碰 remote、不改 `docs/` 规范内容、不加依赖（`pubspec.yaml` 依赖变更=0，除非任务卡明示）。
- 一轮只做一件事（S1 或 S2 二选一），做完就退出；绝不连做两张卡。
- commit 信息中文简短，必带 `[SB-nnn]`；流程类提交（无卡）用 `chore/` 分支 + `[LOOP]` 标记。
- `WAITING_HUMAN`、`_LOCK`、分支名即状态，不另建状态文件。
