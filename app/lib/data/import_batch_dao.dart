// SB-011 · 账单批次 DAO（AppDb 扩展；表定义见 import_batch.dart，迁移见 app_db.dart）.
// 去重键=日期天+金额分+对方（卡验收 2）；整批撤销删同 batchId 交易行（验收 2）.
// 性能：单次 listAll 建集 + batch 批量写，1 万行 <5s（验收 3）.

import 'package:drift/drift.dart';

import 'app_db.dart';
import 'import_batch.dart';

extension AppDbImportBatch on AppDb {
  Future<List<ImportBatch>> listImportBatches() {
    return (select(
      importBatches,
    )..orderBy([(b) => OrderingTerm.desc(b.createdAt)])).get();
  }

  Future<int> insertImportBatch(ImportBatchesCompanion entry) {
    return into(importBatches).insert(entry);
  }

  /// v6 回滚语义：删 import_batches 表并去列即回 v5 形状（开发期回滚用）.
  Future<void> rollbackImportToV5() async {
    await customStatement('DROP TABLE IF EXISTS import_batches');
    try {
      await customStatement(
        'ALTER TABLE transactions DROP COLUMN import_batch_id',
      );
    } catch (_) {
      // 老 sqlite 无 DROP COLUMN：退化为置空（形状等价，数据可弃）.
      try {
        await customStatement('UPDATE transactions SET import_batch_id = NULL');
      } catch (_) {}
    }
  }

  /// 整批撤销：删该批次导入的交易行，再删批次行；返回删除的交易行数.
  Future<int> revokeImportBatch(int batchId) async {
    final int n = await (delete(
      transactions,
    )..where((t) => t.importBatchId.equals(batchId))).go();
    await (delete(importBatches)..where((b) => b.id.equals(batchId))).go();
    return n;
  }

  /// 账单批量导入（含去重+批次登记）.
  /// 同一账单导入两次零重复：既有库同键 + 本批内同键一律跳过计 skippedDup.
  Future<({int batchId, int inserted, int skippedDup})> importBillBatch({
    required List<ImportCandidate> rows,
    String source = 'bill',
    String fileName = '',
    int failCount = 0,
  }) async {
    final List<Transaction> existing = await listAll();
    final Set<String> seen = <String>{
      for (final Transaction t in existing)
        txDedupKey(
          occurredAt: t.occurredAt,
          amountFen: t.amountFen,
          note: t.note,
        ),
    };
    final List<ImportCandidate> fresh = <ImportCandidate>[];
    int skippedDup = 0;
    for (final ImportCandidate r in rows) {
      if (seen.contains(r.dedupKey)) {
        skippedDup++;
        continue;
      }
      seen.add(r.dedupKey);
      fresh.add(r);
    }
    final int batchId = await insertImportBatch(
      ImportBatchesCompanion(
        source: Value(source),
        fileName: Value(fileName),
        rowCount: Value(rows.length),
        okCount: Value(fresh.length),
        failCount: Value(failCount),
      ),
    );
    await batch((Batch b) {
      for (final ImportCandidate r in fresh) {
        b.insert(
          transactions,
          TransactionsCompanion(
            amountFen: Value(r.amountFen),
            occurredAt: Value(r.occurredAt),
            category: Value(r.category),
            note: Value(r.counterparty),
            source: const Value('import'),
            importBatchId: Value(batchId),
          ),
        );
      }
    });
    return (batchId: batchId, inserted: fresh.length, skippedDup: skippedDup);
  }
}
