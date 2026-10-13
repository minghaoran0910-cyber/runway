# 攒够 / Runway

给自己做的一本账：把「钱去哪了」变成「攒够了多少」。

- **定位**：本地优先、无账号、不上云的个人记账 App，核心指标是**攒钱跑道**（runway）——跑道就是离开桌子的自由
- **技术**：Flutter 3.44 / Dart（Impeller 渲染）+ SQLite，一套代码覆盖 Android / iOS / macOS / Windows
- **数据观**：通知采集只落结构化字段 + hash 去重，原文解析即删；真实账本永不进仓库（验收全部用合成数据集）

## 平台现状（v0.1.0 冻结前）

| 平台 | 构建 | 装机验收 |
|---|---|---|
| Android | ✅ 本地+CI | ✅ 真机+模拟器双验（通知采集已落地） |
| macOS | ✅ | ✅ 装机+六类动效走查+性能实测 |
| iOS | ✅ | ✅ 模拟器装机；快捷指令采集路径已定案（见 docs/adr/） |
| Windows | ✅ GitHub Actions 云构建 | ⏳ exe 已验真，真机双击冒烟挂账 |

开发流程：任务卡（docs/tasks/）→ builder 实现 → 监工独立审查 → squash 合入。已归档 24 张卡，完整履历见 `CHANGELOG.md`。

## 目录结构

```
app/                 Flutter 工程（唯一产品代码）
docs/                PRD、设计系统、开发规范、ADR、任务卡（tasks/）
golden/              golden 图基线
tool/                四闸门脚本（format / analyze / test / build）
.github/workflows/   云端构建（Windows/Android 自动，Apple 手动）
```

## 本地开发

```bash
cd app
flutter pub get
flutter test          # 全量测试
bash ../tool/ci.sh    # 四闸门一票合一
```

## 云端构建

- push 改动 `app/**` 自动触发 **Windows release** 与 **Android debug** 构建，产物在 Actions 页下载
- macOS / iOS 用 workflow_dispatch 手动触发（iOS 走 --no-codesign，仅构建验证）

## 状态

v0.1.0 冻结在即：三端闸门已过，真人体验期进行中。问题与决定都记在 `REVIEW.md` / `docs/tasks/`。
