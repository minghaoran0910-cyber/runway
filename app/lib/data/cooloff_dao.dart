// SB-017 · 冷静期 DAO（AppDb 扩展；表定义见 cooloff_store.dart，迁移见 app_db.dart）.
// 同一 txId 只一单（propose 幂等：已存在即返回既有 id，不弹第二次）.
// 开关无行即默认开；customFen 无行即 0（自动=日均×3）.
// 回滚：删 cooloffs + cooloff_prefs 即回 v8 形状（开发期回滚用）.

import 'package:drift/drift.dart';

import 'app_db.dart';

extension AppDbCooloff on AppDb {
  Future<List<Cooloff>> listCooloffs() {
    return (select(cooloffs)..orderBy([(c) => OrderingTerm.desc(c.id)])).get();
  }

  Stream<List<Cooloff>> watchCooloffs() {
    return (select(
      cooloffs,
    )..orderBy([(c) => OrderingTerm.desc(c.id)])).watch();
  }

  Future<Cooloff?> cooloffOfTx(int txId) async {
    final List<Cooloff> rows = await (select(
      cooloffs,
    )..where((c) => c.txId.equals(txId))).get();
    return rows.isEmpty ? null : rows.first;
  }

  /// 幂等建单（同 txId 已存在即返回既有 id，不重复弹）.
  Future<int> proposeCooloff({
    required int txId,
    required int amountFen,
  }) async {
    final Cooloff? hit = await cooloffOfTx(txId);
    if (hit != null) return hit.id;
    return into(cooloffs).insert(
      CooloffsCompanion(
        txId: Value(txId),
        amountFen: Value(amountFen),
        proposedAt: Value(DateTime.now()),
        status: const Value('pending'),
      ),
    );
  }

  Future<void> decideCooloff({required int id, required String status}) async {
    await (update(cooloffs)..where((c) => c.id.equals(id))).write(
      CooloffsCompanion(
        status: Value(status),
        decidedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<bool> cooloffEnabled() async {
    final List<CooloffPref> rows = await (select(
      cooloffPrefs,
    )..orderBy([(p) => OrderingTerm.asc(p.id)])).get();
    if (rows.isEmpty) return true;
    return rows.first.enabled;
  }

  Stream<bool> watchCooloffEnabled() {
    return (select(cooloffPrefs)..orderBy([(p) => OrderingTerm.asc(p.id)]))
        .watch()
        .map((List<CooloffPref> rows) {
          if (rows.isEmpty) return true;
          return rows.first.enabled;
        });
  }

  Future<void> setCooloffEnabled(bool enabled) async {
    final List<CooloffPref> rows = await (select(
      cooloffPrefs,
    )..orderBy([(p) => OrderingTerm.asc(p.id)])).get();
    if (rows.isEmpty) {
      await into(cooloffPrefs).insert(
        CooloffPrefsCompanion(
          enabled: Value(enabled),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return;
    }
    await (update(
      cooloffPrefs,
    )..where((p) => p.id.equals(rows.first.id))).write(
      CooloffPrefsCompanion(
        enabled: Value(enabled),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> cooloffCustomFen() async {
    final List<CooloffPref> rows = await (select(
      cooloffPrefs,
    )..orderBy([(p) => OrderingTerm.asc(p.id)])).get();
    if (rows.isEmpty) return 0;
    return rows.first.customFen;
  }

  /// v9 回滚语义：删冷静两表即回 v8 形状（开发期回滚用）.
  Future<void> rollbackCooloffToV8() async {
    await customStatement('DROP TABLE IF EXISTS cooloffs');
    await customStatement('DROP TABLE IF EXISTS cooloff_prefs');
  }
}
