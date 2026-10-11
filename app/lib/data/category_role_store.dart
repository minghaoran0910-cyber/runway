// SB-019 · 角色表定义（schema v11；迁移见 app_db.dart，禁手改 schema）.
// 独立文件以满足 DEV §2 单文件 ≤400 行（app_db 主表文件单调增长，拆分经卡授权）.
// data 层纯结构，不依赖 logic 层.
// RoleOverrides：category 唯一（标准名口径），role=必要/弹性/固定；用户覆盖优先于默认映射.
// 表类取名 RoleOverrides（行类 RoleOverride）：避开 logic 层 CategoryRole 枚举名冲突.

import 'package:drift/drift.dart';

/// schema v11：role_overrides（类目角色覆盖；无行即默认映射）.
class RoleOverrides extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text().withLength(min: 1, max: 32).unique()();
  TextColumn get role => text().withLength(min: 1, max: 8)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
