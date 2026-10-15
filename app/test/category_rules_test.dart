import 'package:flutter_test/flutter_test.dart';
import 'package:runway/logic/category_feedback.dart';
import 'package:runway/logic/category_rules.dart';

// SB-005 · 规则引擎单测（合成数据；领域层纯 Dart，不碰 flutter/driver）.

void main() {
  group('SB-005 规则匹配（≥20 样例）', () {
    test('关键词样例全覆盖六类目', () {
      final List<({String note, int amountFen, String want})> cases =
          <({String note, int amountFen, String want})>[
            (note: '外卖午餐', amountFen: 2500, want: '食'),
            (note: '瑞幸咖啡', amountFen: 1800, want: '食'),
            (note: '沙县小吃', amountFen: 1500, want: '食'),
            (note: '盒马买菜', amountFen: 8600, want: '食'),
            (note: '滴滴打车', amountFen: 3200, want: '行'),
            (note: '高铁二等座', amountFen: 55300, want: '行'),
            (note: '哈啰单车', amountFen: 300, want: '行'),
            (note: '停车场缴费', amountFen: 1000, want: '行'),
            (note: '交房租', amountFen: 300000, want: '居'),
            (note: '物业费', amountFen: 25000, want: '居'),
            (note: '充宽带', amountFen: 120000, want: '居'),
            (note: '叫家政保洁', amountFen: 15000, want: '居'),
            (note: '爱奇艺会员', amountFen: 2500, want: '玩'),
            (note: 'KTV欢唱', amountFen: 20000, want: '玩'),
            (note: 'B站大会员', amountFen: 16800, want: '玩'),
            (note: '预订民宿', amountFen: 45000, want: '玩'),
            (note: '淘宝下单', amountFen: 9900, want: '用'),
            (note: '去理发店', amountFen: 5000, want: '用'),
            (note: '药店买药', amountFen: 4600, want: '用'),
            (note: '快递费', amountFen: 800, want: '用'),
            (note: '火星探险计划', amountFen: 100000, want: '其他'),
            (note: '未知事项xyz', amountFen: 100, want: '其他'),
          ];
      expect(cases.length, greaterThanOrEqualTo(20));
      for (final ({int amountFen, String note, String want}) c in cases) {
        expect(
          classifyTransaction(note: c.note, amountFen: c.amountFen),
          c.want,
          reason: '样例：${c.note}',
        );
      }
    });

    test('商户字段同口径匹配', () {
      expect(classifyTransaction(merchant: '星巴克'), '食');
      expect(classifyTransaction(merchant: 'DIDI', note: '出行'), '行');
    });

    test('金额区间消歧（苹果：小额食/大额用）', () {
      expect(classifyTransaction(note: '买苹果', amountFen: 3000), '食');
      expect(classifyTransaction(note: '买苹果', amountFen: 600000), '用');
    });
  });

  group('SB-005 纠正回写', () {
    test('纠正一次后同类自动生效（覆盖规则）', () {
      final CategoryCorrections corrections = CategoryCorrections();
      // 纠正前：无规则命中 → 其他.
      expect(classifyTransaction(note: '公司报销'), '其他');
      corrections.record(note: '公司报销', category: '用');
      expect(
        classifyTransaction(note: '公司报销', correctionLookup: corrections.lookup),
        '用',
      );
    });

    test('商户纠正优先于关键词规则', () {
      final CategoryCorrections corrections = CategoryCorrections();
      expect(classifyTransaction(merchant: '星巴克'), '食');
      corrections.record(merchant: '星巴克', category: '玩');
      expect(
        classifyTransaction(
          merchant: '星巴克',
          correctionLookup: corrections.lookup,
        ),
        '玩',
      );
    });

    test('键归一化（大小写/空格不敏感）', () {
      final CategoryCorrections corrections = CategoryCorrections();
      corrections.record(merchant: 'StarBucks', category: '用');
      expect(
        classifyTransaction(
          merchant: '  starbucks ',
          correctionLookup: corrections.lookup,
        ),
        '用',
      );
    });

    test('空键不存储', () {
      final CategoryCorrections corrections = CategoryCorrections();
      corrections.record(category: '食');
      expect(corrections.size, 0);
    });
  });

  group('SB-005 旧类目名兼容', () {
    test('六旧名映射到标准名', () {
      expect(canonicalCategory('餐饮'), '食');
      expect(canonicalCategory('交通'), '行');
      expect(canonicalCategory('居住'), '居');
      expect(canonicalCategory('娱乐'), '玩');
      expect(canonicalCategory('购物'), '用');
      expect(canonicalCategory('其他'), '其他');
    });

    test('标准名与未知名直通', () {
      expect(canonicalCategory('食'), '食');
      expect(canonicalCategory('自建类目'), '自建类目');
    });

    // SB-039 ① · 展示全称（引擎/存储短名不动，旧长名先归一再展示）.
    test('SB-039 展示名全称 + 自建直通', () {
      expect(categoryDisplayName('食'), '餐饮');
      expect(categoryDisplayName('行'), '交通');
      expect(categoryDisplayName('居'), '居住');
      expect(categoryDisplayName('玩'), '娱乐');
      expect(categoryDisplayName('用'), '日用');
      expect(categoryDisplayName('其他'), '其他');
      expect(categoryDisplayName('餐饮'), '餐饮');
      expect(categoryDisplayName('购物'), '日用');
      expect(categoryDisplayName('自建类目'), '自建类目');
    });
  });

  group('SB-005 其他占比', () {
    test('占比与故障阈值', () {
      final CategorySummary s = summarizeFlows(
        <({int amountFen, String category})>[
          (amountFen: 9000, category: '食'),
          (amountFen: 1000, category: '其他'),
        ],
      );
      expect(s.totalFen, 10000);
      expect(s.otherFen, 1000);
      expect(s.otherShare, closeTo(0.1, 1e-9));
      expect(s.otherFault, isTrue);
    });

    test('恰 5% 不算故障（严格大于）', () {
      final CategorySummary s = summarizeFlows(
        <({int amountFen, String category})>[
          (amountFen: 9500, category: '食'),
          (amountFen: 500, category: '其他'),
        ],
      );
      expect(s.otherShare, closeTo(0.05, 1e-9));
      expect(s.otherFault, isFalse);
    });

    test('空集合零占比不误报', () {
      final CategorySummary s = summarizeFlows(
        <({int amountFen, String category})>[],
      );
      expect(s.totalFen, 0);
      expect(s.otherShare, 0);
      expect(s.otherFault, isFalse);
    });

    test('旧名计入归一后类目', () {
      final CategorySummary s = summarizeFlows(
        <({int amountFen, String category})>[(amountFen: 500, category: '餐饮')],
      );
      expect(s.fenByCategory['食'], 500);
      expect(s.otherShare, 0);
    });
  });

  test('SB-005 性能：1 万条批量归类 <500ms（合成数据）', () {
    final List<String> notes = <String>[
      '外卖午餐',
      '滴滴打车',
      '交房租',
      '爱奇艺会员',
      '淘宝下单',
      '火星探险计划',
    ];
    final Stopwatch sw = Stopwatch()..start();
    for (int i = 0; i < 10000; i++) {
      classifyTransaction(note: notes[i % notes.length], amountFen: 1000 + i);
    }
    sw.stop();
    expect(sw.elapsedMilliseconds, lessThan(500));
  });
}
