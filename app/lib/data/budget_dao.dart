// SB-015 · 预算 DAO（AppDb 扩展；表定义见 budget_store.dart，迁移见 app_db.dart）.
// 当前预算 = 同 monthKey 最新行（id 最大）；修改即插新行，历史天然保留.
// 回滚：删 budgets 表即回 v6 形状（开发期回滚用）.

import 'package:drift/drift.dart';

import 'app_db.dart';

extension AppDbBudget on AppDb {
  Future<List<Budget>> listBudgets() {
    return (select(budgets)..orderBy([(b) => OrderingTerm.desc(b.id)])).get();
  }

  /// 同月历史（id 倒序即修改序列）.
  Future<List<Budget>> listBudgetHistory(String monthKey) {
    return (select(budgets)
          ..where((b) => b.monthKey.equals(monthKey))
          ..orderBy([(b) => OrderingTerm.desc(b.id)]))
        .get();
  }

  Stream<List<Budget>> watchBudgetHistory(String monthKey) {
    return (select(budgets)
          ..where((b) => b.monthKey.equals(monthKey))
          ..orderBy([(b) => OrderingTerm.desc(b.id)]))
        .watch();
  }

  /// 当前预算（无行即 null=观察期，调用方给手动设定入口）.
  Future<Budget?> currentBudget(String monthKey) async {
    final List<Budget> rows = await listBudgetHistory(monthKey);
    return rows.isEmpty ? null : rows.first;
  }

  /// 设定/修改预算（插新行；历史保留；返回新行 id）.
  Future<int> upsertBudget({
    required String monthKey,
    required int budgetFen,
    int basisFen = 0,
    int tightenPct = 5,
    String basis = 'manual',
  }) {
    return into(budgets).insert(
      BudgetsCompanion(
        monthKey: Value(monthKey),
        budgetFen: Value(budgetFen),
        basisFen: Value(basisFen),
        tightenPct: Value(tightenPct),
        basis: Value(basis),
        createdAt: Value(DateTime.now()),
      ),
    );
  }

  /// v7 回滚语义：删 budgets 表即回 v6 形状（开发期回滚用）.
  Future<void> rollbackBudgetsToV6() async {
    await customStatement('DROP TABLE IF EXISTS budgets');
  }
}
