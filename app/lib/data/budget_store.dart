// SB-015 · 预算表定义（schema v7；表+迁移见 app_db.dart，禁手改 schema）.
// 独立文件以满足 DEV §2 单文件 ≤400 行（app_db 主表文件单调增长，拆分经卡授权）.
// data 层纯结构，不依赖 logic 层.
// 同一 monthKey 允许多行：最新行即当前预算，历史行即修改历史（改后"省出"按新基线重算）.

import 'package:drift/drift.dart';

/// schema v7：budgets（月预算；monthKey=YYYY-MM；basis=sameMonth/median/manual/observing）.
class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get monthKey => text().withLength(min: 4, max: 16)();
  IntColumn get budgetFen => integer()();
  IntColumn get basisFen => integer().withDefault(const Constant(0))();
  IntColumn get tightenPct => integer().withDefault(const Constant(5))();
  TextColumn get basis => text().withDefault(const Constant('median'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
