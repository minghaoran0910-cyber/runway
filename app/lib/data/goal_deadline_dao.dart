// SB-041 · 期限列 DAO（AppDb 扩展；列定义见 app_db.dart Goals.deadline，迁移见 app_db.dart onUpgrade from<12）.
// 存量迁移幂等：ensureGoalDeadlineColumn 查 PRAGMA 缺列即补，已有即不动（SB-019 同规格）.
// 回滚：删 deadline 列即回 v11 形状（开发期回滚用；需 SQLite 3.35+ DROP COLUMN）.

import 'package:drift/drift.dart';

import 'app_db.dart';

extension AppDbGoalDeadline on AppDb {
  /// 幂等补列：缺 deadline 列即加（返回 true），已有即不动（返回 false）.
  Future<bool> ensureGoalDeadlineColumn() async {
    final List<QueryRow> info = await customSelect(
      "PRAGMA table_info('goals')",
    ).get();
    final bool has = info.any(
      (QueryRow r) => r.read<String>('name') == 'deadline',
    );
    if (has) return false;
    await customStatement('ALTER TABLE goals ADD COLUMN deadline TEXT');
    return true;
  }

  /// v12 回滚语义：删 deadline 列即回 v11 形状（开发期回滚用）.
  Future<void> rollbackGoalDeadlineToV11() async {
    await customStatement('ALTER TABLE goals DROP COLUMN deadline');
  }
}
