# GIT_WORKFLOW · Git 规范（v1.1）

> 原则：历史即审计线索。一个人 + AI 协作的项目，更要靠规矩防止"AI 把仓库写成垃圾场"。

## 1. 仓库形态
- 单仓 mono-repo：`app/ packages/ docs/ demos/ golden/ tool/`（demos/ 存放 tokens.css 与 sprite.svg，镜像链见 DESIGN_SYSTEM §9）；规范文档与代码同仓同版本——opencode 在仓库内读 docs/，规范改动即 PR 改动，天然版本化。
- **main 是唯一长期分支**；除 release/vx 外不留长分支。

## 2. 分支规则
- 功能分支：`feat/SB-<nnn>-<slug>`，一卡一支，从 main 切出，**上限 10 文件**；合并即删。
- 修复：小修直接 `fix/SB-<nnn>-<slug>`；线上紧急 `hotfix/<desc>`（基于 tag 切，修完合回 main 与 release）。
- 发布：`release/v<x.y.z>` 只收版本号/CHANGELOG/文案修复，功能冻结。

## 3. Commit 规范
- 格式：`type(scope): 描述 [SB-nnn]`；subject ≤50 字；type 白名单：feat / fix / refactor / perf / test / docs / design / chore。
- **design 型专用于 token/设计规范变更，未获批准不得使用**（设计漂移是 AI 开发第一风险）。
- 一个 commit 一个逻辑变更；格式化改动禁止与逻辑改动混提；禁 "update/fix bug/wip" 类无信息 message。
- AI 产出 commit 必须带 trailer：`Agent: opencode`——监工抽查（每周 ≥2 笔深 diff）与事后归因都靠它。
- push 前可 rebase 整理；**push 后不许 amend**，用 `fixup!` + autosquash（feat/* 私有分支允许因此 force-push 自身分支；main 与 release/* 任何情况下禁 force-push）。

## 4. 合并规则（门禁）
- opencode **无 merge 权、无 push main 权**；只有监工（老油条）能合入 main。
- 合入前置条件：CI 四闸门绿（format / analyze 零告警 / test 含 golden / Android+macOS build）+ 监工审计通过（对照任务卡与规范条款）。
- 合入方式：**squash**，落 main 标题 = `feat(scope): 描述 [SB-nnn]`（一卡一个 main commit，历史干净可回放）。
- main 禁止 force-push；main 坏了 revert 优先，不重写历史。

## 5. Tag 与发布
- 语义化版本 v<主>.<次>.<补丁>；每个里程碑闸门（G1-G5）打 **annotated tag**，message 写闸门结论与已知偏差。G0 不打 tag；G5 冻结 tag v0.1.0（与 DEV_WORKFLOW §6、README 开工顺序对齐）。
- CHANGELOG.md 按 Keep-a-Changelog：每卡验收归档时同步写入，禁事后补大段。

## 6. 钩子与 CI 强制项
- pre-commit：`dart format --set-exit-if-changed` + `flutter analyze --fatal-infos` + secret 扫描（gitleaks 规则）。
- pre-push：跑本模块相关测试；golden 基线图（`golden/`）变更必须在 PR 描述写明原因，**监工逐张目审**（防 AI 改基线骗过测试）。
- CI 四闸门缺一不可，禁 skip；同一测试连续两次因"环境抖动"重跑 → 记入 lessons.md。

## 7. 仓库卫生（禁区）
- .gitignore 必含：build/ DerivedData/ *.sqlite .env —— 模板 `.env.example` 只放键名；**真实值永不入库**。
- **真实账目数据不进仓库**：测试一律合成 fixtures；个人真实消费数据留在 SilentBook/未来 App 本地库。
- 二进制资源只允许 `design/` 下经 git-lfs 管理；代码目录出现二进制=打回。
- 锁文件冲突未解、超过 5MB 的单文件、任何密钥形态字符串（正则扫描），三选一出现即 CI 红。

## 8. 决策留痕
- 架构类决定（换库/分层调整/迁移策略）写 `docs/adr/NNN-<slug>.md`，commit 引用 ADR 编号；口头否决也算记录（状态 Rejected）。
