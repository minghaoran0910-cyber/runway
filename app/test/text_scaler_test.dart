import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runway/main.dart';

// SB-027 · 系统字体放大钳制回归：1.5 倍缩放不破版（统一压到 ≤1.3）.

void main() {
  test('SB-027 clampTextScaler：超 1.3 压平，不超原样', () {
    expect(
      clampTextScaler(const TextScaler.linear(2.0)).scale(10.0),
      equals(13.0),
    );
    expect(
      clampTextScaler(const TextScaler.linear(1.5)).scale(10.0),
      equals(13.0),
    );
    expect(
      clampTextScaler(const TextScaler.linear(1.3)).scale(10.0),
      equals(13.0),
    );
    expect(
      clampTextScaler(const TextScaler.linear(1.0)).scale(10.0),
      equals(10.0),
    );
    expect(clampTextScaler(TextScaler.noScaling).scale(10.0), equals(10.0));
  });

  testWidgets('SB-027 builder：1.5 缩放进入后 ≤1.3', (WidgetTester tester) async {
    TextScaler? seen;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: MaterialApp(
          builder: textClampBuilder,
          home: Builder(
            builder: (BuildContext ctx) {
              seen = MediaQuery.textScalerOf(ctx);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    await tester.pump();
    expect(seen, isNotNull);
    expect(seen!.scale(10.0), lessThanOrEqualTo(13.0));
  });
}
