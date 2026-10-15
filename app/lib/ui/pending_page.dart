import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_db.dart';
import '../logic/category_rules.dart';
import '../logic/entry.dart';
import '../logic/notification_parse.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';

// SB-010 · 待确认列表（PRD §3 待确认口径 / §4 本地优先；DESIGN §1 地面+浮起 / §7 得到框架）.
// 权限流：未授权→引导卡跳系统设置；撤销后本页仍可用（手动对账），功能降级不断崩.
// 批量确认开关默认关（默认逐条确认）；一键入账走 AppDb.confirmPending（SB-004 通道）.
// 原生推送接入：setPendingHandler 收到结构化字段即幂等落库（insertPendingDedup）.
// 通道 CONTRACT（Android 侧 MainActivity/PendingListenerService 实现，
// 卡授权的 `packages/android_notification_collector/` 家目录预留见该处 .gitkeep；
// Dart 侧收敛至本文件以满足"零 pub 依赖"卡约束——不新增 path 依赖）：
//   channel `runway/notify_collector` methods:
//     `isListenerEnabled` → bool；`openListenerSettings` → void；
//   原生 → Dart：method `onPending` arguments {
//     packageName, title, amountFen, merchant, notifyKey, occurredAtMs,
//     tag, notifId, whenMs, postTimeMs, contentHash }（R3 身份三元组补传）.
// §5 原文零留存：通道只传结构化字段，标题/正文原文不落库（pending 表无原文列）.
// 形状只用 r16（内容卡）/ r10（控件）；分隔仅 hairline；数字 tabular（§1.4）；
// 颜色只用 tokens + theme；文案"待确认"口径，禁"全自动"表述. 本文件零裸动效参数.

/// 采集源抽象（生产走 MethodChannel；测试走 FakePendingSource）.
abstract class PendingSource {
  Future<bool> isListenerEnabled();
  Future<void> openListenerSettings();
  void setPendingHandler(void Function(PendingPush push) onPush);
}

/// 原生推送的结构化账单（无原文）.
/// 身份字段（R3 验收 4）：[tag]/[notifId]/[whenMs]/[postTimeMs]/[contentHash]
/// 由原生补传，去重以 [notifyKey] 为准（Kotlin/Dart 同口径身份哈希）.
class PendingPush {
  PendingPush({
    required this.packageName,
    required this.title,
    required this.amountFen,
    required this.merchant,
    required this.notifyKey,
    required this.occurredAt,
    this.tag = '',
    this.notifId = 0,
    this.whenMs,
    this.postTimeMs,
    this.contentHash = '',
  });

  final String packageName;
  final String title;
  final int amountFen;
  final String merchant;
  final String notifyKey;
  final DateTime occurredAt;
  final String tag;
  final int notifId;
  final int? whenMs;
  final int? postTimeMs;
  final String contentHash;

  factory PendingPush.fromMap(Map<Object?, Object?> map) {
    int asInt(Object? v) => v is int ? v : int.tryParse('$v') ?? 0;
    int? asIntOrNull(Object? v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse('$v');
    }

    final int whenRaw = asInt(map['whenMs']);
    final int postRaw = asInt(map['postTimeMs']);
    return PendingPush(
      packageName: '${map['packageName'] ?? ''}',
      title: '${map['title'] ?? ''}',
      amountFen: asInt(map['amountFen']),
      merchant: '${map['merchant'] ?? ''}',
      notifyKey: '${map['notifyKey'] ?? ''}',
      occurredAt: DateTime.fromMillisecondsSinceEpoch(
        asInt(map['occurredAtMs']),
      ),
      tag: '${map['tag'] ?? ''}',
      notifId: asInt(map['notifId']),
      whenMs: whenRaw == 0 && !map.containsKey('whenMs') ? null : whenRaw,
      postTimeMs:
          asIntOrNull(map['postTimeMs']) ?? (postRaw == 0 ? null : postRaw),
      contentHash: '${map['contentHash'] ?? ''}',
    );
  }
}

/// 生产实现：MethodChannel 直连 Android 侧.
class AndroidNotificationCollector implements PendingSource {
  AndroidNotificationCollector({MethodChannel? channel})
    : channel = channel ?? const MethodChannel(_channelName);

  static const String _channelName = 'runway/notify_collector';

  @visibleForTesting
  final MethodChannel channel;

  @override
  Future<bool> isListenerEnabled() async {
    try {
      final bool? v = await channel.invokeMethod<bool>('isListenerEnabled');
      return v ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      // 桌面端/未集成原生侧：降级为手动（崩溃=打回，故此处必须吞异常）.
      return false;
    }
  }

  @override
  Future<void> openListenerSettings() async {
    try {
      await channel.invokeMethod<void>('openListenerSettings');
    } on PlatformException {
      // 降级：停留本页，列表仍可用（手动对账）.
    } on MissingPluginException {
      // 同上.
    }
  }

  @override
  void setPendingHandler(void Function(PendingPush push) onPush) {
    channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onPending' && call.arguments is Map) {
        onPush(PendingPush.fromMap(call.arguments as Map<Object?, Object?>));
      }
    });
  }
}

class PendingListPage extends StatefulWidget {
  const PendingListPage({super.key, required this.db, required this.source});

  final AppDb db;
  final PendingSource source;

  @override
  State<PendingListPage> createState() => _PendingListPageState();
}

class _PendingListPageState extends State<PendingListPage> {
  /// 批量确认开关：默认关（卡验收 3；默认逐条确认）.
  bool _batch = false;
  final Set<int> _picked = <int>{};

  @override
  void initState() {
    super.initState();
    widget.source.setPendingHandler(_onPush);
  }

  Future<void> _onPush(PendingPush push) async {
    if (push.amountFen <= 0 || push.notifyKey.isEmpty) return;
    String merchant = push.merchant.trim().isEmpty
        ? push.title.trim()
        : push.merchant.trim();
    if (merchant.isEmpty) {
      merchant = push.packageName == alipayPackage ? '支付宝' : '微信支付';
    }
    if (merchant.length > 32) merchant = merchant.substring(0, 32);
    await widget.db.insertPendingDedup(
      PendingRecordsCompanion(
        amountFen: Value(push.amountFen),
        occurredAt: Value(push.occurredAt),
        category: Value(
          canonicalCategory(
            classifyTransaction(merchant: merchant, amountFen: push.amountFen),
          ),
        ),
        merchant: Value(merchant),
        sourcePkg: Value(push.packageName),
        notifyKey: Value(push.notifyKey),
      ),
    );
  }

  Future<void> _confirmOne(PendingRecord row) async {
    await widget.db.confirmPending(row);
  }

  Future<void> _confirmPicked() async {
    final List<PendingRecord> rows = await widget.db.listPending();
    for (final PendingRecord r in rows) {
      if (_picked.contains(r.id)) await widget.db.confirmPending(r);
    }
    if (mounted) setState(() => _picked.clear());
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('待确认')),
      body: Container(
        decoration: AppTheme.ground(isDark),
        child: ListView(
          padding: const EdgeInsets.all(RunwaySpacing.page),
          children: <Widget>[
            _PermissionCard(source: widget.source),
            const SizedBox(height: RunwaySpacing.section),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '逐条确认，省出看得见',
                    style: theme.textTheme.bodyMedium,
                    key: const Key('pendingHint'),
                  ),
                ),
                Switch(
                  value: _batch,
                  key: const Key('batchSwitch'),
                  onChanged: (bool v) => setState(() {
                    _batch = v;
                    if (!v) _picked.clear();
                  }),
                ),
                const Text('批量'),
              ],
            ),
            if (_batch)
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  key: const Key('confirmPicked'),
                  onPressed: _picked.isEmpty ? null : _confirmPicked,
                  child: Text('确认所选（${_picked.length}）'),
                ),
              ),
            const SizedBox(height: 8),
            StreamBuilder<List<PendingRecord>>(
              stream: widget.db.watchPending(),
              builder:
                  (BuildContext ctx, AsyncSnapshot<List<PendingRecord>> snap) {
                    final List<PendingRecord> rows =
                        snap.data ?? <PendingRecord>[];
                    if (rows.isEmpty) {
                      return Padding(
                        // SB-045 ④ · 裸 24 收 token（section=24 同值）.
                        padding: const EdgeInsets.only(
                          top: RunwaySpacing.section,
                        ),
                        child: Text(
                          '暂无待确认，授权通知使用权后自动采集',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                          key: const Key('pendingEmpty'),
                        ),
                      );
                    }
                    return Column(
                      children: <Widget>[
                        for (final PendingRecord r in rows)
                          _PendingRow(
                            row: r,
                            batch: _batch,
                            picked: _picked.contains(r.id),
                            onPick: (bool? v) => setState(() {
                              if (v == true) {
                                _picked.add(r.id);
                              } else {
                                _picked.remove(r.id);
                              }
                            }),
                            onConfirm: () => _confirmOne(r),
                          ),
                      ],
                    );
                  },
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({required this.source});

  final PendingSource source;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return FutureBuilder<bool>(
      future: source.isListenerEnabled(),
      builder: (BuildContext ctx, AsyncSnapshot<bool> snap) {
        if (snap.data == true) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(RunwaySpacing.cardInner),
              child: Text(
                '通知采集已开启，新账单会进入待确认',
                style: theme.textTheme.bodyMedium,
                key: const Key('permOn'),
              ),
            ),
          );
        }
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(RunwaySpacing.cardInner),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '去系统设置打开"通知使用权"，支付通知会自动进入待确认',
                  style: theme.textTheme.bodyMedium,
                  key: const Key('permOff'),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  key: const Key('openSettings'),
                  onPressed: () => source.openListenerSettings(),
                  child: const Text('去设置'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PendingRow extends StatelessWidget {
  const _PendingRow({
    required this.row,
    required this.batch,
    required this.picked,
    required this.onPick,
    required this.onConfirm,
  });

  final PendingRecord row;
  final bool batch;
  final bool picked;
  final ValueChanged<bool?> onPick;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(RunwaySpacing.cardInner),
        child: Row(
          children: <Widget>[
            if (batch)
              Checkbox(
                value: picked,
                onChanged: onPick,
                key: Key('pick-${row.id}'),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${row.merchant} · ${formatFen(row.amountFen)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFeatures: const <FontFeature>[
                        FontFeature.tabularFigures(),
                      ],
                    ),
                    key: Key('pendingTitle-${row.id}'),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${row.category} · 待确认入账',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            FilledButton.tonal(
              key: Key('pendingConfirm-${row.id}'),
              onPressed: onConfirm,
              child: const Text('确认入账'),
            ),
          ],
        ),
      ),
    );
  }
}
