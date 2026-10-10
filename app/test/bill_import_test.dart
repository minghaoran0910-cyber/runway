import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/data/app_db.dart';
import 'package:runway/data/import_batch.dart';
import 'package:runway/data/import_batch_dao.dart';
import 'package:runway/logic/bill_import.dart';

// SB-011 单测：支付宝/微信合成 fixture 解析 + 失败行报告 + 去重 + 撤销 +
// 缓存即删 + 1 万行性能 + 无原文列断言. 测试一律合成数据，真账目永不入库.

const String _alipayCsv =
    '交易时间,交易分类,交易对方,对方账号,商品说明,收/支,金额,收/付款方式,交易状态,交易订单号\n'
    '2026-09-01 12:34:56,餐饮美食,测试小吃店,acc1,午餐,支出,25.50,余额宝,交易成功,ALI001\n'
    '2026-09-01 18:20:00,交通出行,测试地铁,acc2,地铁,支出,4.00,余额宝,交易成功,ALI002\n'
    '2026-09-02 09:00:00,餐饮美食,测试包子铺,acc3,早餐,支出,,余额宝,交易成功,ALI003\n'
    '2026-09-02 10:00:00,退款,测试小吃店,acc1,退款,收入,25.50,余额宝,退款成功,ALI004\n'
    '2026-09-02 11:00:00,餐饮美食,测试面馆,acc4,拉面,支出,18.00,余额宝,交易关闭,ALI005\n';

const String _wechatCsv =
    '交易时间,交易类型,交易对方,商品,收/支,金额(元),支付方式,当前状态,交易单号\n'
    '2026-09-03 08:10:00,商户消费,测试咖啡馆,拿铁,支出,￥32.00,零钱,支付成功,WX001\n'
    '2026-09-03 20:00:00,商户消费,,奶茶,支出,15.00,零钱,支付成功,WX002\n';

List<ImportCandidate> _toCands(BillParseResult r) => <ImportCandidate>[
  for (final BillRow row in r.rows)
    ImportCandidate(
      occurredAt: row.occurredAt,
      amountFen: row.amountFen,
      category: row.category,
      counterparty: row.counterparty,
      dedupKey: row.dedupKey,
    ),
];

void main() {
  test('SB-011 支付宝 fixture：解析正确+失败行给行号原因', () {
    final BillParseResult r = parseBillCsv(_alipayCsv);
    // 成功 3（ALI001/002/004），失败 2（第 4 行金额无效/第 6 行非成功状态）.
    expect(r.rows.length, 3);
    expect(r.failures.length, 2);
    expect(r.failures[0].lineNo, 4);
    expect(r.failures[0].reason, contains('金额无效'));
    expect(r.failures[1].lineNo, 6);
    expect(r.failures[1].reason, contains('非成功状态'));
    final BillRow first = r.rows.firstWhere(
      (BillRow x) => x.counterparty == '测试小吃店' && x.amountFen == 2550,
    );
    expect(first.occurredAt.year, 2026);
    expect(first.occurredAt.month, 9);
    expect(first.occurredAt.day, 1);
    expect(first.category, '食');
    final BillRow metro = r.rows.firstWhere(
      (BillRow x) => x.counterparty == '测试地铁',
    );
    expect(metro.amountFen, 400);
    expect(metro.category, '行');
    // 去重键口径：日期天+金额分+对方.
    expect(
      first.dedupKey,
      billDedupKey(
        occurredAt: first.occurredAt,
        amountFen: 2550,
        counterparty: '测试小吃店',
      ),
    );
  });

  test('SB-011 微信 fixture：￥金额单位+对方为空失败行', () {
    final BillParseResult r = parseBillCsv(_wechatCsv);
    expect(r.rows.length, 1);
    expect(r.failures.length, 1);
    expect(r.failures.single.lineNo, 3);
    expect(r.failures.single.reason, contains('对方为空'));
    expect(r.rows.single.amountFen, 3200);
    expect(r.rows.single.category, '食');
    expect(r.rows.single.occurredAt.hour, 8);
  });

  test('SB-011 去重：同一账单导入两次零重复', () async {
    final AppDb db = AppDb.memoryForTest();
    addTearDown(db.close);
    final BillParseResult r = parseBillCsv(_alipayCsv);
    final List<ImportCandidate> cands = _toCands(r);
    final ({int batchId, int inserted, int skippedDup}) rep1 = await db
        .importBillBatch(rows: cands, fileName: 'a.csv');
    expect(rep1.inserted, 3);
    expect(rep1.skippedDup, 0);
    final ({int batchId, int inserted, int skippedDup}) rep2 = await db
        .importBillBatch(rows: cands, fileName: 'a.csv');
    expect(rep2.inserted, 0);
    expect(rep2.skippedDup, 3);
    expect((await db.listAll()).length, 3);
    // 落库备注=对方名，非原文整行（§5 不留原文）.
    for (final Transaction t in await db.listAll()) {
      expect(t.note.contains(','), isFalse);
      expect(t.source, 'import');
      expect(t.importBatchId, rep1.batchId);
    }
  });

  test('SB-011 批次级整体撤销', () async {
    final AppDb db = AppDb.memoryForTest();
    addTearDown(db.close);
    final BillParseResult r = parseBillCsv(_alipayCsv);
    final ({int batchId, int inserted, int skippedDup}) rep = await db
        .importBillBatch(rows: _toCands(r), fileName: 'a.csv');
    expect((await db.listAll()).length, 3);
    expect((await db.listImportBatches()).length, 1);
    final int n = await db.revokeImportBatch(rep.batchId);
    expect(n, 3);
    expect(await db.listAll(), isEmpty);
    expect(await db.listImportBatches(), isEmpty);
  });

  test('SB-011 原文件不留副本：缓存读后即删', () async {
    final Directory tmp = await Directory.systemTemp.createTemp('sb011');
    addTearDown(() => tmp.delete(recursive: true));
    final File f = File('${tmp.path}/bill.csv');
    await f.writeAsString(_wechatCsv);
    final ({bool deleted, BillParseResult result}) out = await importBillFile(
      f,
    );
    expect(out.result.rows.length, 1);
    expect(out.deleted, isTrue);
    expect(await f.exists(), isFalse);
  });

  test('SB-011 性能：1 万行解析+入库 <5s（合成数据）', () async {
    final StringBuffer sb = StringBuffer(
      '交易时间,交易分类,交易对方,对方账号,商品说明,收/支,金额,收/付款方式,交易状态,交易订单号\n',
    );
    for (int i = 0; i < 10000; i++) {
      final int day = 1 + (i % 28);
      final int amt = (i % 5000) + 1;
      sb.writeln(
        '2026-08-${day.toString().padLeft(2, '0')} 10:00:00,测试,压测商户$i,acc,午餐,支出,${amt ~/ 100}.${(amt % 100).toString().padLeft(2, '0')},余额宝,交易成功,P$i',
      );
    }
    final AppDb db = AppDb.memoryForTest();
    addTearDown(db.close);
    final Stopwatch sw = Stopwatch()..start();
    final BillParseResult r = parseBillCsv(sb.toString());
    final int parseMs = sw.elapsedMilliseconds;
    expect(r.rows.length, 10000);
    expect(r.failures, isEmpty);
    final ({int batchId, int inserted, int skippedDup}) rep = await db
        .importBillBatch(rows: _toCands(r), fileName: 'perf.csv');
    sw.stop();
    expect(rep.inserted, 10000);
    // ignore: avoid_print
    print(
      'SB-011 perf: parse=${parseMs}ms total=${sw.elapsedMilliseconds}ms rows=10000',
    );
    expect(sw.elapsedMilliseconds, lessThan(5000));
  });

  test('SB-011 无原文列：批次表列名断言', () {
    final Map<String, dynamic> cols = ImportBatchesCompanion(
      source: const Value('bill'),
      fileName: const Value('x'),
    ).toColumns(false);
    for (final String name in cols.keys) {
      expect(
        RegExp(
          'raw|content|body|text|message',
          caseSensitive: false,
        ).hasMatch(name),
        isFalse,
        reason: '原文列嫌疑：$name',
      );
    }
  });
}
