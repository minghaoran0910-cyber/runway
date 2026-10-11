import 'package:flutter/material.dart';

import '../data/app_db.dart';
import '../data/category_role_dao.dart';
import '../data/cooloff_dao.dart';
import '../logic/cooloff.dart';
import '../logic/estimate.dart';
import '../logic/role_resolver.dart';
import 'theme/tokens.dart';

// SB-017 · 大额冷静卡（PRD §2 改变层；DESIGN §1 地面+浮起 / §7 得到框架）.
// 只手动大额触发（source=manual；采集/导入/估算不触发）；决定权永远在人：
// 「仍要买」主钮无摩擦保留交易，「忍住」删交易并计省额（省额经目标引擎自然并入进度）+ 一句梗.
// 24h 未处理静默记入，不弹第二次（同 txId 只一单，超时自动落 expired）.
// 开关默认开可关；形状只用 r16（内容卡）；颜色只用 tokens.
// 本文件零裸时长/曲线（无动画，纯展示 + 落库）；成就复用 SB-008（禁新造动效）.

class CooloffCard extends StatelessWidget {
  const CooloffCard({
    super.key,
    required this.amountFen,
    required this.held,
    this.savedFen = 0,
    this.targetFen = 0,
    this.onBuy,
    this.onHold,
  });

  final int amountFen;
  final bool held;
  final int savedFen;
  final int targetFen;
  final VoidCallback? onBuy;
  final VoidCallback? onHold;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(RunwaySpacing.cardInner),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              held ? '大额冷静 · 已忍住' : '大额冷静 · 24 小时',
              style: theme.textTheme.titleMedium,
              key: const Key('cooloffTitle'),
            ),
            const SizedBox(height: 8),
            Text(
              held
                  ? cooloffHeldText(savedFen: savedFen, targetFen: targetFen)
                  : cooloffAskText(amountFen: amountFen),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
              key: held ? const Key('cooloffDone') : const Key('cooloffAsk'),
            ),
            if (held) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                '省额已并入目标进度',
                style: theme.textTheme.bodySmall,
                key: const Key('cooloffJoke'),
              ),
            ],
            if (!held) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                cooloffAskHint(),
                style: theme.textTheme.bodySmall,
                key: const Key('cooloffHint'),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: <Widget>[
                  FilledButton(
                    onPressed: onBuy,
                    key: const Key('cooloffBuy'),
                    child: const Text('仍要买'),
                  ),
                  OutlinedButton(
                    onPressed: onHold,
                    key: const Key('cooloffHold'),
                    child: const Text('忍住'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 冷静同区（首页每日收口之后；数据源 transactions + cooloffs + goals）.
class CooloffZone extends StatefulWidget {
  const CooloffZone({super.key, required this.db});

  final AppDb db;

  @override
  State<CooloffZone> createState() => _CooloffZoneState();
}

class _CooloffZoneState extends State<CooloffZone> {
  final Set<int> _proposedTxIds = <int>{};
  final Set<int> _expiredIds = <int>{};

  Future<void> _ensureProposed(int txId, int amountFen) async {
    await widget.db.proposeCooloff(txId: txId, amountFen: amountFen);
  }

  Future<void> _buy(Cooloff row) async {
    await widget.db.decideCooloff(id: row.id, status: 'bought');
  }

  Future<void> _hold(Cooloff row) async {
    await widget.db.deleteOne(row.txId);
    await widget.db.decideCooloff(id: row.id, status: 'held');
  }

  bool _decidedToday(DateTime? decidedAt, DateTime now) {
    if (decidedAt == null) return false;
    return decidedAt.year == now.year &&
        decidedAt.month == now.month &&
        decidedAt.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    return StreamBuilder<bool>(
      stream: widget.db.watchCooloffEnabled(),
      builder: (ectx, esnap) {
        final bool enabled = esnap.data ?? true;
        return StreamBuilder<List<Transaction>>(
          stream: widget.db.watchAll(),
          builder: (tctx, tsnap) {
            final List<Transaction> rows = tsnap.data ?? <Transaction>[];
            return StreamBuilder<List<Cooloff>>(
              stream: widget.db.watchCooloffs(),
              builder: (cctx, csnap) {
                final List<Cooloff> orders = csnap.data ?? <Cooloff>[];
                return StreamBuilder<List<Goal>>(
                  stream: widget.db.watchGoals(),
                  builder: (gctx, gsnap) {
                    final List<Goal> goals = gsnap.data ?? <Goal>[];
                    final int targetFen = goals.isEmpty
                        ? 0
                        : goals.first.targetFen;
                    return FutureBuilder<int>(
                      future: widget.db.cooloffCustomFen(),
                      builder: (uctx, usnap) {
                        final int custom = usnap.data ?? 0;
                        return StreamBuilder<List<RoleOverride>>(
                          stream: widget.db.watchCategoryRoles(),
                          builder: (octx, osnap) {
                            final Map<String, CategoryRole> overrides =
                                <String, CategoryRole>{};
                            for (final RoleOverride o
                                in osnap.data ?? <RoleOverride>[]) {
                              final CategoryRole? r = parseRole(o.role);
                              if (r != null) overrides[o.category] = r;
                            }
                            // SB-019：阈值只压弹性（弹性日均×3；自定义仍优先，原公式不动）.
                            final List<CloseFlow> flows = rows
                                .where(
                                  (r) =>
                                      isElasticCategory(r.category, overrides),
                                )
                                .map(
                                  (r) => CloseFlow(
                                    amountFen: r.amountFen,
                                    occurredAt: r.occurredAt,
                                    source: r.source,
                                  ),
                                )
                                .toList();
                            final int avg = dailyAverage(
                              flows: flows,
                              now: now,
                            );
                            final int threshold = cooloffThreshold(
                              dailyAvgFen: avg,
                              customFen: custom,
                            );
                            final Map<int, Cooloff> byTx = <int, Cooloff>{};
                            for (final Cooloff o in orders) {
                              byTx[o.txId] = o;
                            }
                            // 超时即静默记入（落 expired，不再弹）.
                            for (final Cooloff o in orders) {
                              if (o.status == 'pending' &&
                                  !_expiredIds.contains(o.id) &&
                                  shouldExpireCooloff(
                                    proposedAt: o.proposedAt,
                                    now: now,
                                  )) {
                                _expiredIds.add(o.id);
                                widget.db.decideCooloff(
                                  id: o.id,
                                  status: 'expired',
                                );
                              }
                            }
                            // 待决策单（未超时）优先展示.
                            Cooloff? pending;
                            for (final Cooloff o in orders) {
                              if (o.status == 'pending' &&
                                  !shouldExpireCooloff(
                                    proposedAt: o.proposedAt,
                                    now: now,
                                  )) {
                                pending = o;
                                break;
                              }
                            }
                            // 无待决策单 → 找最新 24h 内手动大额候选（仅弹性；固定账单不触发）.
                            Transaction? candidate;
                            if (pending == null && threshold > 0) {
                              for (final Transaction r in rows) {
                                if (r.source != 'manual') continue;
                                if (!isElasticCategory(r.category, overrides)) {
                                  continue;
                                }
                                if (r.amountFen < threshold) continue;
                                if (now.difference(r.occurredAt) >=
                                    cooloffWindow) {
                                  continue;
                                }
                                if (byTx.containsKey(r.id)) continue;
                                candidate = r;
                                break;
                              }
                              if (candidate != null &&
                                  !_proposedTxIds.contains(candidate.id)) {
                                _proposedTxIds.add(candidate.id);
                                _ensureProposed(
                                  candidate.id,
                                  candidate.amountFen,
                                );
                              }
                            }
                            // 今日忍住 → 展示已忍住态（含梗）.
                            Cooloff? heldToday;
                            for (final Cooloff o in orders) {
                              if (o.status == 'held' &&
                                  _decidedToday(o.decidedAt, now)) {
                                heldToday = o;
                                break;
                              }
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        '大额冷静',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ),
                                    Switch(
                                      value: enabled,
                                      key: const Key('cooloffSwitch'),
                                      onChanged: (bool v) =>
                                          widget.db.setCooloffEnabled(v),
                                    ),
                                  ],
                                ),
                                if (!enabled)
                                  const SizedBox.shrink()
                                else if (pending != null)
                                  CooloffCard(
                                    amountFen: pending.amountFen,
                                    held: false,
                                    onBuy: () => _buy(pending!),
                                    onHold: () => _hold(pending!),
                                  )
                                else if (heldToday != null)
                                  CooloffCard(
                                    amountFen: heldToday.amountFen,
                                    held: true,
                                    savedFen: heldToday.amountFen,
                                    targetFen: targetFen,
                                  )
                                else if (threshold <= 0)
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                        RunwaySpacing.cardInner,
                                      ),
                                      child: Text(
                                        '先记账，冷静期自然来',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                        key: const Key('cooloffEmpty'),
                                      ),
                                    ),
                                  )
                                else
                                  const SizedBox.shrink(),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
