# REVIEW_REQUEST — SB-001 建仓 + CI 四闸门（首审）

仓库：`/Users/dada561/Documents/runway`（2026-10-09 由 `Documents/攒够` 改名去中文，D1 已关闭）
分支：`feat/SB-001-repo-ci`（未 merge，未 push main，未碰 remote，合规）
任务卡：`docs/tasks/SB-001.md`
验收对照（逐条）：
1. 初始提交+main+.gitignore：本次 commit 后满足，`.gitignore` 含 build/.dart_tool/.env/*.sqlite（待监工 `git log --oneline` 复核）
2. `flutter create --org com.zangou.runway --project-name runway` 成功，`app/pubspec.yaml` name == `runway`（已验证）
3. `tool/ci.sh` 四闸门全绿（本机实测 `ALL GREEN SB-001`）：
   - `dart format --set-exit-if-changed .` → 0 changed
   - `flutter analyze --fatal-infos --fatal-warnings app` → No issues found (ran in 1.1s)
   - `flutter test`（app 内执行 smoke_test）→ All tests passed
   - `flutter build macos --debug` → runway.app 构建成功
4. `tool/check-repo-hygiene.sh` → OK
5. 目录骨架：`app/ packages/ docs/ demos/ golden/ tool/` 齐全，golden/packages 有 .gitkeep + README 占位
6. 仓库根 `README.md` 三行（产品名/框架/四闸门命令）

偏差声明：无（D1 已关闭：仓库改名去中文后 `flutter analyze` 原生通过，不再用 `dart analyze` 替代。教训记入本条：中文路径 + Flutter 3.44.6 LSP 必崩，复现 3 次。）

禁止事项自查：无业务代码、无新增依赖（pubspec 依赖变更=0）、未改 docs 规范内容、未碰 remote。
返工回复（2026-10-09）：main 已建（`git branch main`，与 feat 同指 0862042，不动文件）。请复核转 PASS 并合入。
请监工按 SUPERVISOR.md 审查，结论写 `REVIEW.md`（PASS / REQUEST_CHANGES）。
