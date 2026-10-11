// SB-017 · 大额冷静期引擎（PRD §2 改变层；DESIGN §7 得到框架，纯 Dart）.
// 口径：
//   阈值 = 自定义（>0 即用）否则 日均 ×3（日均复用 SB-016 dailyAverage，禁第二套公式）.
//   只手动大额触发（source=manual；notify/import/estimate 一律不触发）.
//   24h 未处理 → 静默记入（保留交易，不弹第二次，由调用方落 expired）.
//   忍住 → 省额并入目标（调用方删交易/记省额）+ 一句梗（复用 SB-014 称号池）.
//   仍要买 → 无摩擦保留（调用方只落 decided-bought，不删不改不等待）.
// 文案一律得到框架；禁词复用 achievementBannedWords（零新增）；不拦截不说教.
// 本文件禁 import flutter（logic 不依赖 ui/flutter）.

import 'achievement.dart';
import 'entry.dart';
import 'grain_report.dart';

/// 默认倍数（日均 ×3；SB-019 联动时可调，阈值函数已预留 multiple 参数）.
const int defaultCooloffMultiple = 3;

/// 冷静有效期（24h；超时即静默记入，不弹第二次）.
const Duration cooloffWindow = Duration(hours: 24);

/// 候选记账输入（UI 由 Transaction 转换；logic 不 import drift）.
class CooloffCandidate {
  const CooloffCandidate({
    required this.amountFen,
    required this.source,
    required this.occurredAt,
  });

  final int amountFen;
  final String source;
  final DateTime occurredAt;
}

/// 冷静单状态（pending=待决策；bought=仍要买；held=忍住；expired=超时静默记入）.
class CooloffDecision {
  const CooloffDecision({
    required this.amountFen,
    required this.proposedAt,
    required this.status,
  });

  final int amountFen;
  final DateTime proposedAt;
  final String status;
}

/// 阈值（自定义>0 优先；否则 日均×multiple；日均<=0 即 0=不问，零编造）.
int cooloffThreshold({
  required int dailyAvgFen,
  int multiple = defaultCooloffMultiple,
  int customFen = 0,
}) {
  if (customFen > 0) return customFen;
  if (dailyAvgFen <= 0 || multiple <= 0) return 0;
  return dailyAvgFen * multiple;
}

/// 是否弹冷静卡（只手动大额；采集/导入/估算一律 false）.
bool shouldProposeCooloff({
  required CooloffCandidate candidate,
  required int thresholdFen,
  required bool alreadyProposed,
}) {
  if (alreadyProposed) return false;
  if (thresholdFen <= 0) return false;
  if (candidate.source != 'manual') return false;
  if (candidate.amountFen < thresholdFen) return false;
  return true;
}

/// 是否超时（proposedAt + 24h <= now 即静默记入）.
bool shouldExpireCooloff({
  required DateTime proposedAt,
  required DateTime now,
}) {
  return now.difference(proposedAt) >= cooloffWindow;
}

/// 提出文案（得到框架；只陈述，大额只给换算类比，零行动召唤）.
String cooloffAskText({required int amountFen}) {
  return '这单 ¥${formatFen(amountFen)}，先放 24 小时看看？';
}

/// 提出副文案（决定权在人；仍要买无摩擦，先说清不等待）.
String cooloffAskHint() => '忍住=离目标又近一步 · 仍要买直接记，不等待';

/// 忍住文案（省额+一句梗；梗复用 SB-014 称号池，只说粮仓不说人）.
String cooloffHeldText({required int savedFen, required int targetFen}) {
  final String title = goalGrainTitle(
    convertibleFen: savedFen,
    targetFen: targetFen,
  );
  final String joke = grainJokeFor(title);
  return '已为目标省出 ¥${formatFen(savedFen)} · $title —— $joke';
}

/// 仍要买文案（无摩擦确认；中性陈述，不劝阻不说教）.
String cooloffBoughtText({required int amountFen}) {
  return '已记 ¥${formatFen(amountFen)} · 稳步积累的证明';
}

/// 超时文案（静默记入；只陈述，不补弹不打扰）.
String cooloffExpiredText({required int amountFen}) {
  return '昨日 ¥${formatFen(amountFen)} 已记 · 稳步积累的证明';
}

/// 领域校验：自定义阈值（分；0=自动，须 0 或 >0）.
String? validateCooloffCustomFen(int? fen) {
  if (fen == null) return '阈值须为数字';
  if (fen < 0) return '阈值不能为负';
  if (fen > 100000000) return '阈值过大';
  return null;
}

/// 领域校验：冷静单金额（分，须 >0）.
String? validateCooloffAmountFen(int? fen) {
  if (fen == null || fen <= 0) return '金额须大于 0';
  if (fen > 100000000) return '金额过大';
  return null;
}

/// 本卡禁词复用成就表（不另建第二套；冷静文案零命中）.
List<String> get cooloffBannedWords => achievementBannedWords;
