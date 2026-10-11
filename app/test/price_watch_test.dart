import 'package:flutter_test/flutter_test.dart';
import 'package:runway/logic/price_watch.dart';

// SB-020 单测：精确键/≥3 条才出/假阳性防护/中性文案/目标联动.

void main() {
  test('SB-020 同店同物同键（精确匹配）', () {
    expect(
      priceKeyFor(category: '食', note: '牛肉面'),
      priceKeyFor(category: '食', note: '牛肉面'),
    );
  });

  test('SB-020 商户不同即不合并', () {
    expect(
      priceKeyFor(category: '食', note: '牛肉面') ==
          priceKeyFor(category: '食', note: '炸酱面'),
      isFalse,
    );
  });

  test('SB-020 类目不同即不合并', () {
    expect(
      priceKeyFor(category: '食', note: '牛肉面') ==
          priceKeyFor(category: '玩', note: '牛肉面'),
      isFalse,
    );
  });

  test('SB-020 空备注无键（不合并所有空备注）', () {
    expect(priceKeyFor(category: '食', note: '   '), isNull);
  });

  test('SB-020 空类目无键', () {
    expect(priceKeyFor(category: '  ', note: '牛肉面'), isNull);
  });

  test('SB-020 ≥3 条出均价/最低/最近', () {
    final PriceStats? s = summarizePrices(
      key: '食｜牛肉面',
      amounts: <int>[2500, 2800, 3000],
    );
    expect(s, isNotNull);
    expect(s!.count, 3);
    expect(s.avgFen, (2500 + 2800 + 3000) ~/ 3);
    expect(s.minFen, 2500);
    expect(s.latestFen, 3000);
  });

  test('SB-020 <3 条不显示不猜', () {
    expect(summarizePrices(key: '食｜牛肉面', amounts: <int>[2500]), isNull);
    expect(summarizePrices(key: '食｜牛肉面', amounts: <int>[2500, 2800]), isNull);
    expect(summarizePrices(key: '食｜牛肉面', amounts: <int>[]), isNull);
  });

  test('SB-020 中位数联动（跟随取中位数）', () {
    final PriceStats? s = summarizePrices(
      key: '食｜牛肉面',
      amounts: <int>[3000, 2500, 2800],
    );
    expect(s!.medianFen, 2800);
  });

  test('SB-020 较均价陈述（+/-/持平，中性无说教）', () {
    expect(describeVsAvg(currentFen: 3000, avgFen: 2500), '较均价 +5');
    expect(describeVsAvg(currentFen: 2000, avgFen: 2500), '较均价 -5');
    expect(describeVsAvg(currentFen: 2500, avgFen: 2500), '与均价持平');
  });

  test('SB-020 目标联动：手动锁定优先', () {
    expect(resolveGoalPrice(manualPriceFen: 1800, followMedianFen: 2500), 1800);
  });

  test('SB-020 目标联动：无手动即跟随', () {
    expect(resolveGoalPrice(followMedianFen: 2500), 2500);
  });

  test('SB-020 目标联动：双空不猜', () {
    expect(resolveGoalPrice(), isNull);
  });

  test('SB-020 分组只收有键行', () {
    final Map<String, List<int>> g =
        groupByPriceKey(<({int amountFen, String category, String note})>[
          (amountFen: 2500, category: '食', note: '牛肉面'),
          (amountFen: 2800, category: '食', note: ''),
          (amountFen: 3000, category: '食', note: '牛肉面'),
        ]);
    expect(g.length, 1);
    expect(g['食｜牛肉面'], <int>[2500, 3000]);
  });
}
