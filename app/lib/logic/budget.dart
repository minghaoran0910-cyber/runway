// SB-015 · 预算线引擎（PRD §2 改变层 / §3 换算口径：比预算基线多省；DESIGN §7 得到框架，纯 Dart）.
// 口径：
//   基线三要素 = 近 3 月中位数（防单月大额固化）→ 有去年同月优先同月 → 默认收紧 5%（0–15% 可调）.
//   取数优先级：同月 > 中位数 > 观察期（纯函数 suggestBudget，单测锁定；观察期零编造，budgetFen=0）.
//   省出 = max(0, budget − monthSpend) + max(0, lastMonth − monthSpend)（与 SB-007 同构，基线换成预算）.
//   周增量 = max(0, prevWeek − weekSpend)；周预算按 budget×7/30 折算对照.
// 文案一律"得到"框架；禁词复用 achievementBannedWords（零新增，不另建第二套）.
// 本文件禁 import flutter（logic 不依赖 ui/flutter）.

import 'entry.dart';
import 'goal_ladder.dart';

/// 默认收紧比例（基线之上少花 5% 才是预算）.
const int defaultTightenPct = 5;

/// 收紧比例合法区间.
const int tightenMin = 0;
const int tightenMax = 15;

/// 取数来源（单测断言用）.
enum BudgetBasis { sameMonth, median, observing }

/// 预算建议（纯值对象；observing=true 时 budgetFen=0，禁止编造）.
class BudgetQuote {
  const BudgetQuote({
    required this.basis,
    required this.basisFen,
    required this.tightenPct,
    required this.budgetFen,
    required this.observing,
  });

  final BudgetBasis basis;
  final int basisFen;
  final int tightenPct;
  final int budgetFen;
  final bool observing;
}

/// "省出"视图（与 GoalView 同构，基线换成预算）.
class BudgetSaved {
  const BudgetSaved({
    required this.savedVsBudget,
    required this.momGain,
    required this.convertibleFen,
  });

  final int savedVsBudget;
  final int momGain;
  final int convertibleFen;
}

/// 周增量视图.
class BudgetWeekly {
  const BudgetWeekly({
    required this.weekBudgetFen,
    required this.savedVsWeekBudget,
    required this.gainFen,
    required this.deltaFen,
  });

  final int weekBudgetFen;
  final int savedVsWeekBudget;
  final int gainFen;

  /// prev − cur（可负；展示走 weeklyMomText 口径）.
  final int deltaFen;
}

/// 月 key（budgets 表 monthKey 口径：YYYY-MM）.
String monthKeyFor(DateTime t) {
  final String m = t.month.toString().padLeft(2, '0');
  return '${t.year}-$m';
}

/// 三数中位数（防"上月买了台电脑"固化成预算）.
int median3(int a, int b, int c) {
  final List<int> v = <int>[a, b, c]..sort();
  return v[1];
}

/// 收紧换算（基线 × (100−pct)/100，下取整）.
int applyTighten(int basisFen, int tightenPct) {
  if (basisFen <= 0) return 0;
  final int p = tightenPct.clamp(tightenMin, tightenMax);
  return basisFen * (100 - p) ~/ 100;
}

/// 领域校验：返回 null = 合法，否则为错误文案.
String? validateTighten(int? pct) {
  if (pct == null) return '收紧比例须为 $tightenMin–$tightenMax';
  if (pct < tightenMin || pct > tightenMax) {
    return '收紧比例须为 $tightenMin–$tightenMax';
  }
  return null;
}

/// 领域校验：手动预算（分，须 >0）.
String? validateBudgetFen(int? fen) {
  if (fen == null || fen <= 0) return '预算金额须大于 0';
  if (fen > 10000000000) return '预算金额过大';
  return null;
}

/// 预算建议（纯函数；优先级 同月 > 中位数 > 观察期）.
/// - sameMonthFen>0 即优先同月（春节该高就高）；
/// - 否则近 3 月须满 3 个数据月（dataMonths>=3）才给中位数；
/// - 否则观察期（observing，budgetFen=0，禁止编造）.
BudgetQuote suggestBudget({
  int? sameMonthFen,
  required int m0Fen,
  required int m1Fen,
  required int m2Fen,
  required int dataMonths,
  int tightenPct = defaultTightenPct,
}) {
  final int p = tightenPct.clamp(tightenMin, tightenMax);
  if (sameMonthFen != null && sameMonthFen > 0) {
    return BudgetQuote(
      basis: BudgetBasis.sameMonth,
      basisFen: sameMonthFen,
      tightenPct: p,
      budgetFen: applyTighten(sameMonthFen, p),
      observing: false,
    );
  }
  if (dataMonths >= 3) {
    final int med = median3(m0Fen, m1Fen, m2Fen);
    if (med > 0) {
      return BudgetQuote(
        basis: BudgetBasis.median,
        basisFen: med,
        tightenPct: p,
        budgetFen: applyTighten(med, p),
        observing: false,
      );
    }
  }
  return BudgetQuote(
    basis: BudgetBasis.observing,
    basisFen: 0,
    tightenPct: p,
    budgetFen: 0,
    observing: true,
  );
}

/// 预算口径省出（两项各自钳零，不存在负省出；改预算即换基线重算）.
BudgetSaved computeBudgetSaved({
  required int budgetFen,
  required int monthSpendFen,
  required int lastMonthSpendFen,
}) {
  final int savedVsBudget = budgetFen - monthSpendFen > 0
      ? budgetFen - monthSpendFen
      : 0;
  final int momGain = lastMonthSpendFen - monthSpendFen > 0
      ? lastMonthSpendFen - monthSpendFen
      : 0;
  return BudgetSaved(
    savedVsBudget: savedVsBudget,
    momGain: momGain,
    convertibleFen: savedVsBudget + momGain,
  );
}

/// 周增量（相对周预算 + 环比增量，各自钳零）.
BudgetWeekly computeBudgetWeekly({
  required int budgetFen,
  required int weekSpendFen,
  required int prevWeekSpendFen,
}) {
  final int weekBudget = budgetFen > 0 ? budgetFen * 7 ~/ 30 : 0;
  final int saved = weekBudget - weekSpendFen > 0
      ? weekBudget - weekSpendFen
      : 0;
  final int gain = prevWeekSpendFen - weekSpendFen > 0
      ? prevWeekSpendFen - weekSpendFen
      : 0;
  return BudgetWeekly(
    weekBudgetFen: weekBudget,
    savedVsWeekBudget: saved,
    gainFen: gain,
    deltaFen: prevWeekSpendFen - weekSpendFen,
  );
}

/// 预算标题（得到框架）.
String budgetTitle({required bool observing}) {
  return observing ? '本月预算 · 观察期' : '本月预算 · 已生效';
}

/// 预算正文（得到框架；大额只陈述复用 equivalentOf）.
String budgetBody({required int budgetFen, required int savedFen}) {
  if (budgetFen <= 0) return '记满 3 个月，自动给出本月预算';
  if (savedFen <= 0) return '本月预算 ${formatFen(budgetFen)} · 持平即是稳';
  return '本月预算 ${formatFen(budgetFen)} · 已省出 ${formatFen(savedFen)} · ${equivalentOf(savedFen)}';
}

/// 预算状态行（得到框架；超预算不报负数、不劝阻）.
String budgetHint({
  required int budgetFen,
  required int monthSpendFen,
  required int savedFen,
}) {
  if (budgetFen <= 0) return '先记账，预算自然来';
  if (monthSpendFen >= budgetFen) {
    return '本月已用 ${formatFen(monthSpendFen)} · 预算 ${formatFen(budgetFen)} · 稳步积累的证明';
  }
  final double pct = (savedFen / budgetFen).clamp(0.0, 1.0).toDouble();
  return '已省出 ${(pct * 100).toStringAsFixed(0)}% 预算 · 得到阶段性底气';
}

/// 预算基线说明（得到框架；同月/中位数/观察期三态）.
String budgetBasisText({required BudgetQuote quote}) {
  switch (quote.basis) {
    case BudgetBasis.sameMonth:
      return '基线取去年同月 ${formatFen(quote.basisFen)} · 收紧 ${quote.tightenPct}%';
    case BudgetBasis.median:
      return '基线取近 3 月中位数 ${formatFen(quote.basisFen)} · 收紧 ${quote.tightenPct}%';
    case BudgetBasis.observing:
      return '数据不足 3 个月 · 可手动设定预算';
  }
}
