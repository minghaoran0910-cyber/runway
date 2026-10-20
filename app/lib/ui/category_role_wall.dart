import 'package:flutter/material.dart';

import '../logic/category_rules.dart';
import '../logic/entry.dart';
import '../logic/role_resolver.dart';

// SB-047 · 角色墙折叠组件（默认折叠 + 人话解释三行 + 未选红点）.
// 从 category_page.dart 拆出，保证单文件 ≤400 行（DEV §2.2）.

// SB-047 · 角色人话解释（行内折叠区顶部三行，一类一句）.
const Map<CategoryRole, String> roleExplain = <CategoryRole, String>{
  CategoryRole.necessary: '要花的：刚需开支，预算不压它',
  CategoryRole.flexible: '能省的：可优化空间，预算与冷静期只压它',
  CategoryRole.fixed: '固定的：房租贷款等，弹性之外',
};

/// 角色墙（ExpansionTile，默认折叠；pending>0 显示红点）.
class CategoryRoleWall extends StatelessWidget {
  const CategoryRoleWall({
    super.key,
    required this.cats,
    required this.overrides,
    required this.fenByCategory,
    required this.onPick,
  });

  final List<String> cats;
  final Map<String, CategoryRole> overrides;
  final Map<String, int> fenByCategory;
  final Future<void> Function(String category, String role) onPick;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int pending = cats
        .where(
          (String c) =>
              !overrides.containsKey(c) && !defaultCategoryRoles.containsKey(c),
        )
        .length;
    return Card(
      child: ExpansionTile(
        key: const Key('roleWall'),
        initiallyExpanded: false,
        title: Row(
          children: <Widget>[
            Expanded(
              child: Text('角色 · 每类必选', style: theme.textTheme.titleMedium),
            ),
            if (pending > 0)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  shape: BoxShape.circle,
                ),
                key: const Key('roleRedDot'),
              ),
          ],
        ),
        subtitle: Text(
          pending > 0 ? '$pending 类待选' : '已全部选择',
          style: theme.textTheme.bodySmall,
        ),
        children: <Widget>[
          for (final CategoryRole r in CategoryRole.values)
            ListTile(
              dense: true,
              title: Text(
                roleExplain[r]!,
                style: theme.textTheme.bodySmall,
                key: Key('roleExplain-${roleName(r)}'),
              ),
            ),
          for (final String c in cats)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      if (!overrides.containsKey(c) &&
                          !defaultCategoryRoles.containsKey(c))
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                          key: Key('roleDot-$c'),
                        ),
                      Expanded(
                        // SB-039 ① · 标题取全称（key 沿用引擎短名，零迁移）.
                        child: Text(
                          categoryDisplayName(c),
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        formatFenYuan(fenByCategory[c] ?? 0),
                        style: theme.textTheme.titleMedium,
                        key: Key('catTotal-$c'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: <Widget>[
                      for (final CategoryRole r in CategoryRole.values)
                        ChoiceChip(
                          label: Text(roleLabel(r)),
                          selected: resolveRole(c, overrides) == r,
                          onSelected: (_) => onPick(c, roleName(r)),
                          key: Key('role-$c-${roleName(r)}'),
                        ),
                    ],
                  ),
                  if (!overrides.containsKey(c) &&
                      !defaultCategoryRoles.containsKey(c))
                    Text(
                      '请选择角色：要花的 / 能省的 / 固定的',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      key: Key('rolePrompt-$c'),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
