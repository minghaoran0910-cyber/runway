// SB-018 · 月度小实验表定义（schema v10；迁移见 app_db.dart，禁手改 schema）.
// 独立文件以满足 DEV §2 单文件 ≤400 行（app_db 主表文件单调增长，拆分经卡授权）.
// data 层纯结构，不依赖 logic 层.
// Experiments：templateId=库 id/自设走 custom；checkIns=逗号 dayIndex（0..6，同天幂等逻辑层保证）；
//   status=active/done；同月只一单由逻辑层保证（新 active 建单前先完结旧单）.
// ExperimentPrefs：单行约定 id=1，enabled 默认开.

import 'package:drift/drift.dart';

/// schema v10：experiments（7 天小实验落点）.
class Experiments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get templateId => text().withLength(min: 1, max: 32)();
  TextColumn get name => text().withLength(min: 1, max: 32)();
  IntColumn get dailySaveFen => integer()();
  DateTimeColumn get startDate => dateTime()();
  TextColumn get checkIns => text().withDefault(const Constant(''))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// schema v10：experiment_prefs（开关；单行 id=1）.
class ExperimentPrefs extends Table {
  IntColumn get id => integer().autoIncrement()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
