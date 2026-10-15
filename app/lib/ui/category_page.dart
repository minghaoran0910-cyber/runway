import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../data/app_db.dart';
import '../data/category_role_dao.dart';
import '../data/category_stats.dart';
import '../logic/category_feedback.dart';
import '../logic/category_rules.dart';
import '../logic/entry.dart';
import '../logic/role_resolver.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';
import 'price_card.dart';

// SB-005 · 类目管理页（规则引擎落地页：其他占比 + 六类目合计 + 手工纠正回写入口）.
// SB-019 · 角色轴：头部本月弹性占比（首页不放）+ 每类目角色三选（编辑必选，未选必提示）
//   + 聚餐拆分一次性引导卡（只引导不强制）；形状只用 r22/r16；数字 tabular.
// 新建说明：全应用无独立建类目入口，新类目=交易中新名出现即提示必选（见 REVIEW_REQUEST 偏差）.

class CategoryPage extends StatelessWidget {
  CategoryPage({super.key, required this.db, CategoryCorrections? corrections})
    : corrections = corrections ?? CategoryCorrections();

  final AppDb db;
  final CategoryCorrections corrections;

  Future<void> _fix(BuildContext context, Transaction row, String to) async {
    // 备注为空则无键可学：只改库（偏差 D2，见 REVIEW_REQUEST）.
    if (row.note.trim().isNotEmpty) {
      corrections.record(note: row.note, category: to);
    }
    await db.updateOne(
      TransactionsCompanion(
        id: Value(row.id),
        amountFen: Value(row.amountFen),
        occurredAt: Value(row.occurredAt),
        category: Value(to),
        note: Value(row.note),
        source: Value(row.source),
      ),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已纠正为 ${categoryDisplayName(to)}，同类下次自动归入')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('类目管理')),
      body: Container(
        decoration: AppTheme.ground(isDark),
        child: StreamBuilder<List<Transaction>>(
          stream: db.watchAll(),
          builder: (BuildContext ctx, AsyncSnapshot<List<Transaction>> snap) {
            final List<Transaction> rows = snap.data ?? <Transaction>[];
            return StreamBuilder<List<RoleOverride>>(
              stream: db.watchCategoryRoles(),
              builder: (rctx, rsnap) {
                final Map<String, CategoryRole> overrides =
                    <String, CategoryRole>{};
                for (final RoleOverride o in rsnap.data ?? <RoleOverride>[]) {
                  final CategoryRole? r = parseRole(o.role);
                  if (r != null) overrides[o.category] = r;
                }
                final CategorySummary summary = summarizeTransactions(rows);
                final DateTime now = DateTime.now();
                final RoleSummary month = summarizeRoles(
                  rows
                      .where(
                        (t) =>
                            t.occurredAt.year == now.year &&
                            t.occurredAt.month == now.month,
                      )
                      .map(
                        (t) => (amountFen: t.amountFen, category: t.category),
                      ),
                  overrides,
                );
                final int diningHits = rows
                    .where(
                      (t) => isDiningSplitCandidate(
                        category: t.category,
                        note: t.note,
                      ),
                    )
                    .length;
                final Set<String> customs = <String>{};
                for (final Transaction t in rows) {
                  final String c = canonicalCategory(t.category);
                  if (!ruleCategories.contains(c)) customs.add(c);
                }
                final List<String> cats = <String>[
                  ...ruleCategories,
                  ...customs.toList()..sort(),
                ];
                return ListView(
                  padding: const EdgeInsets.all(RunwaySpacing.page),
                  children: <Widget>[
                    Container(
                      decoration: AppTheme.heroCard(),
                      padding: const EdgeInsets.all(RunwaySpacing.cardInner),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            elasticShareText(
                              share: month.elasticShare,
                              elasticFen: month.elasticFen,
                            ),
                            // SB-027 · 弹性占比句是说明性长句，禁套跑道大数字
                            // 字号（RunwayHero.numberSize=28）：降至标题档，
                            // 溢出与"一句话顶标题大"实锤即此修.
                            // SB-027 ①b · 渐变卡内文字一律高对比档：ink 系深色
                            // 在 hero 深青渐变上对比度不足，改用 RunwayHero 白系.
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: RunwayHero.number,
                              fontFeatures: const <FontFeature>[
                                FontFeature.tabularFigures(),
                              ],
                            ),
                            key: const Key('elasticShare'),
                          ),
                          Text(
                            '能省的钱是可优化的空间 · 预算与冷静期只压能省的',
                            // SB-027 ①b · 同上：bodySmall 次灰改 hero 副白.
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: RunwayHero.sub,
                            ),
                            key: const Key('elasticHint'),
                          ),
                        ],
                      ),
                    ),
                    if (diningHits > 0) ...<Widget>[
                      const SizedBox(height: RunwaySpacing.section),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(
                            RunwaySpacing.cardInner,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                diningGuideText(),
                                // SB-039 ④ · 引导说明降 bodySmall，禁占标题位.
                                style: theme.textTheme.bodySmall,
                                key: const Key('diningGuide'),
                              ),
                              Text(
                                '已发现 $diningHits 笔聚餐记录 · 可在下方把聚餐记为能省的',
                                style: theme.textTheme.bodySmall,
                                key: const Key('diningCount'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: RunwaySpacing.section),
                    Text('角色 · 每类必选', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    for (final String c in cats)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(
                            RunwaySpacing.cardInner,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    // SB-039 ① · 标题取全称（key 沿用引擎短名，零迁移）.
                                    child: Text(
                                      categoryDisplayName(c),
                                      style: theme.textTheme.titleMedium,
                                    ),
                                  ),
                                  Text(
                                    formatFen(summary.fenByCategory[c] ?? 0),
                                    style: theme.textTheme.titleMedium,
                                    key: Key('catTotal-$c'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: <Widget>[
                                  for (final CategoryRole r
                                      in CategoryRole.values)
                                    ChoiceChip(
                                      label: Text(roleLabel(r)),
                                      selected: resolveRole(c, overrides) == r,
                                      onSelected: (_) async {
                                        await db.setCategoryRole(
                                          category: c,
                                          role: roleName(r),
                                        );
                                      },
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
                            ],
                          ),
                        ),
                      ),
                    // SB-039 ③ · 其他占比 + 内置规则行已搬"我的"关于诊断区，
                    // 本页只留用户语言（走查"钱花哪了+哪能省"两步直达）.
                    const SizedBox(height: RunwaySpacing.section),
                    Text('近期记录（可纠正）', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (rows.isEmpty)
                      Text(
                        '还没有记录',
                        // SB-039 ④ · 占位说明降 bodySmall.
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                        key: const Key('emptyCatHint'),
                      ),
                    for (final Transaction r in rows)
                      Builder(
                        builder: (BuildContext itemCtx) {
                          final String canon = canonicalCategory(r.category);
                          final String suggest = classifyTransaction(
                            note: r.note,
                            amountFen: r.amountFen,
                            correctionLookup: corrections.lookup,
                          );
                          final bool diff = suggest != canon;
                          return Card(
                            child: ListTile(
                              title: Text(
                                // SB-039 ① · 记录行类目取全称.
                                '${categoryDisplayName(canon)} · ${formatFen(r.amountFen)}',
                                style: theme.textTheme.titleMedium,
                              ),
                              subtitle: Text(
                                diff
                                    ? '${r.note.isEmpty ? '无备注' : r.note}（建议：${categoryDisplayName(suggest)}）'
                                    : (r.note.isEmpty ? '无备注' : r.note),
                                style: theme.textTheme.bodySmall,
                              ),
                              trailing: PopupMenuButton<String>(
                                tooltip: '纠正',
                                icon: const Icon(Icons.tune),
                                onSelected: (String v) => _fix(itemCtx, r, v),
                                itemBuilder: (_) => <PopupMenuEntry<String>>[
                                  for (final String c in ruleCategories)
                                    PopupMenuItem<String>(
                                      value: c,
                                      key: Key('fix-$c'),
                                      child: Text(categoryDisplayName(c)),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    // SB-020 · 常买价格眼同区（无 ≥3 条同键即零高度，旧 golden 零改动）.
                    PriceZone(db: db),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
