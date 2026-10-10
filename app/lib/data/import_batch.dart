// SB-011 · 账单批次表定义（schema v6；表+迁移见 app_db.dart，禁手改 schema）.
// 独立文件以满足 DEV §2 单文件 ≤400 行（app_db 主表文件单调增长，拆分经卡授权）.
// data 层纯结构，不依赖 logic 层.

import 'package:drift/drift.dart';

/// schema v6：import_batches（账单导入批次；整批撤销删 transactions 同 batchId 行）.
@DataClassName('ImportBatch')
class ImportBatches extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get source => text().withDefault(const Constant('bill'))();
  TextColumn get fileName => text().withDefault(const Constant(''))();
  IntColumn get rowCount => integer().withDefault(const Constant(0))();
  IntColumn get okCount => integer().withDefault(const Constant(0))();
  IntColumn get failCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// 账单导入候选（UI 层由 BillRow 映射；data 层纯结构）.
class ImportCandidate {
  ImportCandidate({
    required this.occurredAt,
    required this.amountFen,
    required this.category,
    required this.counterparty,
    required this.dedupKey,
  });

  final DateTime occurredAt;
  final int amountFen;
  final String category;
  final String counterparty;
  final String dedupKey;
}

/// 交易去重键（日期天+金额分+对方；与 logic/bill_import.billDedupKey 同口径）.
String txDedupKey({
  required DateTime occurredAt,
  required int amountFen,
  required String note,
}) {
  final String day =
      '${occurredAt.year.toString().padLeft(4, '0')}-'
      '${occurredAt.month.toString().padLeft(2, '0')}-'
      '${occurredAt.day.toString().padLeft(2, '0')}';
  return '$day|$amountFen|${note.trim()}';
}
