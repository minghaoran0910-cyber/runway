// SB-007 · 目标阶梯与实物换算引擎（PRD §2 攒到层 / DESIGN §7 得到框架，纯 Dart）.
// 口径（卡"换算口径"）：可换算省出 = 比基线多省 + 环比增量，非绝对存款.
//   savedVsBaseline = max(0, baselineFen - monthSpendFen)
//   momGain         = max(0, lastMonthSpendFen - monthSpendFen)
//   convertibleFen  = savedVsBaseline + momGain
// 默认基线取上月实际支出；调用方可传月预算覆盖.
// 文案一律"得到"框架（"省出了什么"）；禁亏欠表述（"又花掉/只剩/还差"）；
// 大额提示只陈述不劝阻（"相当于…"，无行动召唤）.
// 本文件禁 import flutter（logic 不依赖 ui/flutter）.

import 'entry.dart';

/// 参考单价（名 + 分；内置可改，UI 层允许自定义）.
class PriceRef {
  const PriceRef({required this.name, required this.fen});

  final String name;
  final int fen;
}

/// 内置单价表（卡验收 1：奶茶/键盘/手机/5090，可自定义改单价）.
const List<PriceRef> defaultPrices = <PriceRef>[
  PriceRef(name: '奶茶', fen: 1800),
  PriceRef(name: '键盘', fen: 29900),
  PriceRef(name: '手机', fen: 399900),
  PriceRef(name: '5090', fen: 1649900),
];

/// 阶梯档（PRD §2：奶茶→5090→余粮→自由基金→FIRE；键盘/手机为实物中间档）.
class LadderRung {
  const LadderRung({required this.name, required this.thresholdFen});

  final String name;
  final int thresholdFen;
}

const List<LadderRung> defaultLadder = <LadderRung>[
  LadderRung(name: '奶茶', thresholdFen: 1800),
  LadderRung(name: '键盘', thresholdFen: 29900),
  LadderRung(name: '手机', thresholdFen: 399900),
  LadderRung(name: '5090', thresholdFen: 1649900),
  LadderRung(name: '余粮', thresholdFen: 6000000),
  LadderRung(name: '自由基金', thresholdFen: 24000000),
  LadderRung(name: 'FIRE', thresholdFen: 100000000),
];

/// 目标（含换算结果）.
class GoalView {
  const GoalView({
    required this.savedVsBaseline,
    required this.momGain,
    required this.convertibleFen,
    required this.progress,
    required this.done,
  });

  final int savedVsBaseline;
  final int momGain;
  final int convertibleFen;

  /// 0..1（目标未设或目标<=0 时为 0）.
  final double progress;

  /// 已攒够目标.
  final bool done;
}

/// 领域校验：返回 null = 合法，否则为错误文案.
String? validateGoal({
  required String name,
  required int? targetFen,
  required String priceName,
  required int? priceFen,
}) {
  if (name.trim().isEmpty || name.trim().length > 32) return '目标名 1–32 字';
  if (targetFen == null || targetFen <= 0) return '目标金额须大于 0';
  if (targetFen > 10000000000) return '目标金额过大';
  if (priceName.trim().isEmpty || priceName.trim().length > 16) {
    return '单价名 1–16 字';
  }
  if (priceFen == null || priceFen <= 0) return '参考单价须大于 0';
  return null;
}

/// 换算：比基线多省 + 环比增量（两项各自钳零，不存在负省出）.
GoalView computeGoal({
  required int monthSpendFen,
  required int lastMonthSpendFen,
  int? baselineFen,
  int? targetFen,
}) {
  final int base = baselineFen ?? lastMonthSpendFen;
  final int savedVsBaseline = base - monthSpendFen > 0
      ? base - monthSpendFen
      : 0;
  final int momGain = lastMonthSpendFen - monthSpendFen > 0
      ? lastMonthSpendFen - monthSpendFen
      : 0;
  final int convertible = savedVsBaseline + momGain;
  double progress = 0;
  bool done = false;
  if (targetFen != null && targetFen > 0) {
    progress = (convertible / targetFen).clamp(0.0, 1.0).toDouble();
    done = convertible >= targetFen;
  }
  return GoalView(
    savedVsBaseline: savedVsBaseline,
    momGain: momGain,
    convertibleFen: convertible,
    progress: progress,
    done: done,
  );
}

/// 实物换算文案（得到框架）.
/// - 0：持平期，指向下一笔（"记下一笔就开始攺出…"，零亏欠表述）.
/// - 不足 1 件：报已攺 + 继续攺（不用"还差"）.
/// - 足 1 件起："本周省出 N 杯奶茶"；有余数则追加下一杯进度（得到框架）.
String describeSaving({required int convertibleFen, required PriceRef price}) {
  if (convertibleFen <= 0) {
    return '本期持平 · 记下一笔就开始攒出第一杯${price.name}';
  }
  final int count = convertibleFen ~/ price.fen;
  if (count <= 0) {
    final int rest = price.fen - convertibleFen;
    return '已攒 ${formatFen(convertibleFen)} · 继续攒 ${formatFen(rest)}'
        ' 得到 1 ${cupUnit(price.name)}${price.name}';
  }
  final int rest = convertibleFen % price.fen;
  final String head = '本周省出 $count ${cupUnit(price.name)}${price.name}';
  if (rest <= 0) return head;
  return '$head · 另已攒 ${formatFen(rest)} 向下一杯前进';
}

/// 大额陈述（只陈述不劝阻）：取不超过总额的最大内置单价，无行动召唤.
String equivalentOf(int convertibleFen) {
  PriceRef? hit;
  for (final PriceRef p in defaultPrices) {
    if (p.fen <= convertibleFen) hit = p;
  }
  if (hit == null) return '稳步积累中';
  final int count = convertibleFen ~/ hit.fen;
  return '相当于 $count ${cupUnit(hit.name)}${hit.name}';
}

/// 目标所属阶梯档（不超过目标额的最大档）.
String ladderNameFor(int targetFen) {
  String name = defaultLadder.first.name;
  for (final LadderRung r in defaultLadder) {
    if (r.thresholdFen <= targetFen) name = r.name;
  }
  return name;
}

/// 下一站提示（得到框架）.
/// 已达最高档或已攺够目标 → 庆祝陈述（成就时刻文案归 SB-008，此处只报得到）.
String nextLadderHint({required int convertibleFen, required int targetFen}) {
  final String tier = ladderNameFor(targetFen);
  if (convertibleFen >= targetFen && targetFen > 0) {
    return '已攒够 $tier · 得到阶段性底气';
  }
  LadderRung? next;
  for (final LadderRung r in defaultLadder) {
    if (r.thresholdFen > convertibleFen) {
      next = r;
      break;
    }
  }
  if (next == null) return '已越过全部阶梯 · 得到长期底气';
  final double pct = (convertibleFen / next.thresholdFen)
      .clamp(0.0, 1.0)
      .toDouble();
  final String pctText = (pct * 100).toStringAsFixed(0);
  return '下一站 ${next.name} · 已攒 $pctText%';
}

/// 量词语（奶茶/咖啡按杯，其余按件；趣味单位仅限文案正文，禁做图标 §4）.
String cupUnit(String priceName) {
  if (priceName.contains('奶茶') || priceName.contains('咖啡')) return '杯';
  return '件';
}
