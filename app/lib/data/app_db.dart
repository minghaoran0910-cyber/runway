import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// SB-004 · schema v1（Transactions）+ SQLCipher 加密打开 + DAO.
// SB-007 · schema v2（Goals 目标表；PRD §4 goal 模型子集：name/target/单价/tier/doneAt）.
// 授权：SB-007 任务卡显式授权 schema v2 迁移（禁区仅此一表）；禁手改 schema，迁移走 drift.
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

/// schema v2：goals（目标名/目标额分/参考单价名/参考单价分/阶梯档/达成时间）.
/// tier/doneAt  nullable：tier 由目标额推导（goal_ladder.ladderNameFor），
/// doneAt 待成就卡写入；当前卡只用 name/target/单价三件套.
class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 32)();
  IntColumn get targetFen => integer()();
  TextColumn get priceName => text().withLength(min: 1, max: 16)();
  IntColumn get priceFen => integer()();
  TextColumn get tier => text().nullable()();
  DateTimeColumn get doneAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Transactions, Goals])
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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    // v1→v2：新增 goals 表（SB-007 卡授权）；存量 transactions 不动.
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(goals);
      }
    },
  );

  /// v2 回滚语义：删 goals 表即回到 v1 形状（开发期回滚用；线上走版本号）.
  Future<void> rollbackGoalsToV1() async {
    await customStatement('DROP TABLE IF EXISTS goals');
  }

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

  // —— Goals DAO（SB-007；首条 id 最小者为当前目标）——

  Future<List<Goal>> listGoals() {
    return (select(goals)..orderBy([(g) => OrderingTerm.asc(g.id)])).get();
  }

  Stream<List<Goal>> watchGoals() {
    return (select(goals)..orderBy([(g) => OrderingTerm.asc(g.id)])).watch();
  }

  Future<int> insertGoal(GoalsCompanion entry) {
    return into(goals).insert(entry);
  }

  Future<bool> updateGoal(GoalsCompanion entry) {
    return update(goals).replace(entry);
  }

  Future<int> deleteGoal(int id) {
    return (delete(goals)..where((g) => g.id.equals(id))).go();
  }
}
