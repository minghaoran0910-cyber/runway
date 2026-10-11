// SB-019 · 角色 DAO（AppDb 扩展；表定义见 category_role_store.dart，迁移见 app_db.dart）.
// 存量迁移幂等：ensureDefaultRoles 按默认映射补齐缺失行，已有覆盖不动.
// 回滚：删 role_overrides 即回 v10 形状（开发期回滚用）.

import 'package:drift/drift.dart';

import 'app_db.dart';

extension AppDbCategoryRole on AppDb {
  Future<List<RoleOverride>> listCategoryRoles() {
    return (select(
      roleOverrides,
    )..orderBy([(r) => OrderingTerm.asc(r.category)])).get();
  }

  Stream<List<RoleOverride>> watchCategoryRoles() {
    return (select(
      roleOverrides,
    )..orderBy([(r) => OrderingTerm.asc(r.category)])).watch();
  }

  /// 覆盖表快照（标准名 → 角色串；调用方经 parseRole 转枚举）.
  Future<Map<String, String>> roleOverrideMap() async {
    final List<RoleOverride> rows = await listCategoryRoles();
    return <String, String>{
      for (final RoleOverride r in rows) r.category: r.role,
    };
  }

  /// 设置角色（有行更新，无行插入；返回行 id）.
  Future<int> setCategoryRole({
    required String category,
    required String role,
  }) async {
    final List<RoleOverride> hit = await (select(
      roleOverrides,
    )..where((t) => t.category.equals(category))).get();
    if (hit.isEmpty) {
      return into(roleOverrides).insert(
        RoleOverridesCompanion(
          category: Value(category),
          role: Value(role),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
    await (update(
      roleOverrides,
    )..where((t) => t.category.equals(category))).write(
      RoleOverridesCompanion(
        role: Value(role),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return hit.first.id;
  }

  /// 存量迁移（幂等）：默认映射缺失即补，已有覆盖不动；返回新增数.
  Future<int> ensureDefaultRoles(Map<String, String> defaults) async {
    final Map<String, String> cur = await roleOverrideMap();
    int added = 0;
    for (final MapEntry<String, String> e in defaults.entries) {
      if (!cur.containsKey(e.key)) {
        await into(roleOverrides).insert(
          RoleOverridesCompanion(
            category: Value(e.key),
            role: Value(e.value),
            updatedAt: Value(DateTime.now()),
          ),
        );
        added++;
      }
    }
    return added;
  }

  /// v11 回滚语义：删 role_overrides 即回 v10 形状（开发期回滚用）.
  Future<void> rollbackCategoryRolesToV10() async {
    await customStatement('DROP TABLE IF EXISTS role_overrides');
  }
}
