# Changelog（Keep-a-Changelog）

## [Unreleased] — G5 打磨冻结中（SB-012）

- SB-012 预算卡上首页：同一 `BudgetZone` 进首页看板（周报页保留，口径零改）；`tool/perf_check.sh` 性能预算脚本（合成 1 万条聚合 <1.5s＋其他占比 <5%＋包体基线 +20% 卡）；首页预算区 golden（`golden/sb012/` Light/Dark）；`sb006` 看板四图因首页同区连带重生成。
- 待监工/真人闸门（验收 1/2/8/9）：六类动效双端真机走查、冷启动与滚动帧 trace（`golden/perf/`）、Android／iOS 模拟器＋Mac 三端冒烟、浩然 7 天真实使用后验；通过后打 annotated tag v0.1.0。

## [v0.1.0 待冻结] — G1–G4＋改变层已合入（2026-10-09 → 2026-10-12）

### G1 骨架

- SB-001 建仓＋CI 四闸门跑通（format/analyze/test/build）。
- SB-002 Android 构建双平台化。
- SB-003 设计 token 落地（Light/Dark，CSS 镜像对齐）。

### G2 核心闭环

- SB-004 三秒记一笔（含本地存储 schema v1，可查可改可删）。
- SB-005 规则引擎自动归类（其他占比 >5% 即故障口径确立）。
- SB-006 首页目标看板（Hero／今日／Top5／目标，30 秒日报）。

### G3 钩子层

- SB-007 目标阶梯与实物换算（攒到层入口，schema v2）。
- SB-008 成就卡与解锁庆祝（schema v3）。
- SB-009 安全垫与周报。

### G3.5 改变层（2026-10-10 浩然批准增补）

- SB-015 预算线（同月＞中位数＞观察期自动给，一键改，schema v7）。
- SB-016 每日收口一键（schema v8，估算 source=estimate）。
- SB-017 大额冷静期（schema v9，日均×3，只 manual 触发）。
- SB-018 月度小实验（schema v10，7 天打卡，实验成就防撞段）。
- SB-019 分类角色轴（必要／固定／弹性，schema v11；预算与冷静仅弹性过滤）。

### G4 采集与自动化

- SB-010 Android 通知监听采集（去重三元组 key，Kotlin/Dart 同构）。
- SB-011 账单文件导入（邮件附件半自动口径）。
- SB-013 applicationId 归一（com.zangou.runway，四端）。

### 习惯层与温度线

- SB-014 余粮正名与粮仓梗包（得到框架，禁词＋4）。
- SB-020 常买价格眼（同类商品价格统计）。
- SB-022 零日温度线（负结余打趣三段＋点名制，「今天攒 0」仅恰零可用）。

### 已知偏差（浩然可一票翻案，默认接受）

- SB-022 G1：sb016／sb006 存量 golden 未重生成（saved≥0 路径一字不动，全量 golden 零像素差实证）。
- SB-022 G2：JoyRow 用小类而非 record（400 行红线下等价表达）。
- SB-014 D1：DB 标识符保持英文；SB-015 D1：schema 卡注编号过期按实际 v6→v7 执行。
- SB-015 D2／SB-018 D2／SB-019 D2：首页接线与新建类目表单延后项（SB-015 首页接线由本轮 SB-012 闭环，其余留 v0.2）。
- SB-021 时间望远镜摘出 v0.1（2026-10-10 浩然拍板，需 3 个月稳定基线，挂起 v0.2）。

---

格式：Keep-a-Changelog；每卡验收归档时同步写入（GIT_WORKFLOW §5），禁事后补大段。
