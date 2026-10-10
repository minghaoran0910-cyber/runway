import 'package:flutter/material.dart';

import 'data/app_db.dart';
import 'ui/home_page.dart';
import 'ui/theme/app_theme.dart';

// SB-004 · 入口挂接 AppDb 文件库（SQLCipher）+ HomePage 记账闭环.
// 占位计数器页已退役（REVIEW SB-003 观察项 1 落定：换真实页面）.

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
      home: FutureBuilder<AppDb>(
        future: AppDb.openDefault(),
        builder: (BuildContext ctx, AsyncSnapshot<AppDb> snap) {
          if (!snap.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return HomePage(db: snap.data!);
        },
      ),
    );
  }
}
