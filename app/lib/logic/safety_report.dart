// SB-009 · 安全垫与周报引擎（PRD §2 安全垫/自由基金 / §6 周报；DESIGN §7 得到框架，纯 Dart）.
// 口径（复用 SB-007，不复制第二套）：
//   安全垫目标 = 近 3 月月均支出 × 目标月数（默认 6 个月，可设 1–36）；
//   自由基金余额 = 本月可换算省出（goal_ladder.computeGoal 口径）；
//   进度 = 余额 / 目标额（钳 0..1）；
//   周报省出 = max(0, 上周支出 − 本周支出)（单环比增量，避免周粒度双计；
//     文案换算复用 equivalentOf/describeSaving；禁词复用 achievementBannedWords）.
// 本文件禁 import flutter（logic 不依赖 ui/flutter）；日期边界全以传入 now 为准，便于测试.

import 'achievement.dart';
import 'category_rules.dart';
import 'dashboard_stats.dart';
import 'entry.dart';
import 'goal_ladder.dart';

/// 安全垫默认目标月数.
const int defaultSafetyMonths = 6;

/// 安全垫目标月数合法区间.
const int safetyMonthsMin = 1;
const int safetyMonthsMax = 36;

/// 安全垫视图（纯值对象）.
class SafetyPadView {
  const SafetyPadView({
    required this.avgMonthlySpendFen,
    required this.targetMonths,
    required this.targetFen,
    required this.fundFen,
    required this.progress,
    required this.done,
  });

  final int avgMonthlySpendFen;
  final int targetMonths;
  final int targetFen;
  final int fundFen;

  /// 0..1（目标<=0 时为 0）.
  final double progress;

  /// 已攒够安全垫.
  final bool done;
}

/// 领域校验：返回 null = 合法，否则为错误文案.
String? validateSafetyMonths(int? months) {
  if (months == null) return '目标月数须为 $safetyMonthsMin–$safetyMonthsMax';
  if (months < safetyMonthsMin || months > safetyMonthsMax) {
    return '目标月数须为 $safetyMonthsMin–$safetyMonthsMax';
  }
  return null;
}

/// 近 3 月月均支出（自然月；缺月按 0 计，纯函数）.
int avg3MonthSpend({
  required int monthSpendFen,
  required int lastMonthSpendFen,
  required int last2MonthSpendFen,
}) {
  return (monthSpendFen + lastMonthSpendFen + last2MonthSpendFen) ~/ 3;
}

/// 安全垫计算（目标 = 月均 × 月数；余额 = 本月可换算省出）.
SafetyPadView computeSafetyPad({
  required int avgMonthlySpendFen,
  required int fundFen,
  required int targetMonths,
}) {
  final int target = avgMonthlySpendFen * targetMonths;
  double progress = 0;
  bool done = false;
  if (target > 0) {
    progress = (fundFen / target).clamp(0.0, 1.0).toDouble();
    done = fundFen >= target;
  }
  return SafetyPadView(
    avgMonthlySpendFen: avgMonthlySpendFen,
    targetMonths: targetMonths,
    targetFen: target,
    fundFen: fundFen,
    progress: progress,
    done: done,
  );
}

/// 当月/上月/上上月支出汇总（自然月；纯函数，供 UI 由 transactions 推导）.
({int monthSpendFen, int lastMonthSpendFen, int last2MonthSpendFen})
sumLast3MonthSpend(
  List<({int amountFen, DateTime occurredAt})> rows,
  DateTime now,
) {
  int month = 0;
  int last = 0;
  int last2 = 0;
  final DateTime m1 = DateTime(now.year, now.month - 1, 1);
  final DateTime m2 = DateTime(now.year, now.month - 2, 1);
  for (final r in rows) {
    if (r.occurredAt.year == now.year && r.occurredAt.month == now.month) {
      month += r.amountFen;
    } else if (r.occurredAt.year == m1.year && r.occurredAt.month == m1.month) {
      last += r.amountFen;
    } else if (r.occurredAt.year == m2.year && r.occurredAt.month == m2.month) {
      last2 += r.amountFen;
    }
  }
  return (
    monthSpendFen: month,
    lastMonthSpendFen: last,
    last2MonthSpendFen: last2,
  );
}

/// 安全垫标题（得到框架；只报得到，无行动召唤）.
String safetyTitle({required int targetMonths}) {
  return '安全垫 · $targetMonths 个月开销底气';
}

/// 安全垫正文（得到框架；大额只陈述复用 equivalentOf）.
String safetyBody({required int fundFen, required int targetFen}) {
  if (targetFen <= 0) return '记满 3 个月，开始攒出第一个月底气';
  if (fundFen <= 0) return '本期持平 · 已有目标 ${formatFen(targetFen)} 等待攒出';
  return '已攒 ${formatFen(fundFen)} / 目标 ${formatFen(targetFen)} · ${equivalentOf(fundFen)}';
}

/// 安全垫下一站（得到框架；复用 goal_ladder.nextLadderHint 口径思想）.
String safetyHint({required int fundFen, required int targetFen}) {
  if (targetFen <= 0) return '先记账，底气自然来';
  if (fundFen >= targetFen) return '已攒够安全垫 · 得到阶段性底气';
  final double pct = (fundFen / targetFen).clamp(0.0, 1.0).toDouble();
  return '已攒 ${(pct * 100).toStringAsFixed(0)}% · 稳步积累的证明';
}

// —— 周报 ——

/// 周报 Top3 单项（复用 TopEntry 形状；此处独立定义避免 ui  import dashboard 细节）.
class WeeklyTop {
  const WeeklyTop({required this.category, required this.fen});

  final String category;
  final int fen;
}

/// 周报视图（纯值对象；income 暂 0 预留，transactions 暂无收入口径）.
class WeeklyReportView {
  const WeeklyReportView({
    required this.weekStart,
    required this.weekEnd,
    required this.spendFen,
    required this.incomeFen,
    required this.savedFen,
    required this.top3,
    required this.momDeltaFen,
  });

  final DateTime weekStart;
  final DateTime weekEnd;
  final int spendFen;
  final int incomeFen;
  final int savedFen;
  final List<WeeklyTop> top3;

  /// 本周相对上周的支出差（负 = 比上周多花；正 = 比上周省）.
  final int momDeltaFen;
}

/// 本周周一 00:00（本地时间；周一起算）.
DateTime weekStartFor(DateTime now) {
  final DateTime day = DateTime(now.year, now.month, now.day);
  return day.subtract(Duration(days: now.weekday - 1));
}

/// 周区间（含起止日；end = start + 6 天）.
({DateTime start, DateTime end}) weekRangeFor(DateTime now) {
  final DateTime s = weekStartFor(now);
  return (start: s, end: s.add(const Duration(days: 6)));
}

/// 周报聚合（纯函数；flows 复用 DashboardFlow，类目归一复用 canonicalCategory）.
/// savedFen = max(0, prevWeekSpend − weekSpend)；momDelta = prev − cur（可负）.
WeeklyReportView computeWeekly({
  required List<DashboardFlow> flows,
  required DateTime now,
  required int prevWeekSpendFen,
}) {
  final ({DateTime start, DateTime end}) range = weekRangeFor(now);
  final DateTime endEx = range.end.add(const Duration(days: 1));
  int spend = 0;
  final Map<String, int> byCat = <String, int>{};
  for (final DashboardFlow f in flows) {
    if (f.occurredAt.isBefore(range.start) || !f.occurredAt.isBefore(endEx)) {
      continue;
    }
    spend += f.amountFen;
    final String c = canonicalCategory(f.category);
    byCat.update(c, (int v) => v + f.amountFen, ifAbsent: () => f.amountFen);
  }
  final List<WeeklyTop> top =
      byCat.entries
          .map((e) => WeeklyTop(category: e.key, fen: e.value))
          .toList()
        ..sort((a, b) => b.fen.compareTo(a.fen));
  final List<WeeklyTop> top3 = top.length <= 3 ? top : top.sublist(0, 3);
  final int saved = prevWeekSpendFen - spend > 0 ? prevWeekSpendFen - spend : 0;
  return WeeklyReportView(
    weekStart: range.start,
    weekEnd: range.end,
    spendFen: spend,
    incomeFen: 0,
    savedFen: saved,
    top3: top3,
    momDeltaFen: prevWeekSpendFen - spend,
  );
}

/// 上周整周支出（供环比；纯函数）.
int sumPrevWeekSpend({
  required List<DashboardFlow> flows,
  required DateTime now,
}) {
  final DateTime thisStart = weekStartFor(now);
  final DateTime prevStart = thisStart.subtract(const Duration(days: 7));
  int sum = 0;
  for (final DashboardFlow f in flows) {
    if (!f.occurredAt.isBefore(prevStart) && f.occurredAt.isBefore(thisStart)) {
      sum += f.amountFen;
    }
  }
  return sum;
}

/// 是否应自动生成（周一且本周未生成；lastGenerated 为已落库最新 weekStart，null=从未生成）.
bool shouldGenerateWeekly({required DateTime now, DateTime? lastGenerated}) {
  if (now.weekday != DateTime.monday) return false;
  final DateTime thisStart = weekStartFor(now);
  if (lastGenerated == null) return true;
  final DateTime lastStart = weekStartFor(lastGenerated);
  return lastStart.isBefore(thisStart);
}

/// 周报标题（得到框架）.
String weeklyTitle({required DateTime weekStart}) {
  final String m = weekStart.month.toString().padLeft(2, '0');
  final String d = weekStart.day.toString().padLeft(2, '0');
  return '周报 · $m-$d 起一周的底气';
}

/// 周报正文（得到框架；换算复用 describeSaving equivalentOf，不复制第二套）.
String weeklyBody({required int savedFen, required int spendFen}) {
  if (savedFen <= 0) {
    return '本周支出 ${formatFen(spendFen)} · 持平即是稳 · ${equivalentOf(spendFen)}';
  }
  return '本周省出 ${formatFen(savedFen)} · ${equivalentOf(savedFen)}';
}

/// 周报环比文案（得到框架；只陈述不劝阻）.
String weeklyMomText({required int momDeltaFen}) {
  if (momDeltaFen > 0) return '比上周多省 ${formatFen(momDeltaFen)}';
  if (momDeltaFen < 0) return '比上周多花 ${formatFen(-momDeltaFen)} · 整体仍在积累';
  return '与上周持平 · 稳步积累的证明';
}

/// Top3 文案（得到框架；空 Top 返回引导语）.
String weeklyTopText(List<WeeklyTop> top3) {
  if (top3.isEmpty) return '本周暂无支出构成';
  final String parts = top3
      .map((t) => '${t.category}${formatFen(t.fen)}')
      .join(' · ');
  return '支出 Top：$parts';
}

/// 本卡禁词复用成就表（不另建第二套；周报/安全垫文案零命中）.
List<String> get safetyBannedWords => achievementBannedWords;
