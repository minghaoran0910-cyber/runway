import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'budget_store.dart';
import 'import_batch.dart';

// schema：v1 Transactions / v2 Goals(SB-007) / v3 Achievements(SB-008)
// v4 SafetyPad+WeeklyReports(SB-009) / v5 PendingRecords(SB-010)
// v6 ImportBatches+tx.importBatchId(SB-011) / v7 Budgets(SB-015，卡内授权可回滚).
// 禁手改 schema，迁移走 drift；真实账目永不入库，测试合成 fixtures.

part 'app_db.g.dart';

/// schema v1：transactions（金额分/时间戳/类目/备注/来源）.
/// SB-011 v6 新增 importBatchId（可空；账单导入批次归属，整批撤销用）.
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amountFen => integer()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get category => text().withLength(min: 1, max: 32)();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  IntColumn get importBatchId => integer().nullable()();
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

/// schema v3：achievements（成就收藏序列；goalId 去重由逻辑层保证）.
/// tier 冗余目标档（ladderNameFor 推导）；unlockedAt 为达成落库时间（序列排序键）.
class Achievements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get goalId => integer()();
  TextColumn get goalName => text().withLength(min: 1, max: 32)();
  IntColumn get targetFen => integer()();
  IntColumn get convertibleFen => integer()();
  TextColumn get tier => text().withDefault(const Constant(''))();
  DateTimeColumn get unlockedAt => dateTime().withDefault(currentDateAndTime)();
}

/// schema v4：safety_pad（余粮配置；单行约定 id=1，targetMonths 默认 6）.
// SB-014：表名/列名保持不动（行为零变化，无迁移授权）；用户可见文案一律"余粮".
class SafetyPad extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get targetMonths => integer().withDefault(const Constant(6))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// schema v4：weekly_reports（周报缓存；weekStart 唯一由逻辑层保证，每周一生成）.
class WeeklyReports extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get weekStart => dateTime()();
  IntColumn get spendFen => integer().withDefault(const Constant(0))();
  IntColumn get incomeFen => integer().withDefault(const Constant(0))();
  IntColumn get savedFen => integer().withDefault(const Constant(0))();
  TextColumn get topJson => text().withDefault(const Constant(''))();
  IntColumn get momDeltaFen => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// schema v5：pending_records（待确认采集；notifyKey 去重由逻辑层保证）.
/// §5 原文零留存：本表只有结构化字段，禁止新增原文列（单测断言列名）.
class PendingRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amountFen => integer()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get category => text().withLength(min: 1, max: 32)();
  TextColumn get merchant => text().withLength(min: 1, max: 64)();
  TextColumn get sourcePkg => text().withDefault(const Constant(''))();
  TextColumn get notifyKey => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// schema v6 表定义见 data/import_batch.dart；v7 见 data/budget_store.dart（单文件 ≤400 行拆分）.
@DriftDatabase(
  tables: [
    Transactions,
    Goals,
    Achievements,
    SafetyPad,
    WeeklyReports,
    PendingRecords,
    ImportBatches,
    Budgets,
  ],
)
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
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    // v2 goals(SB-007)；v3 achievements(SB-008)；v4 safety+weekly(SB-009)；
    // v5 pending(SB-010)；v6 importbatch+列(SB-011)；v7 budgets(SB-015). 存量不动.
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(goals);
      }
      if (from < 3) {
        await m.createTable(achievements);
      }
      if (from < 4) {
        await m.createTable(safetyPad);
        await m.createTable(weeklyReports);
      }
      if (from < 5) {
        await m.createTable(pendingRecords);
      }
      if (from < 6) {
        await m.createTable(importBatches);
        await m.addColumn(transactions, transactions.importBatchId);
      }
      if (from < 7) {
        await m.createTable(budgets);
      }
    },
  );

  /// v6 回滚语义见 data/import_batch_dao.dart（单文件 ≤400 行拆分）.

  /// v5 回滚语义：删 pending_records 表即回 v4 形状（开发期回滚用）.
  Future<void> rollbackPendingToV4() async {
    await customStatement('DROP TABLE IF EXISTS pending_records');
  }

  /// v4 回滚语义：删 safety_pad + weekly_reports 即回 v3 形状（开发期回滚用）.
  Future<void> rollbackSafetyWeeklyToV3() async {
    await customStatement('DROP TABLE IF EXISTS safety_pad');
    await customStatement('DROP TABLE IF EXISTS weekly_reports');
  }

  /// v3 回滚语义：删 achievements 表即回到 v2 形状（开发期回滚用；线上走版本号）.
  Future<void> rollbackAchievementsToV2() async {
    await customStatement('DROP TABLE IF EXISTS achievements');
  }

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

  // —— Achievements DAO（SB-008；unlockedAt 倒序即收藏序列）——

  Future<List<Achievement>> listAchievements() {
    return (select(
      achievements,
    )..orderBy([(a) => OrderingTerm.desc(a.unlockedAt)])).get();
  }

  Stream<List<Achievement>> watchAchievements() {
    return (select(
      achievements,
    )..orderBy([(a) => OrderingTerm.desc(a.unlockedAt)])).watch();
  }

  Future<int> insertAchievement(AchievementsCompanion entry) {
    return into(achievements).insert(entry);
  }

  Future<int> deleteAchievement(int id) {
    return (delete(achievements)..where((a) => a.id.equals(id))).go();
  }

  // —— SafetyPad DAO（SB-009；单行约定 id=1，不存在即默认 6 个月）——

  Future<List<SafetyPadData>> listSafetyPad() {
    return (select(safetyPad)..orderBy([(s) => OrderingTerm.asc(s.id)])).get();
  }

  Future<SafetyPadData?> currentSafetyPad() async {
    final List<SafetyPadData> rows = await listSafetyPad();
    return rows.isEmpty ? null : rows.first;
  }

  Future<int> upsertSafetyMonths(int months) async {
    final SafetyPadData? cur = await currentSafetyPad();
    if (cur == null) {
      return into(safetyPad).insert(
        SafetyPadCompanion(
          targetMonths: Value(months),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
    await (update(safetyPad)..where((s) => s.id.equals(cur.id))).write(
      SafetyPadCompanion(
        targetMonths: Value(months),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return cur.id;
  }

  // —— WeeklyReports DAO（SB-009；weekStart 倒序即历史序列）——

  Future<List<WeeklyReport>> listWeeklyReports() {
    return (select(
      weeklyReports,
    )..orderBy([(w) => OrderingTerm.desc(w.weekStart)])).get();
  }

  Stream<List<WeeklyReport>> watchWeeklyReports() {
    return (select(
      weeklyReports,
    )..orderBy([(w) => OrderingTerm.desc(w.weekStart)])).watch();
  }

  Future<bool> weeklyExists(DateTime weekStart) async {
    final List<WeeklyReport> rows = await (select(
      weeklyReports,
    )..where((w) => w.weekStart.equals(weekStart))).get();
    return rows.isNotEmpty;
  }

  Future<int> insertWeeklyReport(WeeklyReportsCompanion entry) {
    return into(weeklyReports).insert(entry);
  }

  Future<int> deleteWeeklyReport(int id) {
    return (delete(weeklyReports)..where((w) => w.id.equals(id))).go();
  }

  // —— PendingRecords DAO（SB-010；createdAt 倒序即待确认序列）——

  Future<List<PendingRecord>> listPending() {
    return (select(
      pendingRecords,
    )..orderBy([(r) => OrderingTerm.desc(r.createdAt)])).get();
  }

  Stream<List<PendingRecord>> watchPending() {
    return (select(
      pendingRecords,
    )..orderBy([(r) => OrderingTerm.desc(r.createdAt)])).watch();
  }

  /// 幂等落库：同 notifyKey 已存在即返回既有 id（重复通知去重；风暴不丢不卡）.
  Future<int> insertPendingDedup(PendingRecordsCompanion entry) async {
    final String key = entry.notifyKey.value;
    if (key.isNotEmpty) {
      final List<PendingRecord> hit = await (select(
        pendingRecords,
      )..where((r) => r.notifyKey.equals(key))).get();
      if (hit.isNotEmpty) return hit.first.id;
    }
    return into(pendingRecords).insert(entry);
  }

  /// 一键入账：走 SB-004 transactions 通道（source 记 `notify`），再删待确认行.
  Future<int> confirmPending(PendingRecord row) async {
    final int id = await insertOne(
      TransactionsCompanion(
        amountFen: Value(row.amountFen),
        occurredAt: Value(row.occurredAt),
        category: Value(row.category),
        note: Value(row.merchant),
        source: const Value('notify'),
      ),
    );
    await deletePending(row.id);
    return id;
  }

  /// 批量确认（仅 UI 开关打开时调用；开关默认关，见 pending_page）.
  Future<int> confirmAllPending() async {
    final List<PendingRecord> rows = await listPending();
    for (final PendingRecord r in rows) {
      await confirmPending(r);
    }
    return rows.length;
  }

  Future<int> deletePending(int id) {
    return (delete(pendingRecords)..where((r) => r.id.equals(id))).go();
  }

  // SB-011 批次 DAO 见 import_batch_dao.dart（本文件保 ≤400 行）.
}
