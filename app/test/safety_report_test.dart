import 'package:drift/drift.dart' hide Column, isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/logic/dashboard_stats.dart';
import 'package:runway/logic/safety_report.dart';

// SB-009 · 安全垫与周报单测（合成数据，纯 Dart + DAO；≥14 条）.

DashboardFlow _f(int fen, DateTime t, [String c = '餐饮']) {
  return DashboardFlow(amountFen: fen, category: c, occurredAt: t);
}

void main() {
  test('SB-009 安全垫：目标=月均×月数，进度钳制', () {
    final SafetyPadView v = computeSafetyPad(
      avgMonthlySpendFen: 10000,
      fundFen: 30000,
      targetMonths: 6,
    );
    expect(v.targetFen, 60000);
    expect(v.progress, closeTo(0.5, 1e-9));
    expect(v.done, isFalse);
  });

  test('SB-009 安全垫：余额超目标即达成，目标<=0 不崩', () {
    final SafetyPadView v = computeSafetyPad(
      avgMonthlySpendFen: 10000,
      fundFen: 60000,
      targetMonths: 6,
    );
    expect(v.done, isTrue);
    expect(v.progress, 1.0);
    final SafetyPadView z = computeSafetyPad(
      avgMonthlySpendFen: 0,
      fundFen: 100,
      targetMonths: 6,
    );
    expect(z.targetFen, 0);
    expect(z.progress, 0);
    expect(z.done, isFalse);
  });

  test('SB-009 月数校验：默认 6 合法，区间 1–36', () {
    expect(validateSafetyMonths(6), isNull);
    expect(validateSafetyMonths(1), isNull);
    expect(validateSafetyMonths(36), isNull);
    expect(validateSafetyMonths(0), isNotNull);
    expect(validateSafetyMonths(37), isNotNull);
    expect(validateSafetyMonths(null), isNotNull);
    expect(defaultSafetyMonths, 6);
  });

  test('SB-009 月均：近 3 月求均，缺月按 0', () {
    expect(
      avg3MonthSpend(
        monthSpendFen: 3000,
        lastMonthSpendFen: 6000,
        last2MonthSpendFen: 9000,
      ),
      6000,
    );
    expect(
      avg3MonthSpend(
        monthSpendFen: 0,
        lastMonthSpendFen: 0,
        last2MonthSpendFen: 9000,
      ),
      3000,
    );
  });

  test('SB-009 三月汇总：自然月归位，跨年 1 月回 12 月', () {
    final DateTime now = DateTime(2026, 1, 15, 12);
    final sums = sumLast3MonthSpend(<({int amountFen, DateTime occurredAt})>[
      (amountFen: 100, occurredAt: DateTime(2026, 1, 5)),
      (amountFen: 200, occurredAt: DateTime(2025, 12, 5)),
      (amountFen: 300, occurredAt: DateTime(2025, 11, 5)),
      (amountFen: 999, occurredAt: DateTime(2025, 10, 5)),
    ], now);
    expect(sums.monthSpendFen, 100);
    expect(sums.lastMonthSpendFen, 200);
    expect(sums.last2MonthSpendFen, 300);
  });

  test('SB-009 文案：安全垫标题/正文/提示零禁词', () {
    final String t = safetyTitle(targetMonths: 6);
    final String b = safetyBody(fundFen: 30000, targetFen: 60000);
    final String h = safetyHint(fundFen: 30000, targetFen: 60000);
    for (final String bad in safetyBannedWords) {
      expect(t.contains(bad), isFalse, reason: '标题含禁词 $bad');
      expect(b.contains(bad), isFalse, reason: '正文含禁词 $bad');
      expect(h.contains(bad), isFalse, reason: '提示含禁词 $bad');
    }
    expect(t.contains('6'), isTrue);
    expect(h.contains('已攒'), isTrue);
  });

  test('SB-009 文案：达成态报底气，未记账给引导', () {
    expect(safetyHint(fundFen: 60000, targetFen: 60000), contains('已攒够安全垫'));
    expect(safetyBody(fundFen: 0, targetFen: 60000), contains('持平'));
    expect(safetyBody(fundFen: 100, targetFen: 0), contains('记满'));
  });

  test('SB-009 周起算：周一归零，周日归本周一', () {
    // 2026-10-05 为周一，2026-10-11 为周日.
    expect(weekStartFor(DateTime(2026, 10, 5, 15)), DateTime(2026, 10, 5));
    expect(weekStartFor(DateTime(2026, 10, 11, 15)), DateTime(2026, 10, 5));
    final range = weekRangeFor(DateTime(2026, 10, 7, 12));
    expect(range.start, DateTime(2026, 10, 5));
    expect(range.end, DateTime(2026, 10, 11));
  });

  test('SB-009 周报：本周聚合 + 省出=上周−本周钳零', () {
    final DateTime wed = DateTime(2026, 10, 7, 12);
    final WeeklyReportView v = computeWeekly(
      flows: <DashboardFlow>[
        _f(1000, DateTime(2026, 10, 6, 12), '餐饮'),
        _f(2000, DateTime(2026, 10, 7, 12), '交通'),
        _f(9999, DateTime(2026, 9, 20, 12), '购物'),
      ],
      now: wed,
      prevWeekSpendFen: 5000,
    );
    expect(v.spendFen, 3000);
    expect(v.savedFen, 2000);
    expect(v.momDeltaFen, 2000);
    expect(v.top3.length, 2);
    expect(v.top3.first.category, '行');
  });

  test('SB-009 周报：本周超上周则省出为 0，mom 为负', () {
    final WeeklyReportView v = computeWeekly(
      flows: <DashboardFlow>[_f(8000, DateTime(2026, 10, 7, 12))],
      now: DateTime(2026, 10, 7, 12),
      prevWeekSpendFen: 5000,
    );
    expect(v.savedFen, 0);
    expect(v.momDeltaFen, -3000);
    expect(weeklyMomText(momDeltaFen: v.momDeltaFen), contains('多花'));
  });

  test('SB-009 上周汇总：仅计上周一整周', () {
    final List<DashboardFlow> flows = <DashboardFlow>[
      _f(100, DateTime(2026, 10, 5, 12)),
      _f(200, DateTime(2026, 10, 11, 23)),
      _f(999, DateTime(2026, 10, 12, 12)),
      _f(999, DateTime(2026, 9, 27, 12)),
    ];
    // now=10-12（周一），上周=10-05~10-11.
    expect(
      sumPrevWeekSpend(flows: flows, now: DateTime(2026, 10, 12, 12)),
      300,
    );
  });

  test('SB-009 自动生成：仅周一且本周未生成', () {
    final DateTime mon = DateTime(2026, 10, 5, 9);
    expect(shouldGenerateWeekly(now: mon), isTrue);
    expect(
      shouldGenerateWeekly(now: mon, lastGenerated: DateTime(2026, 10, 5, 9)),
      isFalse,
    );
    expect(
      shouldGenerateWeekly(now: mon, lastGenerated: DateTime(2026, 9, 28, 9)),
      isTrue,
    );
    expect(shouldGenerateWeekly(now: DateTime(2026, 10, 7, 9)), isFalse);
  });

  test('SB-009 周报文案：标题/正文/环比/Top 零禁词', () {
    final String t = weeklyTitle(weekStart: DateTime(2026, 10, 5));
    final String b = weeklyBody(savedFen: 2000, spendFen: 3000);
    final String m = weeklyMomText(momDeltaFen: 2000);
    final String top = weeklyTopText(const <WeeklyTop>[
      WeeklyTop(category: '餐饮', fen: 1000),
    ]);
    for (final String bad in safetyBannedWords) {
      expect(t.contains(bad), isFalse);
      expect(b.contains(bad), isFalse);
      expect(m.contains(bad), isFalse);
      expect(top.contains(bad), isFalse);
    }
    expect(b.contains('省出'), isTrue);
  });

  test('SB-009 DAO：安全垫 upsert 单行 + 周报幂等', () async {
    final AppDb db = AppDb.memoryForTest();
    expect(await db.currentSafetyPad(), isNull);
    await db.upsertSafetyMonths(6);
    expect((await db.currentSafetyPad())?.targetMonths, 6);
    await db.upsertSafetyMonths(12);
    expect((await db.currentSafetyPad())?.targetMonths, 12);
    expect((await db.listSafetyPad()).length, 1);

    final DateTime ws = DateTime(2026, 10, 5);
    expect(await db.weeklyExists(ws), isFalse);
    await db.insertWeeklyReport(
      WeeklyReportsCompanion(
        weekStart: Value(ws),
        spendFen: const Value(3000),
        savedFen: const Value(2000),
        topJson: const Value('餐饮:1000'),
        momDeltaFen: const Value(2000),
      ),
    );
    expect(await db.weeklyExists(ws), isTrue);
    expect((await db.listWeeklyReports()).length, 1);
  });

  test('SB-009 schema v4：回滚删双表即回 v3 形状', () async {
    final AppDb db = AppDb.memoryForTest();
    await db.upsertSafetyMonths(6);
    expect(await db.currentSafetyPad(), isNotNull);
    await db.rollbackSafetyWeeklyToV3();
    bool threw = false;
    try {
      await db.currentSafetyPad();
    } catch (_) {
      threw = true;
    }
    expect(threw, isTrue);
    bool threw2 = false;
    try {
      await db.listWeeklyReports();
    } catch (_) {
      threw2 = true;
    }
    expect(threw2, isTrue);
    // 存量表不受影响.
    await db.insertOne(
      TransactionsCompanion(
        amountFen: const Value(100),
        occurredAt: Value(DateTime(2026, 10, 1)),
        category: const Value('餐饮'),
      ),
    );
    expect((await db.listAll()).length, 1);
  });
}
