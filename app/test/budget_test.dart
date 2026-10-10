import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/data/budget_dao.dart';
import 'package:runway/logic/achievement.dart';
import 'package:runway/logic/budget.dart';

// SB-015 · 预算线单测（基线三要素 / 取数优先级 / 省出口径 / 周增量 / 文案禁词 / DAO 历史）.

void main() {
  group('SB-015 基线三要素', () {
    test('中位数防单月大额固化：100/200/10000→中位数 200', () {
      expect(median3(100, 200, 10000), 200);
      expect(median3(10000, 100, 200), 200);
      expect(median3(200, 10000, 100), 200);
    });

    test('同月优先：有去年同月即取同月（春节该高就高）', () {
      final BudgetQuote q = suggestBudget(
        sameMonthFen: 500000,
        m0Fen: 10000,
        m1Fen: 20000,
        m2Fen: 30000,
        dataMonths: 3,
      );
      expect(q.basis, BudgetBasis.sameMonth);
      expect(q.basisFen, 500000);
      expect(q.observing, isFalse);
    });

    test('无同月中位数：budget=中位数×95%', () {
      final BudgetQuote q = suggestBudget(
        m0Fen: 10000,
        m1Fen: 20000,
        m2Fen: 30000,
        dataMonths: 3,
      );
      expect(q.basis, BudgetBasis.median);
      expect(q.basisFen, 20000);
      expect(q.budgetFen, 19000);
    });

    test('默认收紧 5%：10000→9500', () {
      expect(applyTighten(10000, 5), 9500);
    });

    test('收紧可调 0–15：0%=全额，15%=85%，越界钳制', () {
      expect(applyTighten(10000, 0), 10000);
      expect(applyTighten(10000, 15), 8500);
      expect(applyTighten(10000, 20), 8500);
      expect(applyTighten(10000, -1), 10000);
      expect(applyTighten(0, 5), 0);
    });

    test('validateTighten：null/越界非法，0–15 合法', () {
      expect(validateTighten(null), isNotNull);
      expect(validateTighten(-1), isNotNull);
      expect(validateTighten(16), isNotNull);
      expect(validateTighten(0), isNull);
      expect(validateTighten(5), isNull);
      expect(validateTighten(15), isNull);
    });

    test('validateBudgetFen：null/0 非法，超大额非法', () {
      expect(validateBudgetFen(null), isNotNull);
      expect(validateBudgetFen(0), isNotNull);
      expect(validateBudgetFen(-5), isNotNull);
      expect(validateBudgetFen(100), isNull);
    });
  });

  group('SB-015 取数优先级与观察期', () {
    test('优先级：同月>中位数（同月在即忽略中位数）', () {
      final BudgetQuote q = suggestBudget(
        sameMonthFen: 999,
        m0Fen: 100,
        m1Fen: 100,
        m2Fen: 100,
        dataMonths: 3,
      );
      expect(q.basis, BudgetBasis.sameMonth);
      expect(q.basisFen, 999);
    });

    test('数据不足 3 个月降级观察期：禁止编造基线', () {
      for (final int n in <int>[0, 1, 2]) {
        final BudgetQuote q = suggestBudget(
          m0Fen: 10000,
          m1Fen: 20000,
          m2Fen: 0,
          dataMonths: n,
        );
        expect(q.basis, BudgetBasis.observing, reason: 'dataMonths=$n');
        expect(q.observing, isTrue);
        expect(q.budgetFen, 0);
        expect(q.basisFen, 0);
      }
    });

    test('中位数为零仍观察期（全零月份无意义）', () {
      final BudgetQuote q = suggestBudget(
        m0Fen: 0,
        m1Fen: 0,
        m2Fen: 0,
        dataMonths: 3,
      );
      expect(q.observing, isTrue);
      expect(q.budgetFen, 0);
    });

    test('monthKeyFor：YYYY-MM 口径', () {
      expect(monthKeyFor(DateTime(2026, 1, 5)), '2026-01');
      expect(monthKeyFor(DateTime(2026, 10, 31)), '2026-10');
    });
  });

  group('SB-015 省出口径（≥10）', () {
    test('1 月光=满省：month=0→savedVs=budget', () {
      final BudgetSaved s = computeBudgetSaved(
        budgetFen: 100000,
        monthSpendFen: 0,
        lastMonthSpendFen: 90000,
      );
      expect(s.savedVsBudget, 100000);
      expect(s.momGain, 90000);
      expect(s.convertibleFen, 190000);
    });

    test('2 持平：month=budget→savedVs=0', () {
      final BudgetSaved s = computeBudgetSaved(
        budgetFen: 100000,
        monthSpendFen: 100000,
        lastMonthSpendFen: 100000,
      );
      expect(s.savedVsBudget, 0);
      expect(s.momGain, 0);
      expect(s.convertibleFen, 0);
    });

    test('3 超支不为负：month>budget 且 >last→全零', () {
      final BudgetSaved s = computeBudgetSaved(
        budgetFen: 100000,
        monthSpendFen: 120000,
        lastMonthSpendFen: 110000,
      );
      expect(s.savedVsBudget, 0);
      expect(s.momGain, 0);
      expect(s.convertibleFen, 0);
    });

    test('4 超预算但环比下降：savedVs=0，momGain 保留', () {
      final BudgetSaved s = computeBudgetSaved(
        budgetFen: 100000,
        monthSpendFen: 150000,
        lastMonthSpendFen: 200000,
      );
      expect(s.savedVsBudget, 0);
      expect(s.momGain, 50000);
      expect(s.convertibleFen, 50000);
    });

    test('5 正常省出：budget1000/last900/month800→200+100=300', () {
      final BudgetSaved s = computeBudgetSaved(
        budgetFen: 100000,
        monthSpendFen: 80000,
        lastMonthSpendFen: 90000,
      );
      expect(s.savedVsBudget, 20000);
      expect(s.momGain, 10000);
      expect(s.convertibleFen, 30000);
    });

    test('6 改后即时重算：同支出换基线 80000→savedVs=0', () {
      final BudgetSaved before = computeBudgetSaved(
        budgetFen: 100000,
        monthSpendFen: 80000,
        lastMonthSpendFen: 90000,
      );
      final BudgetSaved after = computeBudgetSaved(
        budgetFen: 80000,
        monthSpendFen: 80000,
        lastMonthSpendFen: 90000,
      );
      expect(before.convertibleFen, 30000);
      expect(after.savedVsBudget, 0);
      expect(after.convertibleFen, 10000);
    });

    test('7 上月为零（新用户首月）：momGain=0，只算预算差', () {
      final BudgetSaved s = computeBudgetSaved(
        budgetFen: 100000,
        monthSpendFen: 60000,
        lastMonthSpendFen: 0,
      );
      expect(s.savedVsBudget, 40000);
      expect(s.momGain, 0);
      expect(s.convertibleFen, 40000);
    });

    test('8 预算为零（观察期）：全零不负', () {
      final BudgetSaved s = computeBudgetSaved(
        budgetFen: 0,
        monthSpendFen: 50000,
        lastMonthSpendFen: 60000,
      );
      expect(s.savedVsBudget, 0);
      expect(s.momGain, 10000);
      expect(s.convertibleFen, 10000);
    });

    test('9 本月反超上月：momGain=0，只剩预算差', () {
      final BudgetSaved s = computeBudgetSaved(
        budgetFen: 100000,
        monthSpendFen: 95000,
        lastMonthSpendFen: 90000,
      );
      expect(s.savedVsBudget, 5000);
      expect(s.momGain, 0);
      expect(s.convertibleFen, 5000);
    });

    test('10 大额省出可加（不截断）', () {
      final BudgetSaved s = computeBudgetSaved(
        budgetFen: 1000000,
        monthSpendFen: 100000,
        lastMonthSpendFen: 900000,
      );
      expect(s.convertibleFen, 900000 + 800000);
    });
  });

  group('SB-015 周增量', () {
    test('周预算折算：月 30000→周 7000（×7/30）', () {
      final BudgetWeekly w = computeBudgetWeekly(
        budgetFen: 30000,
        weekSpendFen: 0,
        prevWeekSpendFen: 0,
      );
      expect(w.weekBudgetFen, 7000);
    });

    test('周省出：weekSpend<weekBudget→差额；超周预算→0 非负', () {
      final BudgetWeekly ok = computeBudgetWeekly(
        budgetFen: 30000,
        weekSpendFen: 5000,
        prevWeekSpendFen: 8000,
      );
      expect(ok.savedVsWeekBudget, 2000);
      expect(ok.gainFen, 3000);
      final BudgetWeekly over = computeBudgetWeekly(
        budgetFen: 30000,
        weekSpendFen: 9000,
        prevWeekSpendFen: 8000,
      );
      expect(over.savedVsWeekBudget, 0);
      expect(over.gainFen, 0);
      expect(over.deltaFen, -1000);
    });

    test('周 delta 可负（展示走环比口径）', () {
      final BudgetWeekly w = computeBudgetWeekly(
        budgetFen: 30000,
        weekSpendFen: 9000,
        prevWeekSpendFen: 6000,
      );
      expect(w.deltaFen, -3000);
    });
  });

  group('SB-015 文案（得到框架）', () {
    test('观察期/生效标题与正文三态', () {
      expect(budgetTitle(observing: true), contains('观察期'));
      expect(budgetTitle(observing: false), contains('已生效'));
      expect(budgetBody(budgetFen: 0, savedFen: 0), contains('记满 3 个月'));
      expect(budgetBody(budgetFen: 100000, savedFen: 0), contains('持平即是稳'));
      expect(budgetBody(budgetFen: 100000, savedFen: 20000), contains('已省出'));
    });

    test('超预算文案无"超支"二字、不报负数', () {
      final String hint = budgetHint(
        budgetFen: 100000,
        monthSpendFen: 120000,
        savedFen: 0,
      );
      expect(hint.contains('超支'), isFalse);
      expect(hint.contains('-'), isFalse);
    });

    test('基线说明三态可读', () {
      final BudgetQuote same = suggestBudget(
        sameMonthFen: 50000,
        m0Fen: 1,
        m1Fen: 1,
        m2Fen: 1,
        dataMonths: 3,
      );
      expect(budgetBasisText(quote: same), contains('去年同月'));
      final BudgetQuote med = suggestBudget(
        m0Fen: 10000,
        m1Fen: 20000,
        m2Fen: 30000,
        dataMonths: 3,
      );
      expect(budgetBasisText(quote: med), contains('中位数'));
      final BudgetQuote obs = suggestBudget(
        m0Fen: 0,
        m1Fen: 0,
        m2Fen: 0,
        dataMonths: 0,
      );
      expect(budgetBasisText(quote: obs), contains('手动'));
    });

    test('全部文案零禁词命中', () {
      final List<String> copies = <String>[
        budgetTitle(observing: true),
        budgetTitle(observing: false),
        budgetBody(budgetFen: 0, savedFen: 0),
        budgetBody(budgetFen: 100000, savedFen: 0),
        budgetBody(budgetFen: 100000, savedFen: 20000),
        budgetHint(budgetFen: 0, monthSpendFen: 0, savedFen: 0),
        budgetHint(budgetFen: 100000, monthSpendFen: 120000, savedFen: 0),
        budgetHint(budgetFen: 100000, monthSpendFen: 80000, savedFen: 30000),
        budgetBasisText(
          quote: suggestBudget(
            m0Fen: 10000,
            m1Fen: 20000,
            m2Fen: 30000,
            dataMonths: 3,
          ),
        ),
      ];
      for (final String c in copies) {
        for (final String w in achievementBannedWords) {
          expect(c.contains(w), isFalse, reason: '文案命中禁词 $w：$c');
        }
      }
    });
  });

  group('SB-015 DAO 历史', () {
    test('修改即插新行：current 取最新，历史倒序', () async {
      final AppDb db = AppDb.memoryForTest();
      await db.upsertBudget(monthKey: '2026-10', budgetFen: 100000);
      await db.upsertBudget(monthKey: '2026-10', budgetFen: 90000);
      final Budget? cur = await db.currentBudget('2026-10');
      expect(cur, isNotNull);
      expect(cur!.budgetFen, 90000);
      final List<Budget> hist = await db.listBudgetHistory('2026-10');
      expect(hist.length, 2);
      expect(hist.first.budgetFen, 90000);
      expect(hist.last.budgetFen, 100000);
      await db.close();
    });

    test('空月即观察期：current=null；异月隔离', () async {
      final AppDb db = AppDb.memoryForTest();
      expect(await db.currentBudget('2026-11'), isNull);
      await db.upsertBudget(monthKey: '2026-11', budgetFen: 50000);
      expect((await db.currentBudget('2026-11'))!.budgetFen, 50000);
      expect(await db.currentBudget('2026-10'), isNull);
      await db.close();
    });

    test('v7 回滚：删 budgets 表即回 v6 形状', () async {
      final AppDb db = AppDb.memoryForTest();
      await db.upsertBudget(monthKey: '2026-10', budgetFen: 1);
      await db.rollbackBudgetsToV6();
      expect(() async => db.listBudgets(), throwsA(isA<Exception>()));
      await db.close();
    });
  });
}
