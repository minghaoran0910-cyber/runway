# task_plan.md

> G0 已过闸（2026-10-09 浩然批准：命名 攒够/Runway，框架 Flutter，Android 先行）。
> 规范真相源：`docs/`（由 `_inbox/` 6 份搬运而来，只搬运不改内容）。

## 里程碑（对齐 DEV_WORKFLOW §6）
- [x] M0 需求整合：`_inbox/` 6 份 → `docs/PRD.md / DESIGN_SYSTEM.md / DEV_WORKFLOW.md / GIT_WORKFLOW.md / README.md / tasks/SB-001.md`
- [x] SB-001 建仓 + CI 四闸门：PASS，squash 合入 main（`d6ef4da`）
- [ ] loop bootstrap：`LOOP.md` + 监工手册附录（分支 `chore/loop-bootstrap`，待合入）
- [ ] SB-002：等监工发卡（Android SDK + build 双平台化），发卡后自动开工
- [ ] G1 骨架剩余：设计 token 落地 + CI 接入（SB-002 起）
- [ ] G2 核心闭环：三秒记一笔 → 分类 → 首页目标看板
- [ ] G3 钩子层：目标阶梯/成就卡/安全垫/周报
- [ ] G4 采集：Android 通知监听 / 邮件导入
- [ ] G5 打磨冻结 → tag v0.1.0

## SB-001 卡内文件（flutter create 生成物除外）
1. `tool/ci.sh`
2. `tool/check-repo-hygiene.sh`
3. `app/analysis_options.yaml`（覆盖默认，严格化靠 CI --fatal-infos）
4. `app/test/smoke_test.dart`
5. `README.md`（仓库根三行）
6. `.gitignore`
7. `golden/.gitkeep + README.md`、`packages/.gitkeep + README.md`（占位）
8. `docs/` 搬运 6 份（不算编辑）

## 当前阻塞
- 等监工合入 loop bootstrap + 下发 SB-002（巡检会自动处理，无需人工传声）。
