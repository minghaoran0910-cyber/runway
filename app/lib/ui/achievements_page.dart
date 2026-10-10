import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../data/app_db.dart';
import '../logic/achievement.dart';
import '../logic/entry.dart';
import 'achievement_card.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';

// SB-008 · 成就收藏页（PRD §2 成就卡序列；DESIGN §1 地面+浮起 / §7 得到框架）.
// 时间序列倒序；截图导出走 RepaintBoundary.toImage（无新依赖）；
// 形状只用 r16（内容卡）；分隔仅 hairline；数字 tabular；颜色只用 tokens.
// 本文件零裸时长/曲线（无动画，纯展示 + 截图导出）.

/// 截图导出（无新依赖；返回 PNG 字节，调用方配文见 shareCaption）.
Future<Uint8List?> captureAchievementPng(GlobalKey key) async {
  final RenderObject? obj = key.currentContext?.findRenderObject();
  if (obj == null || obj is! RenderRepaintBoundary) return null;
  final ui.Image img = await obj.toImage(pixelRatio: 2);
  final ByteData? data = await img.toByteData(format: ui.ImageByteFormat.png);
  return data?.buffer.asUint8List();
}

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key, required this.db});

  final AppDb db;

  String _dateOf(DateTime t) {
    final String m = t.month.toString().padLeft(2, '0');
    final String d = t.day.toString().padLeft(2, '0');
    return '${t.year}-$m-$d';
  }

  Future<void> _share(
    BuildContext context,
    GlobalKey key,
    String goalName,
  ) async {
    final Uint8List? bytes = await captureAchievementPng(key);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          bytes == null
              ? '导出失败，再试一次'
              : '${shareCaption(goalName: goalName)} · 已导出 ${bytes.length} 字节',
        ),
        key: const Key('achShareResult'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('成就收藏')),
      body: Container(
        decoration: AppTheme.ground(isDark),
        child: StreamBuilder<List<Achievement>>(
          stream: db.watchAchievements(),
          builder: (BuildContext ctx, AsyncSnapshot<List<Achievement>> snap) {
            final List<Achievement> rows = snap.data ?? <Achievement>[];
            if (rows.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(RunwaySpacing.page),
                children: <Widget>[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(RunwaySpacing.cardInner),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('成就收藏', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            '还没有成就卡 · 定第一个目标开始攒',
                            style: theme.textTheme.bodyMedium,
                            key: const Key('achEmpty'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(RunwaySpacing.page),
              itemCount: rows.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, thickness: 0.5),
              itemBuilder: (BuildContext c, int i) {
                final Achievement a = rows[i];
                final GlobalKey key = GlobalKey(debugLabel: 'achShot-${a.id}');
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(RunwaySpacing.cardInner),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        RepaintBoundary(
                          key: key,
                          child: AchievementCard(
                            goalName: a.goalName,
                            targetFen: a.targetFen,
                            convertibleFen: a.convertibleFen,
                            tier: a.tier,
                            frame: AchievementFrame.still,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                '${_dateOf(a.unlockedAt)} · 攒出 ${formatFen(a.targetFen)}',
                                style: theme.textTheme.bodySmall,
                                key: Key('achItem-${a.id}'),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _share(context, key, a.goalName),
                              key: Key('achShare-${a.id}'),
                              child: const Text('分享为图片'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
