// SB-034 · 金额脱敏单测（0 / 负数 / 大数边界；输出不含原值；禁词零命中）.

import 'package:flutter_test/flutter_test.dart';
import 'package:runway/diagnostics/diag_mask.dart';
import 'package:runway/logic/achievement.dart';

void main() {
  test('SB-034 零值', () {
    expect(maskAmountFen(0), equals('¥0'));
  });

  test('SB-034 小额多位', () {
    expect(maskAmountFen(123400), equals('¥1□□□□□'));
    expect(maskedHidesRaw(fen: 123400, masked: maskAmountFen(123400)), isTrue);
  });

  test('SB-034 负数保符号', () {
    expect(maskAmountFen(-1234), equals('-¥1□□□'));
    expect(maskedHidesRaw(fen: -1234, masked: maskAmountFen(-1234)), isTrue);
  });

  test('SB-034 大数边界', () {
    expect(maskAmountFen(100000000), equals('¥1□□□□□□□□'));
    expect(
      maskedHidesRaw(fen: 100000000, masked: maskAmountFen(100000000)),
      isTrue,
    );
  });

  test('SB-034 首位与位数保留', () {
    expect(maskAmountFen(3612000).startsWith('¥3'), isTrue);
    expect(maskAmountFen(3612000).length, equals('3612000'.length + 1));
  });

  test('SB-034 诊断文案禁词零命中', () {
    const List<String> copy = <String>['体验改进计划', '帮你攒得更稳：卡顿或闪退时自动带上技术日志，修得更快'];
    for (final String w in achievementBannedWords) {
      for (final String s in copy) {
        expect(s.contains(w), isFalse, reason: '禁词命中: $w');
      }
    }
    expect(copy.join().contains('浪费'), isFalse);
  });
}
