// SB-019 · 分类角色轴（PRD §3 分类角色 / §2 改变层，纯 Dart）.
// 口径：角色是属性层，SB-005 场景类目不重构；每个类目必映射 必要/弹性/固定 之一，无未映射态.
// 默认映射（2026-10-10 决策模型 0.93）：行/用/食=必要；玩/其他=弹性；居=固定.
// 餐饮默认必要但引导拆出「聚餐」为弹性（一次性引导卡，不强制，由调用方按候选展示）.
// 预算基线与冷静阈值只压弹性：调用方按本文件过滤后复用 SB-015/SB-016/SB-017 原公式，禁第二套.
// 本文件禁 import flutter（logic 不依赖 ui/flutter）.

import 'achievement.dart';
import 'category_rules.dart';

// SB-039 ② · 角色人话化：UI 展示经 [roleLabel]（要花的/能省的/固定的）；
// 存储串经 [roleName] 保持旧值（必要/弹性/固定），存量覆盖零迁移；
// [parseRole] 新旧全收（旧串读入即归一到同一枚举）.

/// 分类角色（必要=刚性开支；弹性=优化主战场；固定=账单）.
enum CategoryRole { necessary, flexible, fixed }

/// 角色中文名（UI 直显·人话）.
String roleLabel(CategoryRole role) {
  switch (role) {
    case CategoryRole.necessary:
      return '要花的';
    case CategoryRole.flexible:
      return '能省的';
    case CategoryRole.fixed:
      return '固定的';
  }
}

/// 中文名 → 角色（人话与旧术语全收，未知返回 null，调用方提示必选）.
CategoryRole? parseRole(String raw) {
  switch (raw.trim()) {
    case '要花的':
    case '必要':
      return CategoryRole.necessary;
    case '能省的':
    case '弹性':
      return CategoryRole.flexible;
    case '固定的':
    case '固定':
      return CategoryRole.fixed;
    default:
      return null;
  }
}

/// 角色 → 存储串（与 SB-019 落库口径一致，恒为旧术语，禁随展示改）.
String roleName(CategoryRole role) {
  switch (role) {
    case CategoryRole.necessary:
      return '必要';
    case CategoryRole.flexible:
      return '弹性';
    case CategoryRole.fixed:
      return '固定';
  }
}

/// 领域校验：新建/编辑类目必选角色（null/空即非法）.
String? validateRole(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return '请选择角色：要花的 / 能省的 / 固定的';
  }
  if (parseRole(raw) == null) return '角色只能是要花的 / 能省的 / 固定的';
  return null;
}

/// 默认映射（标准名口径；旧名先经 canonicalCategory 归一）.
/// 其他归弹性：未知即暴露为可优化，不藏进刚性.
const Map<String, CategoryRole> defaultCategoryRoles = <String, CategoryRole>{
  '食': CategoryRole.necessary,
  '行': CategoryRole.necessary,
  '用': CategoryRole.necessary,
  '居': CategoryRole.fixed,
  '玩': CategoryRole.flexible,
  '其他': CategoryRole.flexible,
};

/// 解析角色（归一 → 用户覆盖优先 → 默认 → 弹性兜底，永不返回 null）.
CategoryRole resolveRole(
  String category, [
  Map<String, CategoryRole>? overrides,
]) {
  final String canon = canonicalCategory(category.trim());
  final CategoryRole? custom = overrides?[canon];
  if (custom != null) return custom;
  return defaultCategoryRoles[canon] ?? CategoryRole.flexible;
}

/// 是否弹性类目（预算/冷静联动过滤用）.
bool isElasticCategory(
  String category, [
  Map<String, CategoryRole>? overrides,
]) {
  return resolveRole(category, overrides) == CategoryRole.flexible;
}

/// 聚餐拆分候选：食类 + 备注含聚餐 → 建议拆为弹性（只引导，不强制改类）.
bool isDiningSplitCandidate({required String category, required String note}) {
  if (canonicalCategory(category) != '食') return false;
  return note.contains('聚餐');
}

/// 角色汇总（本月弹性占比供数；空输入 share=0）.
class RoleSummary {
  const RoleSummary({
    required this.totalFen,
    required this.elasticFen,
    required this.fenByRole,
  });

  final int totalFen;
  final int elasticFen;
  final Map<CategoryRole, int> fenByRole;

  double get elasticShare => totalFen <= 0 ? 0 : elasticFen / totalFen;
}

/// 按角色聚合（金额分 + 类目 + 可选覆盖）.
RoleSummary summarizeRoles(
  Iterable<({int amountFen, String category})> flows, [
  Map<String, CategoryRole>? overrides,
]) {
  final Map<CategoryRole, int> map = <CategoryRole, int>{
    CategoryRole.necessary: 0,
    CategoryRole.flexible: 0,
    CategoryRole.fixed: 0,
  };
  int total = 0;
  int elastic = 0;
  for (final ({int amountFen, String category}) f in flows) {
    final CategoryRole r = resolveRole(f.category, overrides);
    map[r] = (map[r] ?? 0) + f.amountFen;
    total += f.amountFen;
    if (r == CategoryRole.flexible) elastic += f.amountFen;
  }
  return RoleSummary(totalFen: total, elasticFen: elastic, fenByRole: map);
}

/// 弹性占比头行文案（放类目管理页头部，首页不放；得到框架）.
String elasticShareText({required double share, required int elasticFen}) {
  final String pct = (share * 100).toStringAsFixed(1);
  if (elasticFen <= 0) return '本月能省的占比 0% · 先记账，优化空间自然来';
  return '本月能省的占比 $pct% · 可优化的空间在这里';
}

/// 聚餐引导文案（一次性引导卡，不强制）.
// SB-045 ③ · 长句拆短：主句 ≤14 字（13 字）；自动提示行为发生时可见，
// 同屏副行（已发现 N 笔聚餐记录）保留白话锚.
String diningGuideText() => '餐饮记为要花的，聚餐可拆分';

/// 本卡禁词复用成就表（不另建第二套；角色文案零命中）.
List<String> get roleBannedWords => achievementBannedWords;
