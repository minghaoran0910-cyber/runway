// SB-016 · 每日收口 DAO（AppDb 扩展；表定义见 estimate_store.dart，迁移见 app_db.dart）.
// 今日收口 = 同 dateKey 最新行；开关无行即默认开.
// 回滚：删 daily_closes + close_prefs 即回 v7 形状（开发期回滚用）.

import 'package:drift/drift.dart';

import 'app_db.dart';

extension AppDbEstimate on AppDb {
  Future<List<DailyClose>> listCloses() {
    return (select(
      dailyCloses,
    )..orderBy([(c) => OrderingTerm.desc(c.id)])).get();
  }

  Future<List<DailyClose>> closesForDate(String dateKey) {
    return (select(dailyCloses)
          ..where((c) => c.dateKey.equals(dateKey))
          ..orderBy([(c) => OrderingTerm.desc(c.id)]))
        .get();
  }

  Stream<List<DailyClose>> watchClosesForDate(String dateKey) {
    return (select(dailyCloses)
          ..where((c) => c.dateKey.equals(dateKey))
          ..orderBy([(c) => OrderingTerm.desc(c.id)]))
        .watch();
  }

  Future<DailyClose?> closeOfDate(String dateKey) async {
    final List<DailyClose> rows = await closesForDate(dateKey);
    return rows.isEmpty ? null : rows.first;
  }

  Future<int> markClosed({
    required String dateKey,
    int estimateFen = 0,
    String status = 'done',
  }) {
    return into(dailyCloses).insert(
      DailyClosesCompanion(
        dateKey: Value(dateKey),
        estimateFen: Value(estimateFen),
        status: Value(status),
        createdAt: Value(DateTime.now()),
      ),
    );
  }

  Future<bool> closeEnabled() async {
    final List<ClosePref> rows = await (select(
      closePrefs,
    )..orderBy([(p) => OrderingTerm.asc(p.id)])).get();
    if (rows.isEmpty) return true;
    return rows.first.enabled;
  }

  Stream<bool> watchCloseEnabled() {
    return (select(closePrefs)..orderBy([(p) => OrderingTerm.asc(p.id)]))
        .watch()
        .map((List<ClosePref> rows) {
          if (rows.isEmpty) return true;
          return rows.first.enabled;
        });
  }

  Future<void> setCloseEnabled(bool enabled) async {
    final List<ClosePref> rows = await (select(
      closePrefs,
    )..orderBy([(p) => OrderingTerm.asc(p.id)])).get();
    if (rows.isEmpty) {
      await into(closePrefs).insert(
        ClosePrefsCompanion(
          enabled: Value(enabled),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return;
    }
    await (update(closePrefs)..where((p) => p.id.equals(rows.first.id))).write(
      ClosePrefsCompanion(
        enabled: Value(enabled),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// v8 回滚语义：删收口两表即回 v7 形状（开发期回滚用）.
  Future<void> rollbackEstimateToV7() async {
    await customStatement('DROP TABLE IF EXISTS daily_closes');
    await customStatement('DROP TABLE IF EXISTS close_prefs');
  }
}
