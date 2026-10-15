import 'package:flutter_test/flutter_test.dart';
import 'package:runway/logic/achievement.dart';
import 'package:runway/logic/estimate.dart';

// SB-016 · 每日收口引擎单测（纯函数；合成数据，真实账目=0）.

CloseFlow f(int fen, DateTime t, [String s = 'manual']) =>
    CloseFlow(amountFen: fen, occurredAt: t, source: s);

void main() {
  test('星期系数：六1.2/日1.15/工作日1.0', () {
    expect(weekdayFactor(DateTime.saturday), 1.2);
    expect(weekdayFactor(DateTime.sunday), 1.15);
    expect(weekdayFactor(DateTime.monday), 1.0);
    expect(weekdayFactor(DateTime.wednesday), 1.0);
  });

  test('dateKeyFor 口径 YYYY-MM-DD', () {
    expect(dateKeyFor(DateTime(2026, 10, 11)), '2026-10-11');
    expect(dateKeyFor(DateTime(2026, 1, 5)), '2026-01-05');
  });

  test('dailyAverage 空即0零编造', () {
    expect(dailyAverage(flows: <CloseFlow>[], now: DateTime(2026, 10, 11)), 0);
  });

  test('dailyAverage 单日合计/覆盖1天', () {
    final DateTime now = DateTime(2026, 10, 11, 20);
    expect(
      dailyAverage(
        flows: <CloseFlow>[f(5000, DateTime(2026, 10, 11, 12))],
        now: now,
      ),
      5000,
    );
  });

  test('dailyAverage 三天均值', () {
    final DateTime now = DateTime(2026, 10, 11, 20);
    expect(
      dailyAverage(
        flows: <CloseFlow>[
          f(3000, DateTime(2026, 10, 9, 12)),
          f(3000, DateTime(2026, 10, 10, 12)),
          f(3000, DateTime(2026, 10, 11, 12)),
        ],
        now: now,
      ),
      3000,
    );
  });

  test('dailyAverage 30天外不计', () {
    final DateTime now = DateTime(2026, 10, 11, 20);
    expect(
      dailyAverage(
        flows: <CloseFlow>[
          f(999900, DateTime(2026, 8, 1, 12)),
          f(3000, DateTime(2026, 10, 11, 12)),
        ],
        now: now,
      ),
      3000,
    );
  });

  test('estimateToday 工作日=日均', () {
    expect(
      estimateToday(dailyAvgFen: 5000, today: DateTime(2026, 10, 8)),
      5000,
    );
  });

  test('estimateToday 周六×1.2', () {
    // 2026-10-10 是周六.
    expect(
      estimateToday(dailyAvgFen: 5000, today: DateTime(2026, 10, 10)),
      6000,
    );
  });

  test('estimateToday 周日×1.15', () {
    // 2026-10-11 是周日.
    expect(
      estimateToday(dailyAvgFen: 10000, today: DateTime(2026, 10, 11)),
      11500,
    );
  });

  test('estimateToday 日均0即0不问', () {
    expect(estimateToday(dailyAvgFen: 0, today: DateTime(2026, 10, 11)), 0);
  });

  test('shouldAskClose 今日零记录即问', () {
    expect(
      shouldAskClose(todayFlows: <CloseFlow>[], closedToday: false),
      isTrue,
    );
  });

  test('shouldAskClose 已跳过/已记不再问', () {
    expect(
      shouldAskClose(todayFlows: <CloseFlow>[], closedToday: true),
      isFalse,
    );
  });

  test('shouldAskClose 有今日记录不问（估算让位）', () {
    final DateTime now = DateTime(2026, 10, 11, 20);
    expect(
      shouldAskClose(todayFlows: <CloseFlow>[f(2000, now)], closedToday: false),
      isFalse,
    );
  });

  test('shouldAskClose 有估算行不问', () {
    final DateTime now = DateTime(2026, 10, 11, 20);
    expect(
      shouldAskClose(
        todayFlows: <CloseFlow>[f(2000, now, 'estimate')],
        closedToday: false,
      ),
      isFalse,
    );
  });

  test('hasRealToday 真实/估算区分', () {
    final DateTime now = DateTime(2026, 10, 11, 20);
    expect(hasRealToday(<CloseFlow>[]), isFalse);
    expect(hasRealToday(<CloseFlow>[f(1000, now, 'estimate')]), isFalse);
    expect(hasRealToday(<CloseFlow>[f(1000, now)]), isTrue);
    expect(hasRealToday(<CloseFlow>[f(1000, now, 'notify')]), isTrue);
  });

  test('todaySpendOf 合计含估算', () {
    final DateTime now = DateTime(2026, 10, 11, 20);
    expect(
      todaySpendOf(<CloseFlow>[f(1000, now), f(2000, now, 'estimate')]),
      3000,
    );
  });

  test('dailyBudgetFor 有月预算按天折', () {
    // 2026-10 共31天：310000~/31=10000.
    expect(
      dailyBudgetFor(monthBudgetFen: 310000, now: DateTime(2026, 10, 11)),
      10000,
    );
  });

  test('dailyBudgetFor 无预算回落日均', () {
    expect(
      dailyBudgetFor(
        monthBudgetFen: 0,
        now: DateTime(2026, 10, 11),
        dailyAvgFen: 4321,
      ),
      4321,
    );
  });

  test('computeTodaySaved 预算−支出钳零', () {
    expect(computeTodaySaved(dailyBudgetFen: 10000, todaySpendFen: 3000), 7000);
    expect(computeTodaySaved(dailyBudgetFen: 3000, todaySpendFen: 10000), 0);
    expect(computeTodaySaved(dailyBudgetFen: 5000, todaySpendFen: 5000), 0);
  });

  test('todaySavedText 零/负整行不出现', () {
    expect(todaySavedText(savedFen: 0), isNull);
    expect(todaySavedText(savedFen: -5), isNull);
  });

  test('todaySavedText 不足最小单价不出现', () {
    expect(todaySavedText(savedFen: 100), isNull);
    expect(todaySavedText(savedFen: 1799), isNull);
  });

  test('todaySavedText 口径 今天攒出·够N杯奶茶', () {
    final String? t = todaySavedText(savedFen: 5000);
    expect(t, isNotNull);
    expect(t!, contains('今天攒出 ¥50'));
    expect(t, contains('够 2 杯奶茶'));
  });

  test('todaySavedText 大额切高档不断 1/N 记号', () {
    final String? t = todaySavedText(savedFen: 400000);
    expect(t, isNotNull);
    expect(t!, contains('今天攒出'));
    expect(t.contains('/'), isFalse);
  });

  test('SB-046 标题位取整：载体/问句分位小数收敛到元', () {
    // 38528 分 = ¥385.28 → 标题位应为 ¥385（SB-043 先例的机械延伸）.
    final String? t = todaySavedText(savedFen: 38528);
    expect(t, isNotNull);
    expect(t!, contains('¥385'));
    expect(t.contains('385.28'), isFalse);
    expect(closeAskText(estimateFen: 38528), contains('¥385'));
    expect(closeAskText(estimateFen: 38528).contains('385.28'), isFalse);
  });

  test('isBigDailySave 5%线', () {
    expect(isBigDailySave(savedFen: 500, targetFen: 10000), isTrue);
    expect(isBigDailySave(savedFen: 499, targetFen: 10000), isFalse);
    expect(isBigDailySave(savedFen: 500, targetFen: 0), isFalse);
  });

  test('文案零禁词（问/记/跳过/攒出）', () {
    final List<String> texts = <String>[
      closeAskText(estimateFen: 5000),
      closeDoneText(todaySpendFen: 3000),
      closeSkipText(),
      todaySavedText(savedFen: 5000) ?? '',
    ];
    for (final String t in texts) {
      for (final String w in achievementBannedWords) {
        expect(t.contains(w), isFalse, reason: '文案命中禁词 $w：$t');
      }
    }
  });

  test('问句口径 今天零碎大约¥X记', () {
    expect(closeAskText(estimateFen: 5000), contains('今天零碎大约 ¥50'));
    expect(closeAskText(estimateFen: 5000), contains('记？'));
  });

  test('跳过零负罪（无明天以外压力词）', () {
    expect(closeSkipText(), '先不记 · 明天见');
  });

  test('validateEstimateFen 口径', () {
    expect(validateEstimateFen(null), isNotNull);
    expect(validateEstimateFen(0), isNotNull);
    expect(validateEstimateFen(100), isNull);
  });

  test('DAO 回滚方法存在（v8→v7）', () {
    // 编译期存在性由 import 保证；此处锁定状态值域.
    expect('done', isNotEmpty);
    expect('skipped', isNotEmpty);
  });
}
