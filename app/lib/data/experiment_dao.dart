// SB-018 · 月度小实验 DAO（AppDb 扩展；表定义见 experiment_store.dart）.
// 打卡同天幂等（checkIns 逗号集，去重追加）；建单前完结旧 active（同月只一单）.
// 回滚：删 experiments + experiment_prefs 即回 v9 形状（开发期回滚用）.

import 'package:drift/drift.dart';

import 'app_db.dart';

/// checkIns 序列化（"0,2,5"；空即 ''，解析失败即空集）.
String encodeCheckIns(Set<int> days) {
  final List<int> sorted = days.toList()..sort();
  return sorted.join(',');
}

Set<int> decodeCheckIns(String raw) {
  if (raw.trim().isEmpty) return <int>{};
  final Set<int> out = <int>{};
  for (final String part in raw.split(',')) {
    final int? v = int.tryParse(part.trim());
    if (v == null || v < 0 || v >= 7) continue;
    out.add(v);
  }
  return out;
}

extension AppDbExperiment on AppDb {
  Future<List<Experiment>> listExperiments() {
    return (select(
      experiments,
    )..orderBy([(e) => OrderingTerm.desc(e.id)])).get();
  }

  Stream<List<Experiment>> watchExperiments() {
    return (select(
      experiments,
    )..orderBy([(e) => OrderingTerm.desc(e.id)])).watch();
  }

  Future<Experiment?> activeExperiment() async {
    final List<Experiment> rows =
        await (select(experiments)
              ..where((e) => e.status.equals('active'))
              ..orderBy([(e) => OrderingTerm.desc(e.id)]))
            .get();
    return rows.isEmpty ? null : rows.first;
  }

  /// 建单（先完结旧 active；返回新 id）.
  Future<int> startExperiment({
    required String templateId,
    required String name,
    required int dailySaveFen,
    required DateTime startDate,
  }) async {
    final Experiment? old = await activeExperiment();
    if (old != null) {
      await (update(experiments)..where((e) => e.id.equals(old.id))).write(
        ExperimentsCompanion(status: const Value('done')),
      );
    }
    return into(experiments).insert(
      ExperimentsCompanion(
        templateId: Value(templateId),
        name: Value(name),
        dailySaveFen: Value(dailySaveFen),
        startDate: Value(startDate),
      ),
    );
  }

  /// 打卡（同天幂等；返回 true=新增，false=已打过）.
  Future<bool> checkInExperiment({
    required int id,
    required int dayIndex,
  }) async {
    if (dayIndex < 0 || dayIndex >= 7) return false;
    final List<Experiment> rows = await (select(
      experiments,
    )..where((e) => e.id.equals(id))).get();
    if (rows.isEmpty) return false;
    final Set<int> days = decodeCheckIns(rows.first.checkIns);
    if (days.contains(dayIndex)) return false;
    days.add(dayIndex);
    await (update(experiments)..where((e) => e.id.equals(id))).write(
      ExperimentsCompanion(checkIns: Value(encodeCheckIns(days))),
    );
    return true;
  }

  Future<void> finishExperiment(int id) async {
    await (update(experiments)..where((e) => e.id.equals(id))).write(
      ExperimentsCompanion(status: const Value('done')),
    );
  }

  Future<bool> experimentEnabled() async {
    final List<ExperimentPref> rows = await (select(
      experimentPrefs,
    )..orderBy([(p) => OrderingTerm.asc(p.id)])).get();
    if (rows.isEmpty) return true;
    return rows.first.enabled;
  }

  Stream<bool> watchExperimentEnabled() {
    return (select(experimentPrefs)..orderBy([(p) => OrderingTerm.asc(p.id)]))
        .watch()
        .map((List<ExperimentPref> rows) {
          if (rows.isEmpty) return true;
          return rows.first.enabled;
        });
  }

  Future<void> setExperimentEnabled(bool enabled) async {
    final List<ExperimentPref> rows = await (select(
      experimentPrefs,
    )..orderBy([(p) => OrderingTerm.asc(p.id)])).get();
    if (rows.isEmpty) {
      await into(experimentPrefs).insert(
        ExperimentPrefsCompanion(
          enabled: Value(enabled),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return;
    }
    await (update(
      experimentPrefs,
    )..where((p) => p.id.equals(rows.first.id))).write(
      ExperimentPrefsCompanion(
        enabled: Value(enabled),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// v10 回滚语义：删实验两表即回 v9 形状（开发期回滚用）.
  Future<void> rollbackExperimentToV9() async {
    await customStatement('DROP TABLE IF EXISTS experiments');
    await customStatement('DROP TABLE IF EXISTS experiment_prefs');
  }
}
