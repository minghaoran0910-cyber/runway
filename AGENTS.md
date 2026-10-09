# AGENTS.md — 攒够项目协作规范

## 角色
- `opencode/Muse Spark`（我）：唯一开发。写代码、写测试、更新文档、提交 git。
- `openclaw / 老油条 main`：监工。不直接写业务代码，只审查、打回、定规范。
- 人（你）：路由器 + 最终拍板。负责把 openclaw 产出的需求文档丢进 `_inbox/`，并转述关键结论。

## 目录约定
- `/Users/dada561/Documents/runway`：本仓库，真相源。（2026-10-09 由 `Documents/攒够` 改名去中文，原因见 REVIEW_REQUEST D1，已关闭）
- 工程名/产品名不变：中文「攒够」，英文「Runway」。
- `_inbox/`：openclaw 产出的 PRD / 设计规范 / 接口文档投放区。你贴进来后告诉我，我负责整合到 `docs/`。
- `docs/`：整合后的正式文档（需求、架构、API、设计规范）。
- `task_plan.md`：任务拆解（我维护）。
- `progress.md`：开发进度（我维护，openclaw 只读）。
- `REVIEW_REQUEST.md`：我写，请求监工审查。
- `REVIEW.md`：openclaw 写，结论只能是 `PASS` 或 `REQUEST_CHANGES`。
- `findings.md`：技术调研记录。

## 开发流程
1. 你把 openclaw 梳理的需求丢进 `_inbox/`，跟我说一声。
2. 我整合到 `docs/` + 更新 `task_plan.md`，开工。
3. 我每完成一个里程碑：更新 `progress.md` + 写 `REVIEW_REQUEST.md`（含本次 diff / 测试结果），commit。
4. openclaw 巡检（cron，见 `SUPERVISOR.md`）：读 `REVIEW_REQUEST.md` + `git diff`，把结论写进 `REVIEW.md`。
5. 你看到 `REVIEW.md` 是 `REQUEST_CHANGES` 就转告我，我整改后重新发起审查。是 `PASS` 就继续下一里程碑。

## Git 规范
- 分支：`main` 稳定，开发用 `feat/*`，我提交前保证可运行。
- commit 信息中文简短，关联里程碑编号。
- 不 force-push，不改写已 PASS 的历史。

## 为什么不用我直接调 openclaw
实测本机网关已在运行（pid 60553），我侧 `openclaw agent --local / --agent` 会因 `DuplicateOpenClawRuntimeError` 被锁死。
所以采用文件 + cron 异步模式：我只写文件不直连，openclaw 靠 cron 主动来扫。这也是自动巡检能落地的唯一稳定方式。
