import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../data/app_db.dart';
import 'bill_import_page.dart';
import 'diagnostics_card.dart';
import 'pending_page.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';

// SB-040 · "我的-设置"页（通知导入/待确认入口、诊断回传开关、数据导出、关于版本）.
// 形状只用 r16 内容卡；颜色只用 tokens；诊断段复用 SB-034 门（未配置=零像素）.

/// 版本（写死；发版时随 CHANGELOG 同改，不引入新依赖）.
const String kAppVersion = 'v0.1.0-dev';

/// 交易导出 CSV（纯函数，便于单测；合成数据口径，表头固定）.
String exportTransactionsCsv(List<Transaction> rows) {
  final StringBuffer sb = StringBuffer(
    'id,amountFen,occurredAt,category,note,source\n',
  );
  for (final Transaction r in rows) {
    final String note = r.note.replaceAll(',', '，').replaceAll('\n', ' ');
    sb.writeln(
      '${r.id},${r.amountFen},${r.occurredAt.toIso8601String()},${r.category},$note,${r.source}',
    );
  }
  return sb.toString();
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.db});

  final AppDb db;

  Future<void> _export(BuildContext context) async {
    final List<Transaction> rows = await db.listAll();
    final String csv = exportTransactionsCsv(rows);
    final Directory dir = await getTemporaryDirectory();
    final File f = File(
      '${dir.path}/runway-export-${DateTime.now().millisecondsSinceEpoch}.csv',
    );
    await f.writeAsString(csv);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已导出 ${rows.length} 笔 · ${f.path}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: Container(
        decoration: AppTheme.ground(isDark),
        child: ListView(
          padding: const EdgeInsets.all(RunwaySpacing.page),
          children: <Widget>[
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text('通知导入'),
                    subtitle: const Text('待确认入账与账单文件导入'),
                    key: const Key('settingsImport'),
                    onTap: () => Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => BillImportPage(db: db),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.markunread_mailbox_outlined),
                    title: const Text('待确认'),
                    subtitle: const Text('通知采集的每一笔先过目再入账'),
                    key: const Key('settingsPending'),
                    onTap: () => Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => PendingListPage(
                          db: db,
                          source: AndroidNotificationCollector(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: RunwaySpacing.section),
            // SB-034 门内：未配置/非 debug 即零像素（本页不断言其存在）.
            const DiagnosticsSection(),
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.ios_share_outlined),
                    title: const Text('数据导出'),
                    subtitle: const Text('全部记录导出为 CSV（合成口径）'),
                    key: const Key('settingsExport'),
                    onTap: () => _export(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outlined),
                    title: const Text('关于'),
                    subtitle: const Text('攒够 Runway · $kAppVersion'),
                    key: const Key('settingsAbout'),
                    onTap: () => showAboutDialog(
                      context: context,
                      applicationName: '攒够 Runway',
                      applicationVersion: kAppVersion,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
