# REVIEW_REQUEST — SB-024 iOS采集设计稿 v2（第2轮·应答第1轮RC）

仓库：`/Users/dada561/Documents/runway`，分支：`feat/SB-024-ios-design`（未 merge、未 push、无 remote，合规）
任务卡：`docs/tasks/SB-024.md`（含第二轮浩然 16:57 修订令：快捷指令升正式渠道 + 四平台导入矩阵）
基座：`main@c65547a` 起步 → 本轮 `merge main` 取修订令 + PRD/ROADMAP 裁定入册（`6bab9ac`，progress 按时序 union 解冲突）
R4 计数：1/2（第1轮 RC，非规范变更计轮；本轮为第 2 轮，未达 WAITING_HUMAN 线）

施工改动（业务文件 1≤10，单文件 89 行≤400）：
- `docs/adr/ADR-iOS-通知采集路径.md`（重写 v1 79 行→v2 89 行）：v1 作废声明 + 前提修正（路径被锁≠通道被锁，主动拉被锁/被动推允许）+ SB-010 基座引用面全保留（makeNotifyKey/pending_records v5/sourcePkg/insertPendingDedup/notifyContentHash/channel d6ae1ab）+ A 升正式主路径（推送落盘）+ B 降对账兜底 + C 保留 + 四平台×四路矩阵表（每格路径/依赖/置信度/坑）+ 隐私即删盘 + schema 零迁移（sourcePkg 扩展 ios-shortcut/desktop-dir，两套键禁第三套）+ 决策自评 v2 + V2-1 四拆解预案（a/b/c/d，tag 后第一批）+ §7 偏差如实申报。
- PRD/ROADMAP 未动：采集裁定已由监工 `2e77dcf` 入册，builder 未重复改，避免冲突。
- `app/` 零改动（`git diff --name-only main...HEAD -- app/` 实测空）；无 pubspec；无 remote。

验收对照（卡 SB-024 原三项 + 修订令五条）：
1. ADR 内容：三路各含原理/限制/工程量/失败模式，给出推荐 + 理由；结论引用 SB-010 去重键与 schema 兼容面（零迁移、两套键分工）——达标（§1/§2/§4）。
2. 零代码：不改 app/、不引依赖；本轮 docs 仅改该 ADR 1 文件（PRD/ROADMAP 系监工已入册，非本轮改动）——达标。
3. 决策打分留档：§5 自评 v2（总推荐 0.78 接受/v1 原推荐 0.20 拒绝/在线拉取 0.30 缓做 + 识别选型 0.50、目录监听 0.62 两灰区留裁决），请监工复核——达标。
4. 第1轮 RC 两处乱码已修：A 工程量行"对称实现"、C 失败模式行"沉淀在周报"，全文件拉丁残片自查通过——达标。
5. 修订令：A 主路径 + B 兜底 + C 保留 + 矩阵表 + 即删盘 + 拆解预案 + v0.1 冻结线不变（零运行时代码）——达标。

测试：`tool/ci.sh` ALL GREEN（format 0 改动/analyze No issues/smoke 通过/双构建成功）+ `tool/check-repo-hygiene.sh` OK；纸面卡零代码，冒烟锚点 cd5d73a 维持（cd5d73a..HEAD 非 docs 实测零代码，复用监工口径）。

偏差声明（如实申报）：
① v1 首轮偏差声明误写"无偏差"（正文自带 2 缺陷），本轮承认并已修复，§7 留档。
② 英文残留均为必要产品/代码名（App Groups/Vision/PaddleOCR/Tesseract/makeNotifyKey/sourcePkg 等），已在 §7 申报，非乱码。
③ 灰区两项（Windows 识别二选一 0.50、目录监听进首批 0.62）留监工/浩然裁决，不阻塞审。
④ 在线拉取命名由"IMAP"改为通用"在线拉取"（方向不变，SB-011 原文如此），请监工确认口径。

文件约束：业务 1 文件≤10；单文件 89≤400；无 pubspec；无 remote；真实账目 0；禁词零新增；_LOCK 本轮退场即删。

状态：待审查（2026-10-12 17:5x builder 提审·SB-024 第2轮；feat 分支未合入）
