import 'package:flutter_test/flutter_test.dart';
import 'package:runway/logic/goal_ladder.dart';

// SB-007 · 换算引擎单测（合成数据，纯 Dart；≥15 条口径样例）.

void main() {
  test('SB-007 内置单价表：奶茶/键盘/手机/5090 齐备且为正', () {
    expect(defaultPrices.length, greaterThanOrEqualTo(4));
    for (final PriceRef p in defaultPrices) {
      expect(p.name.isNotEmpty, isTrue);
      expect(p.fen, greaterThan(0));
    }
    expect(defaultPrices.first.name, '奶茶');
  });

  test('SB-007 校验：空名/目标<=0/空单价名/单价<=0 均报错', () {
    expect(
      validateGoal(name: '', targetFen: 100, priceName: '奶茶', priceFen: 1800),
      isNotNull,
    );
    expect(
      validateGoal(name: '攒手机', targetFen: 0, priceName: '奶茶', priceFen: 1800),
      isNotNull,
    );
    expect(
      validateGoal(
        name: '攒手机',
        targetFen: null,
        priceName: '奶茶',
        priceFen: 1800,
      ),
      isNotNull,
    );
    expect(
      validateGoal(name: '攺手机', targetFen: 100, priceName: '', priceFen: 1800),
      isNotNull,
    );
    expect(
      validateGoal(name: '攒手机', targetFen: 100, priceName: '奶茶', priceFen: 0),
      isNotNull,
    );
  });

  test('SB-007 校验：合法目标通过', () {
    expect(
      validateGoal(
        name: '攒手机',
        targetFen: 399900,
        priceName: '奶茶',
        priceFen: 1800,
      ),
      isNull,
    );
  });

  test('SB-007 口径：双项为正时相加（非绝对存款）', () {
    final GoalView v = computeGoal(
      monthSpendFen: 80000,
      lastMonthSpendFen: 100000,
      targetFen: 100000,
    );
    expect(v.savedVsBaseline, 20000);
    expect(v.momGain, 20000);
    expect(v.convertibleFen, 40000);
    expect(v.progress, closeTo(0.4, 1e-9));
    expect(v.done, isFalse);
  });

  test('SB-007 口径：本月超基线则该项钳零（不出现负省出）', () {
    final GoalView v = computeGoal(
      monthSpendFen: 120000,
      lastMonthSpendFen: 100000,
      baselineFen: 110000,
      targetFen: 100000,
    );
    expect(v.savedVsBaseline, 0);
    expect(v.momGain, 0);
    expect(v.convertibleFen, 0);
    expect(v.progress, 0);
  });

  test('SB-007 口径：自定义预算基线覆盖默认上月基线', () {
    final GoalView v = computeGoal(
      monthSpendFen: 80000,
      lastMonthSpendFen: 100000,
      baselineFen: 90000,
      targetFen: 100000,
    );
    expect(v.savedVsBaseline, 10000);
    expect(v.momGain, 20000);
    expect(v.convertibleFen, 30000);
  });

  test('SB-007 口径：全零输入不误报', () {
    final GoalView v = computeGoal(
      monthSpendFen: 0,
      lastMonthSpendFen: 0,
      targetFen: 100,
    );
    expect(v.convertibleFen, 0);
    expect(v.progress, 0);
    expect(v.done, isFalse);
  });

  test('SB-007 月光月：基线花光但环比增量仍省出一杯奶茶', () {
    const PriceRef tea = PriceRef(name: '奶茶', fen: 1800);
    final GoalView v = computeGoal(
      monthSpendFen: 98000,
      lastMonthSpendFen: 100000,
      targetFen: 399900,
    );
    expect(v.savedVsBaseline, 2000);
    expect(v.momGain, 2000);
    expect(v.convertibleFen, 4000);
    final String copy = describeSaving(
      convertibleFen: v.convertibleFen,
      price: tea,
    );
    expect(copy.contains('省出 2 杯奶茶'), isTrue);
  });

  test('SB-007 文案：零省出为持平期得到表述（零亏欠词）', () {
    const PriceRef tea = PriceRef(name: '奶茶', fen: 1800);
    final String copy = describeSaving(convertibleFen: 0, price: tea);
    expect(copy.contains('持平'), isTrue);
    expect(copy.contains('第一杯奶茶'), isTrue);
    for (final String bad in <String>['又花掉', '只剩', '还差', '超支']) {
      expect(copy.contains(bad), isFalse);
    }
  });

  test('SB-007 文案：不足一件报已攺+继续攺（不用"还差"）', () {
    const PriceRef tea = PriceRef(name: '奶茶', fen: 1800);
    final String copy = describeSaving(convertibleFen: 1000, price: tea);
    expect(copy.contains('已攒'), isTrue);
    expect(copy.contains('继续攒'), isTrue);
    expect(copy.contains('还差'), isFalse);
  });

  test('SB-007 文案：多杯带余数下一杯进度', () {
    const PriceRef tea = PriceRef(name: '奶茶', fen: 1800);
    final String copy = describeSaving(convertibleFen: 4000, price: tea);
    expect(copy.contains('省出 2 杯奶茶'), isTrue);
    expect(copy.contains('下一杯'), isTrue);
  });

  test('SB-007 文案：整杯无余数不追加', () {
    const PriceRef tea = PriceRef(name: '奶茶', fen: 1800);
    final String copy = describeSaving(convertibleFen: 3600, price: tea);
    expect(copy, '本周省出 2 杯奶茶');
  });

  test('SB-007 大额：只陈述不劝阻', () {
    final String big = equivalentOf(399900 + 1800);
    expect(big.contains('手机'), isTrue);
    for (final String bad in <String>['别买', '不该', '忍住', '建议']) {
      expect(big.contains(bad), isFalse);
    }
    expect(equivalentOf(100), '稳步积累中');
  });

  test('SB-007 阶梯：目标额归档（奶茶→手机→5090→安全垫）', () {
    expect(ladderNameFor(1800), '奶茶');
    expect(ladderNameFor(500000), '手机');
    expect(ladderNameFor(2000000), '5090');
    expect(ladderNameFor(7000000), '安全垫');
    expect(ladderNameFor(30000000), '自由基金');
  });

  test('SB-007 下一站：得到框架进度提示', () {
    final String hint = nextLadderHint(
      convertibleFen: 20000,
      targetFen: 399900,
    );
    expect(hint.contains('下一站'), isTrue);
    expect(hint.contains('已攒'), isTrue);
    expect(hint.contains('还差'), isFalse);
  });

  test('SB-007 进度：钳制 0..1 + 达成态', () {
    final GoalView over = computeGoal(
      monthSpendFen: 0,
      lastMonthSpendFen: 100000,
      targetFen: 1000,
    );
    expect(over.progress, 1.0);
    expect(over.done, isTrue);
    final GoalView none = computeGoal(
      monthSpendFen: 50000,
      lastMonthSpendFen: 100000,
    );
    expect(none.progress, 0);
    expect(none.done, isFalse);
  });

  test('SB-007 量词：奶茶按杯、手机按件', () {
    expect(cupUnit('奶茶'), '杯');
    expect(cupUnit('手机'), '件');
  });
}
