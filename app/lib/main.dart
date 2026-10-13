import 'package:flutter/material.dart';

import 'data/app_db.dart';
import 'ui/root_shell.dart';
import 'ui/theme/app_theme.dart';

// SB-004 · 入口挂接 AppDb 文件库（SQLCipher）+ RootShell 三 tab 导航.
// 占位计数器页已退役（REVIEW SB-003 观察项 1 落定：换真实页面）.
// SB-027 · 全工程系统字体放大钳制 ≤1.3（大字体手机布局防爆，回归见
// text_scaler_test.dart）；下限不抬，保证小字体用户原样.

/// 系统字体缩放钳制（纯函数，可单测）：>1.3 一律压到 1.3，其余原样.
TextScaler clampTextScaler(TextScaler input) {
  return input.clamp(maxScaleFactor: 1.3);
}

/// MaterialApp.builder 具名封装（供回归测试直测同一函数）.
Widget textClampBuilder(BuildContext ctx, Widget? child) {
  final MediaQueryData mq = MediaQuery.of(ctx);
  return MediaQuery(
    data: mq.copyWith(textScaler: clampTextScaler(mq.textScaler)),
    child: child ?? const SizedBox.shrink(),
  );
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Runway',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      builder: textClampBuilder,
      home: FutureBuilder<AppDb>(
        future: AppDb.openDefault(),
        builder: (BuildContext ctx, AsyncSnapshot<AppDb> snap) {
          if (!snap.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return RootShell(db: snap.data!);
        },
      ),
    );
  }
}
