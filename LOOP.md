# LOOP.md — runway 自动施工循环（headless 唤醒入口）

> 本文件是 `opencode run` 每次被唤醒后的唯一指令来源。不依赖上轮记忆，一切以文件为准。
> 期望的唤醒语（openclaw 侧 cron 拥有，备查）：`读 LOOP.md，按状态机只做一件事，做完就退出；_LOCK 存在则直接退出`，工作目录 `/Users/dada561/Documents/runway`。
> 权限实测结论（2026-10-09，三次 headless 探测）：工作区内读/写/删/in-repo bash/本地 commit 均允许；工作区外（`/tmp` 等）一律拒绝。所以锁文件放仓库根 `_LOCK`（已 gitignore），绝不碰 `/tmp`。

## S0 守卫（任一命中 → 直接退出，exit 0，不动任何文件）
1. `LOOP.md` 不在工作树 → 退出（环未就绪）。
2. 当前分支不是 `main` → 退出（等监工合入，见 SUPERVISOR.md 附录合入舞步）。
3. `_LOCK` 存在且其中 PID 存活 → 退出（另一轮在跑）；PID 已死 → 删锁继续。
4. 工作树脏（业务文件有未提交修改）→ 退出（有人在干活，不抢）。流程文件不算脏：`REVIEW.md`、`REVIEW_REQUEST.md`、`progress.md`、`task_plan.md`、`LOOP.md`、`SUPERVISOR.md` 的修改直接忽略，只看其他文件，例如：`git status --short | grep -v -E ' (REVIEW(_REQUEST)?|progress|task_plan|LOOP|SUPERVISOR)\.md'` 非空才算脏。
5. `REVIEW_REQUEST.md` 的 mtime 新于 `REVIEW.md` → 退出（等监工审查）。
6. `REVIEW_REQUEST.md` 含 `WAITING_HUMAN` → 退出（等人工裁决，唤醒任务应已被监工暂停）。

通过守卫后：创建 `_LOCK`（写 PID+时间），全程 `trap` 保证退场删锁（`trap 'rm -f _LOCK' EXIT`）。

## S1 返工（REVIEW 结论为 REQUEST_CHANGES → 修一轮）
1. 先数轮次：`REVIEW.md` 中针对本卡的 `REQUEST_CHANGES` 已出现 ≥2 次 → 本次即第 3 轮，不再动手，直接 REVIEW_REQUEST 写 `WAITING_HUMAN`（说明卡或规范可能有问题），解锁退出。（前提：监工写 REVIEW 时给轮次编号，见 SUPERVISOR.md 附录。）
2. 否则按 REVIEW.md 问题列表逐条改（DEV/GIT 规范全遵守：`feat/SB-nnn-slug` 分支、文件数 ≤10、单文件 ≤400 行、不碰禁区）。
3. 跑 `tool/ci.sh` 全绿 + `tool/check-repo-hygiene.sh`。
4. commit（格式 `type(scope): 描述 [SB-nnn]` + trailer `Agent: opencode`）→ 先更新 `progress.md` → 再写 REVIEW_REQUEST.md。留在 feat 分支，解锁退出。

## S2 新卡（有任务卡且未做过 → 做一单）
1. 新卡定义：`docs/tasks/SB-*.md` 文件存在，且其编号未出现在 `progress.md` 的 done 记录里（`progress.md` 是唯一真相注册表，`REVIEW_REQUEST.md` 会被重写不能作为依据）。不许自创卡。
2. 开工前必读（DEV_WORKFLOW §2.1 每任务新会话注入，headless 无记忆，必须明示）：`docs/README.md` + `docs/DEV_WORKFLOW.md` + `docs/GIT_WORKFLOW.md` + `docs/DESIGN_SYSTEM.md` + 本任务卡。禁止凭记忆写码。
3. 从 main 切 `feat/SB-nnn-slug`，按卡施工（自检三件套：`dart format` + analyze 零 warning + 相关测试）。
4. `tool/ci.sh` 全绿后 commit → 先更新 `progress.md`（SB-nnn done）→ 再写 REVIEW_REQUEST.md（含验收对照+偏差声明）。留在 feat 分支，解锁退出。
5. 无新卡 → 解锁退出（idle，不烧 token）。

## 写文件原子性（防巡检读半截）
更新 `REVIEW_REQUEST.md` / `progress.md` / `task_plan.md` 一律先写临时文件再 `mv` 覆盖，例如：`cat > REVIEW_REQUEST.md.tmp.$$ <<'EOF' ... EOF && mv REVIEW_REQUEST.md.tmp.$$ REVIEW_REQUEST.md`。`_LOCK` 的创建删除不需要原子性。向 `progress.md` 追加单行时同样：`cp` 到 tmp、追加、再 `mv` 回。

## Watchdog（巡夜，每 2h，openclaw cron `runway-watchdog` command 模式）
调度器宿主结论（2026-10-09 实测）：macOS launchd 跑不起来——`~/Documents` 受 TCC 保护，launchd 上下文读仓内文件直接 `Operation not permitted`（复现两次，已卸载 plist）。openclaw 网关上下文有目录授权（巡检可读写），故 watchdog 与唤醒一样挂 openclaw cron；`tool/loop-watch.sh` 留作等价手动入口（经授权的 shell 里可直接跑）。
- 默认只读：按下清单检查，全过即健康 → 零写入直接退出。
- 清单：①唤醒 `攒够-loop唤醒` 与巡检 `攒够-监工巡检` 都在且 enabled（`openclaw cron list`，调不通则记 unknown 跳过，不算病）；②当前分支是 main 且无悬空 `feat/*` 分支；③`_LOCK` 不存在，或存在但 PID 已死；④`REVIEW_REQUEST.md` 新于 `REVIEW.md` 超过 2h（巡检连续 ~4 轮没来）；⑤`progress.md` 停滞超 24h 且无 `WAITING_HUMAN`；⑥`WAITING_HUMAN` 存在（只记录，不重复写，等人工）。
- 分级处置（一次只做一件，做完就退）：死锁（③命中）→ 删锁，并在 `progress.md` 追加一行说明；④/⑤命中 → `progress.md` 追加一行告警（巡检读 progress，自会接手）；连续两轮仍 sick 且 loop 实质停转 → 写 `WAITING_HUMAN` 熔断。
- 禁区：绝不碰业务代码，绝不 commit/merge/push，绝不改 `docs/` 规范。健康检查本身不许产生提交。

## 铁律（违反=监工直接打回）
- 不 merge、不 push、不碰 remote、不改 `docs/` 规范内容、不加依赖（`pubspec.yaml` 依赖变更=0，除非任务卡明示）。
- 一轮只做一件事（S1 或 S2 二选一），做完就退出；绝不连做两张卡。
- commit 信息中文简短，必带 `[SB-nnn]`；流程类提交（无卡）用 `chore/` 分支 + `[LOOP]` 标记。
- `WAITING_HUMAN`、`_LOCK`、分支名即状态，不另建状态文件。
