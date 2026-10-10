// SB-016 · 每日收口估算引擎（PRD §1 记账是手段 / §2 看见层；DESIGN §7 得到框架，纯 Dart）.
// 口径：
//   日均 = 近 30 天支出合计 / 覆盖天数（首笔至今，上限 30；空即 0，零编造）.
//   估算 = 日均 × 星期系数（周六 1.2 / 周日 1.15 / 工作日 1.0，下取整四舍五入）.
//   收口：今日无记录即问句；有真实记录估算让位（不问）；今日已有估算行即已记.
//   今日攒出 = max(0, 日预算 − 今日支出含估算)；日预算 = 月预算 / 当月天数，无预算回落日均.
//   今日攒出行：saved<=0 或换算不出（<最小单价）整行不出现；文案复用 SB-007 价格表，禁第二套公式，禁 1/N 记号.
// 本文件禁 import flutter（logic 不依赖 ui/flutter）.

import 'achievement.dart';
import 'entry.dart';
import 'goal_ladder.dart';

/// 收口输入流（UI 由 Transaction 转换；logic 不 import drift）.
class CloseFlow {
  const CloseFlow({
    required this.amountFen,
    required this.occurredAt,
    this.source = 'manual',
  });

  final int amountFen;
  final DateTime occurredAt;
  final String source;
}

/// 日期 key（daily_closes 表口径：YYYY-MM-DD）.
String dateKeyFor(DateTime t) {
  final String m = t.month.toString().padLeft(2, '0');
  final String d = t.day.toString().padLeft(2, '0');
  return '${t.year}-$m-$d';
}

bool _sameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// 星期系数（周末零碎偏高；工作日 1.0）.
double weekdayFactor(int weekday) {
  if (weekday == DateTime.saturday) return 1.2;
  if (weekday == DateTime.sunday) return 1.15;
  return 1.0;
}

/// 日均（近 30 天合计 / 覆盖天数；空输入=0，零编造）.
int dailyAverage({required List<CloseFlow> flows, required DateTime now}) {
  final DateTime start = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(const Duration(days: 29));
  int total = 0;
  DateTime? first;
  for (final CloseFlow f in flows) {
    final DateTime day = DateTime(
      f.occurredAt.year,
      f.occurredAt.month,
      f.occurredAt.day,
    );
    if (day.isBefore(start) ||
        day.isAfter(DateTime(now.year, now.month, now.day))) {
      continue;
    }
    total += f.amountFen;
    if (first == null || day.isBefore(first)) first = day;
  }
  if (total <= 0 || first == null) return 0;
  final int covered =
      DateTime(now.year, now.month, now.day).difference(first).inDays + 1;
  final int days = covered < 1 ? 1 : (covered > 30 ? 30 : covered);
  return total ~/ days;
}

/// 今日估算（日均 × 星期系数；日均<=0 即 0，调用方不问）.
int estimateToday({required int dailyAvgFen, required DateTime today}) {
  if (dailyAvgFen <= 0) return 0;
  return (dailyAvgFen * weekdayFactor(today.weekday)).round();
}

/// 今日记录（自然日）.
List<CloseFlow> todayFlowsOf(List<CloseFlow> flows, DateTime now) {
  return flows.where((f) => _sameDay(f.occurredAt, now)).toList();
}

/// 今日是否有真实记录（source != estimate 即真实；采集/手动都算真实）.
bool hasRealToday(List<CloseFlow> todayFlows) {
  for (final CloseFlow f in todayFlows) {
    if (f.source != 'estimate') return true;
  }
  return false;
}

/// 是否弹问句：今日零记录且今日未收口（已跳过/已记都不再问）；有真实记录估算让位.
bool shouldAskClose({
  required List<CloseFlow> todayFlows,
  required bool closedToday,
}) {
  if (closedToday) return false;
  if (todayFlows.isNotEmpty) return false;
  return true;
}

/// 今日支出合计（含估算）.
int todaySpendOf(List<CloseFlow> todayFlows) {
  int sum = 0;
  for (final CloseFlow f in todayFlows) {
    sum += f.amountFen;
  }
  return sum;
}

/// 当月天数.
int daysInMonthOf(DateTime now) {
  final DateTime firstNext = DateTime(now.year, now.month + 1, 1);
  return firstNext.subtract(const Duration(days: 1)).day;
}

/// 日预算（月预算 / 当月天数；无预算回落日均；纯函数）.
int dailyBudgetFor({
  required int monthBudgetFen,
  required DateTime now,
  int dailyAvgFen = 0,
}) {
  if (monthBudgetFen > 0) {
    return monthBudgetFen ~/ daysInMonthOf(now);
  }
  return dailyAvgFen;
}

/// 今日攒出（日预算 − 今日支出，钳零）.
int computeTodaySaved({
  required int dailyBudgetFen,
  required int todaySpendFen,
}) {
  final int v = dailyBudgetFen - todaySpendFen;
  return v > 0 ? v : 0;
}

/// 今日攒出行文案（null=整行不出现：saved<=0 或换算不出；复用 SB-007 价格表，禁第二套公式）.
/// 格式「今天攒出 ¥X · 够 N 杯奶茶」；只报整件，禁 1/N 记号.
String? todaySavedText({required int savedFen}) {
  if (savedFen <= 0) return null;
  PriceRef? hit;
  for (final PriceRef p in defaultPrices) {
    if (p.fen <= savedFen) hit = p;
  }
  if (hit == null) return null;
  final int count = savedFen ~/ hit.fen;
  if (count <= 0) return null;
  return '今天攒出 ¥${formatFen(savedFen)} · 够 $count ${cupUnit(hit.name)}${hit.name}';
}

/// 大额攒出（≥目标 5% 即达标线；调用方复用 SB-008 成就卡，禁新造动效）.
bool isBigDailySave({required int savedFen, required int targetFen}) {
  if (targetFen <= 0 || savedFen <= 0) return false;
  return savedFen * 20 >= targetFen;
}

/// 问句（得到框架；产品立场「不用每笔记」进文案）.
String closeAskText({required int estimateFen}) {
  return '今天零碎大约 ¥${formatFen(estimateFen)}，记？';
}

/// 已记态（得到框架；只报得到）.
String closeDoneText({required int todaySpendFen}) {
  return '今日已记 ¥${formatFen(todaySpendFen)} · 稳步积累的证明';
}

/// 跳过态（零打扰零负罪；禁词零命中）.
String closeSkipText() => '先不记 · 明天见';

/// 收口开关默认开（新库无行即开）.
const bool closeDefaultEnabled = true;

/// 领域校验：估算金额（分，须 >0）.
String? validateEstimateFen(int? fen) {
  if (fen == null || fen <= 0) return '金额须大于 0';
  if (fen > 100000000) return '金额过大';
  return null;
}

/// 本卡禁词复用成就表（不另建第二套；收口文案零命中）.
List<String> get closeBannedWords => achievementBannedWords;
