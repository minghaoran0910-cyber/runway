import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/logic/entry.dart';

// SB-004 · 领域层单测 + DAO CRUD（合成数据，内存库）.

void main() {
  group('SB-004 金额解析（分）', () {
    test('常规输入', () {
      expect(parseAmountToFen('12'), 1200);
      expect(parseAmountToFen('12.34'), 1234);
      expect(parseAmountToFen('0.5'), 50);
      expect(parseAmountToFen(' 9.9 '), 990);
    });

    test('非法输入拒收', () {
      expect(parseAmountToFen(''), isNull);
      expect(parseAmountToFen('0'), isNull);
      expect(parseAmountToFen('0.00'), isNull);
      expect(parseAmountToFen('-5'), isNull);
      expect(parseAmountToFen('12.345'), isNull);
      expect(parseAmountToFen('abc'), isNull);
      expect(parseAmountToFen('12..34'), isNull);
    });

    test('格式化回显', () {
      expect(formatFen(1200), '12');
      expect(formatFen(1234), '12.34');
      expect(formatFen(50), '0.5');
    });

    test('SB-033 千分位全局统一：0/4位/5位/负数/极值', () {
      expect(formatFen(0), '0');
      expect(formatFen(123400), '1,234');
      expect(formatFen(3612000), '36,120');
      expect(formatFen(123456), '1,234.56');
      expect(formatFen(-123400), '-1,234');
      expect(formatFen(100000000), '1,000,000');
    });
  });

  group('SB-004 领域校验', () {
    test('合法草稿', () {
      expect(validateEntry(amountFen: 1200, category: '餐饮', note: ''), isNull);
    });

    test('金额/类目/备注边界', () {
      expect(validateEntry(amountFen: 0, category: '餐饮', note: ''), isNotNull);
      expect(
        validateEntry(amountFen: null, category: '餐饮', note: ''),
        isNotNull,
      );
      expect(validateEntry(amountFen: 100, category: '', note: ''), isNotNull);
      expect(
        validateEntry(amountFen: 100, category: 'x' * 33, note: ''),
        isNotNull,
      );
      expect(
        validateEntry(amountFen: 100, category: '餐饮', note: 'x' * 201),
        isNotNull,
      );
    });
  });

  group('SB-004 DAO CRUD（内存库合成数据）', () {
    late AppDb db;

    setUp(() {
      db = AppDb.memoryForTest();
    });

    tearDown(() async {
      await db.close();
    });

    test('增查改删全链路', () async {
      final int id = await db.insertOne(
        TransactionsCompanion(
          amountFen: const Value(1234),
          occurredAt: Value(DateTime(2026, 10, 1, 12)),
          category: const Value('餐饮'),
          note: const Value('合成午餐'),
          source: const Value('manual'),
        ),
      );
      List<Transaction> rows = await db.listAll();
      expect(rows.length, 1);
      expect(rows.first.amountFen, 1234);
      expect(rows.first.category, '餐饮');

      await db.updateOne(
        TransactionsCompanion(
          id: Value(id),
          amountFen: const Value(2000),
          occurredAt: Value(DateTime(2026, 10, 1, 12)),
          category: const Value('交通'),
          note: const Value('合成地铁'),
          source: const Value('manual'),
        ),
      );
      rows = await db.listAll();
      expect(rows.first.amountFen, 2000);
      expect(rows.first.category, '交通');

      await db.deleteOne(id);
      rows = await db.listAll();
      expect(rows, isEmpty);
    });

    test('resetDatabase 回滚=清空重建', () async {
      await db.insertOne(
        TransactionsCompanion(
          amountFen: const Value(500),
          occurredAt: Value(DateTime(2026, 10, 2)),
          category: const Value('其他'),
        ),
      );
      expect((await db.listAll()).length, 1);
      await db.resetDatabase();
      expect(await db.listAll(), isEmpty);
      // 重建后仍可写（回滚可用）.
      await db.insertOne(
        TransactionsCompanion(
          amountFen: const Value(600),
          occurredAt: Value(DateTime(2026, 10, 3)),
          category: const Value('购物'),
        ),
      );
      expect((await db.listAll()).length, 1);
    });
  });
}
