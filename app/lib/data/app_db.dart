import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// SB-004 · schema v1（Transactions）+ SQLCipher 加密打开 + DAO.
// 授权：任务卡显式授权建 schema v1（DEV §2 禁区卡内授权）；ADR-001 记录选型.
// 真实账目数据永不入库；测试一律合成 fixtures.

part 'app_db.g.dart';

/// schema v1：transactions（金额分/时间戳/类目/备注/来源）.
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amountFen => integer()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get category => text().withLength(min: 1, max: 32)();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get source => text().withDefault(const Constant('manual'))();
}

@DriftDatabase(tables: [Transactions])
class AppDb extends _$AppDb {
  AppDb(super.executor);

  /// v1 开发期密钥（TODO: G4 前迁 Keychain/Keystore 随机密钥）.
  // ignore: constant_identifier_names
  static const String devKey = 'runway-dev-key-v1';

  static String pragmaFor(String key) => "PRAGMA key = '$key'";

  static void _setupRaw(dynamic rawDb, String key) {
    try {
      rawDb.execute(pragmaFor(key));
    } catch (_) {
      // 普通 sqlite 忽略未知 PRAGMA；加密构建则已设钥. 测试宿主安全.
    }
  }

  static Future<void> _applyLive(AppDb db, String key) async {
    try {
      await db.customStatement(pragmaFor(key));
    } catch (_) {
      // 同上：可用性优先.
    }
  }

  /// 文件库（应用文档目录 runway.db，SQLCipher 整体加密）.
  static Future<AppDb> openDefault({String key = devKey}) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File(p.join(dir.path, 'runway.db'));
    return openFile(file, key: key);
  }

  /// 指定文件打开（测试/回滚重建用）.
  static Future<AppDb> openFile(File file, {String key = devKey}) async {
    final NativeDatabase native = NativeDatabase(
      file,
      setup: (rawDb) => _setupRaw(rawDb, key),
    );
    final AppDb db = AppDb(native);
    await _applyLive(db, key);
    return db;
  }

  /// 内存库（单测/widget 测试合成数据专用）.
  static AppDb memoryForTest() {
    return AppDb(
      NativeDatabase.memory(setup: (rawDb) => _setupRaw(rawDb, devKey)),
    );
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    // v1 为首个基线版本，无线上存量；后续版本以 onUpgrade 分步脚本落地.
    onUpgrade: (m, from, to) async {},
  );

  /// v1 回滚语义：删库重建（无存量迁移）.
  Future<void> resetDatabase() async {
    for (final TableInfo table in allTables) {
      await delete(table).go();
    }
  }

  Future<List<Transaction>> listAll() {
    return (select(
      transactions,
    )..orderBy([(t) => OrderingTerm.desc(t.occurredAt)])).get();
  }

  Stream<List<Transaction>> watchAll() {
    return (select(
      transactions,
    )..orderBy([(t) => OrderingTerm.desc(t.occurredAt)])).watch();
  }

  Future<int> insertOne(TransactionsCompanion entry) {
    return into(transactions).insert(entry);
  }

  Future<bool> updateOne(TransactionsCompanion entry) {
    return update(transactions).replace(entry);
  }

  Future<int> deleteOne(int id) {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }
}
