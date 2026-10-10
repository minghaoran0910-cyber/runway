import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../data/app_db.dart';
import '../data/category_stats.dart';
import '../logic/category_feedback.dart';
import '../logic/category_rules.dart';
import '../logic/entry.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';

// SB-005 · 类目管理页（规则引擎落地页：其他占比 + 六类目合计 + 手工纠正回写入口）.
// Hero 主卡沿 §3；列表分隔仅 hairline（§1.3）；数字 tabular（§1.4）；形状只用 r22/r16（§1.2）.

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('已纠正为 $to，同类下次自动归入')));
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
            final CategorySummary summary = summarizeTransactions(rows);
            final String shareText =
                '${(summary.otherShare * 100).toStringAsFixed(1)}%';
            return ListView(
              padding: const EdgeInsets.all(RunwaySpacing.page),
              children: <Widget>[
                Container(
                  decoration: AppTheme.heroCard(),
                  padding: const EdgeInsets.all(RunwaySpacing.cardInner),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        '其他占比（示例数据）',
                        style: TextStyle(
                          fontSize: RunwayHero.titleSize,
                          color: RunwayHero.title,
                        ),
                      ),
                      Text(
                        shareText,
                        style: const TextStyle(
                          fontSize: RunwayHero.numberSize,
                          color: RunwayHero.number,
                          fontWeight: FontWeight.w700,
                          fontFeatures: <FontFeature>[
                            FontFeature.tabularFigures(),
                          ],
                        ),
                        key: const Key('otherShare'),
                      ),
                      Text(
                        summary.otherFault ? '分类故障：占比超 5%，待修复' : '分类健康',
                        style: TextStyle(
                          fontSize: RunwayHero.subSize,
                          color: summary.otherFault
                              ? RunwayHero.goldAccent
                              : RunwayHero.sub,
                        ),
                        key: Key(
                          summary.otherFault ? 'otherFault' : 'otherHealthy',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: RunwaySpacing.section),
                Text(
                  '内置规则 ${defaultRules.length} 条 · 6 类目',
                  style: theme.textTheme.bodySmall,
                  key: const Key('ruleInfo'),
                ),
                const SizedBox(height: 8),
                for (final String c in ruleCategories)
                  Card(
                    child: ListTile(
                      title: Text(c, style: theme.textTheme.titleMedium),
                      trailing: Text(
                        formatFen(summary.fenByCategory[c] ?? 0),
                        style: theme.textTheme.titleMedium,
                        key: Key('catTotal-$c'),
                      ),
                    ),
                  ),
                const SizedBox(height: RunwaySpacing.section),
                Text('近期记录（可纠正）', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                if (rows.isEmpty)
                  Text(
                    '还没有记录',
                    style: theme.textTheme.bodyMedium,
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
                            '$canon · ${formatFen(r.amountFen)}',
                            style: theme.textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            diff
                                ? '${r.note.isEmpty ? '无备注' : r.note}（建议：$suggest）'
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
                                  child: Text(c),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
