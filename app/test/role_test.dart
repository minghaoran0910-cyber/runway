import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/data/category_role_dao.dart';
import 'package:runway/logic/achievement.dart';
import 'package:runway/logic/budget.dart';
import 'package:runway/logic/cooloff.dart';
import 'package:runway/logic/estimate.dart';
import 'package:runway/logic/role_resolver.dart';

// SB-019 · 角色轴单测（默认映射 / 覆盖优先 / 聚餐拆分 / 聚合口径 / 预算冷静联动 / DAO 幂等回滚）.

Map<String, CategoryRole> _overridesOf(Map<String, String> raw) {
  return <String, CategoryRole>{
    for (final MapEntry<String, String> e in raw.entries)
      e.key: parseRole(e.value)!,
  };
}

void main() {
  group('SB-019 默认映射（无未映射态）', () {
    test('食/行/用=必要，居=固定，玩/其他=弹性', () {
      expect(resolveRole('食'), CategoryRole.necessary);
      expect(resolveRole('行'), CategoryRole.necessary);
      expect(resolveRole('用'), CategoryRole.necessary);
      expect(resolveRole('居'), CategoryRole.fixed);
      expect(resolveRole('玩'), CategoryRole.flexible);
      expect(resolveRole('其他'), CategoryRole.flexible);
    });

    test('旧名先归一：餐饮/交通/购物/居住/娱乐走默认', () {
      expect(resolveRole('餐饮'), CategoryRole.necessary);
      expect(resolveRole('交通'), CategoryRole.necessary);
      expect(resolveRole('购物'), CategoryRole.necessary);
      expect(resolveRole('居住'), CategoryRole.fixed);
      expect(resolveRole('娱乐'), CategoryRole.flexible);
    });

    test('未知类目兜底弹性（永不 null）', () {
      expect(resolveRole('自建类'), CategoryRole.flexible);
      expect(resolveRole(''), CategoryRole.flexible);
      expect(resolveRole('  '), CategoryRole.flexible);
    });

    test('用户覆盖优先于默认，已有覆盖不动', () {
      final Map<String, CategoryRole> o = _overridesOf(<String, String>{
        '食': '弹性',
      });
      expect(resolveRole('食', o), CategoryRole.flexible);
      expect(resolveRole('行', o), CategoryRole.necessary);
      expect(isElasticCategory('食', o), isTrue);
      expect(isElasticCategory('行', o), isFalse);
    });
  });

  group('SB-019 角色编解码与校验', () {
    test('roleLabel/parseRole 互逆', () {
      for (final CategoryRole r in CategoryRole.values) {
        expect(parseRole(roleLabel(r)), r);
        expect(roleName(r), roleLabel(r));
      }
    });

    test('parseRole 未知返回 null', () {
      expect(parseRole(''), isNull);
      expect(parseRole('刚性'), isNull);
      expect(parseRole('elastic'), isNull);
    });

    test('validateRole：null/空/非法有错，三值合法', () {
      expect(validateRole(null), isNotNull);
      expect(validateRole(''), isNotNull);
      expect(validateRole('刚性'), isNotNull);
      expect(validateRole('必要'), isNull);
      expect(validateRole('弹性'), isNull);
      expect(validateRole('固定'), isNull);
    });
  });

  group('SB-019 聚餐拆分（只引导不强制）', () {
    test('食+聚餐=候选', () {
      expect(isDiningSplitCandidate(category: '食', note: '周五聚餐火锅'), isTrue);
      expect(isDiningSplitCandidate(category: '餐饮', note: '聚餐'), isTrue);
    });

    test('非食或无聚餐=非候选', () {
      expect(isDiningSplitCandidate(category: '玩', note: '聚餐'), isFalse);
      expect(isDiningSplitCandidate(category: '食', note: '外卖'), isFalse);
      expect(isDiningSplitCandidate(category: '食', note: ''), isFalse);
    });

    test('候选不改解析：食仍必要（不强制）', () {
      expect(resolveRole('食'), CategoryRole.necessary);
      expect(diningGuideText().contains('聚餐'), isTrue);
    });
  });

  group('SB-019 聚合口径', () {
    test('弹性占比：玩3000/食7000→30%', () {
      final RoleSummary s = summarizeRoles(<({int amountFen, String category})>[
        (amountFen: 7000, category: '食'),
        (amountFen: 3000, category: '玩'),
      ]);
      expect(s.totalFen, 10000);
      expect(s.elasticFen, 3000);
      expect(s.elasticShare, closeTo(0.3, 1e-9));
    });

    test('空输入 share=0 不 NaN', () {
      final RoleSummary s = summarizeRoles(
        <({int amountFen, String category})>[],
      );
      expect(s.totalFen, 0);
      expect(s.elasticFen, 0);
      expect(s.elasticShare, 0);
    });

    test('覆盖改写聚合：食覆弹性后全额弹性', () {
      final Map<String, CategoryRole> o = _overridesOf(<String, String>{
        '食': '弹性',
      });
      final RoleSummary s = summarizeRoles(<({int amountFen, String category})>[
        (amountFen: 5000, category: '食'),
      ], o);
      expect(s.elasticFen, 5000);
      expect(s.elasticShare, 1.0);
    });

    test('elasticShareText：零与正常两态', () {
      expect(elasticShareText(share: 0, elasticFen: 0), contains('0%'));
      final String t = elasticShareText(share: 0.3, elasticFen: 3000);
      expect(t, contains('30.0%'));
      expect(t, contains('本月弹性占比'));
    });
  });

  group('SB-019 预算联动（仅弹性进基线，原公式不动）', () {
    test('弹性过滤后中位数：总额含固定30000，弹性10000/20000/30000→预算19000', () {
      final List<({int amountFen, String category})> flows =
          <({int amountFen, String category})>[
            (amountFen: 10000, category: '玩'),
            (amountFen: 20000, category: '居'),
          ];
      final RoleSummary s = summarizeRoles(flows);
      expect(s.elasticFen, 10000);
      final BudgetQuote q = suggestBudget(
        m0Fen: 10000,
        m1Fen: 20000,
        m2Fen: 30000,
        dataMonths: 3,
      );
      expect(q.basis, BudgetBasis.median);
      expect(q.budgetFen, 19000);
    });

    test('固定大额不固化预算：居100000不进弹性基线', () {
      final RoleSummary s = summarizeRoles(<({int amountFen, String category})>[
        (amountFen: 100000, category: '居'),
        (amountFen: 8000, category: '玩'),
      ]);
      expect(s.elasticFen, 8000);
      expect(s.totalFen, 108000);
    });
  });

  group('SB-019 冷静联动（弹性日均×3，原公式不动）', () {
    test('阈值=弹性日均×3：固定 excluded', () {
      final DateTime now = DateTime(2026, 10, 11, 12);
      final List<CloseFlow> all = <CloseFlow>[
        CloseFlow(amountFen: 10000, occurredAt: now),
        CloseFlow(amountFen: 90000, occurredAt: now),
      ];
      final int avgAll = dailyAverage(flows: all, now: now);
      // 弹性只有 10000（玩），居 90000 不计.
      final List<CloseFlow> elastic = <CloseFlow>[
        CloseFlow(amountFen: 10000, occurredAt: now),
      ];
      final int avgElastic = dailyAverage(flows: elastic, now: now);
      expect(avgAll, 100000);
      expect(avgElastic, 10000);
      expect(
        cooloffThreshold(dailyAvgFen: avgElastic),
        avgElastic * defaultCooloffMultiple,
      );
    });

    test('自定义仍优先（联动不锁死）', () {
      expect(cooloffThreshold(dailyAvgFen: 10000, customFen: 50000), 50000);
    });
  });

  group('SB-019 DAO（迁移幂等 + 回滚）', () {
    test('ensureDefaultRoles 幂等：首轮补6，次轮0', () async {
      final AppDb db = AppDb.memoryForTest();
      final Map<String, String> defs = <String, String>{
        for (final MapEntry<String, CategoryRole> e
            in defaultCategoryRoles.entries)
          e.key: roleName(e.value),
      };
      expect(await db.ensureDefaultRoles(defs), 6);
      expect(await db.ensureDefaultRoles(defs), 0);
      expect((await db.listCategoryRoles()).length, 6);
      await db.close();
    });

    test('已有覆盖不动：食改弹性后迁移不覆盖', () async {
      final AppDb db = AppDb.memoryForTest();
      await db.setCategoryRole(category: '食', role: '弹性');
      final Map<String, String> defs = <String, String>{
        for (final MapEntry<String, CategoryRole> e
            in defaultCategoryRoles.entries)
          e.key: roleName(e.value),
      };
      await db.ensureDefaultRoles(defs);
      expect((await db.roleOverrideMap())['食'], '弹性');
      await db.close();
    });

    test('setCategoryRole 更新语义：插后改取最新', () async {
      final AppDb db = AppDb.memoryForTest();
      await db.setCategoryRole(category: '玩', role: '必要');
      expect((await db.roleOverrideMap())['玩'], '必要');
      await db.setCategoryRole(category: '玩', role: '弹性');
      expect((await db.roleOverrideMap())['玩'], '弹性');
      await db.close();
    });

    test('v11 回滚：删 role_overrides 即回 v10 形状', () async {
      final AppDb db = AppDb.memoryForTest();
      await db.setCategoryRole(category: '食', role: '必要');
      await db.rollbackCategoryRolesToV10();
      expect(() async => db.listCategoryRoles(), throwsA(isA<Exception>()));
      await db.close();
    });
  });

  group('SB-019 文案（得到框架，零禁词）', () {
    test('全部角色文案零禁词命中', () {
      final List<String> copies = <String>[
        elasticShareText(share: 0, elasticFen: 0),
        elasticShareText(share: 0.35, elasticFen: 3500),
        diningGuideText(),
        validateRole(null)!,
        for (final CategoryRole r in CategoryRole.values) roleLabel(r),
      ];
      expect(copies.length, greaterThanOrEqualTo(7));
      for (final String c in copies) {
        for (final String w in achievementBannedWords) {
          expect(c.contains(w), isFalse, reason: '文案命中禁词 $w：$c');
        }
      }
    });
  });
}
