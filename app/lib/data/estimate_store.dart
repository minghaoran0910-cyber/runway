// SB-016 · 每日收口表定义（schema v8；迁移见 app_db.dart，禁手改 schema）.
// 独立文件以满足 DEV §2 单文件 ≤400 行（app_db 主表文件单调增长，拆分经卡授权）.
// data 层纯结构，不依赖 logic 层.
// DailyCloses：同 dateKey 允许多行（最新即当日状态；问句只看今日是否有行）.
// ClosePrefs：单行约定 id=1，enabled 默认开（新库无行即开）.

import 'package:drift/drift.dart';

/// schema v8：daily_closes（每日收口落点；status=done/skipped）.
class DailyCloses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get dateKey => text().withLength(min: 8, max: 16)();
  IntColumn get estimateFen => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('done'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// schema v8：close_prefs（收口开关；单行 id=1）.
class ClosePrefs extends Table {
  IntColumn get id => integer().autoIncrement()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
