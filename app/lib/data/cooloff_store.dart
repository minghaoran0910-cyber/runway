// SB-017 · 冷静期表定义（schema v9；迁移见 app_db.dart，禁手改 schema）.
// 独立文件以满足 DEV §2 单文件 ≤400 行（app_db 主表文件单调增长，拆分经卡授权）.
// data 层纯结构，不依赖 logic 层.
// Cooloffs：txId=transactions.id（同一交易只建一单，不弹第二次）；
//   status=pending/bought/held/expired；decidedAt 为决策落库时间.
// CooloffPrefs：单行约定 id=1，enabled 默认开；customFen=0 即自动（日均×3）.

import 'package:drift/drift.dart';

/// schema v9：cooloffs（冷静单；txId 唯一由逻辑层保证）.
class Cooloffs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get txId => integer()();
  IntColumn get amountFen => integer()();
  DateTimeColumn get proposedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get decidedAt => dateTime().nullable()();
}

/// schema v9：cooloff_prefs（开关+自定义阈值；单行 id=1）.
class CooloffPrefs extends Table {
  IntColumn get id => integer().autoIncrement()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  IntColumn get customFen => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
