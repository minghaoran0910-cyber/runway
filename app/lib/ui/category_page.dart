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
import 'category_role_wall.dart';
import 'widgets/progress_ring.dart';

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
      appBar: AppBar(title: const Text('账本')),
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
                  padding: const EdgeInsets.fromLTRB(
                    RunwaySpacing.page,
                    RunwaySpacing.page,
                    RunwaySpacing.page,
                    96,
                  ), // SB-044 · 底部 96 避开 FAB 遮挡
                  children: <Widget>[
                    Container(
                      decoration: AppTheme.heroCard(),
                      padding: const EdgeInsets.all(RunwaySpacing.cardInner),
                      // SB-047 · 页首占比可视化：左文案 + 右复用首页 ring.
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
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
                                const SizedBox(height: 4),
                                Text(
                                  '能省的钱是可优化的空间 · 预算与冷静期只压能省的',
                                  // SB-047 · 副句提级 bodyMedium（可读主文案）.
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: RunwayHero.sub,
                                  ),
                                  key: const Key('elasticHint'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          ProgressRing(
                            fraction: month.elasticShare,
                            key: const Key('elasticRing'),
                            center: Text(
                              '${(month.elasticShare * 100).toStringAsFixed(0)}%',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: RunwayHero.number,
                                fontFeatures: const <FontFeature>[
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // SB-047 · 空态重设计：零记录只出一张引导卡，角色墙隐藏.
                    if (rows.isEmpty)
                      const SizedBox(height: RunwaySpacing.section),
                    if (rows.isEmpty)
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(RunwaySpacing.cardInner),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '去记一笔，占比与角色在这里等你',
                                style: theme.textTheme.titleMedium,
                                key: Key('emptyCatHint'),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '记下第一笔后，这里会显示本月类目占比与角色解释',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
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
                    // SB-047 · 角色墙默认折叠（记录>0 才出现）；未选行红点引导.
                    if (rows.isNotEmpty) ...<Widget>[
                      const SizedBox(height: RunwaySpacing.section),
                      CategoryRoleWall(
                        cats: cats,
                        overrides: overrides,
                        fenByCategory: summary.fenByCategory,
                        onPick: (String c, String role) =>
                            db.setCategoryRole(category: c, role: role),
                      ),
                    ],
                    // SB-039 ③ · 其他占比 + 内置规则行已搬"我的"关于诊断区，
                    // 本页只留用户语言（走查"钱花哪了+哪能省"两步直达）.
                    if (rows.isNotEmpty) ...<Widget>[
                      const SizedBox(height: RunwaySpacing.section),
                      Text('近期记录（可纠正）', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                    ],
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
                                '${categoryDisplayName(canon)} · ${formatFenYuan(r.amountFen)}',
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
