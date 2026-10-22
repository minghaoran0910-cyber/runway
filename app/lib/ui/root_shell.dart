import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_db.dart';
import 'category_page.dart';
import 'goal_page.dart';
import 'home_page.dart';
import 'quick_add_page.dart';
import 'runway_icons.dart';

// SB-027 · 底部导航壳（P0 急救）：三 tab（首页/账本/我的），现有页面全挂进去.
// 首页=HomePage（内层记一笔 FAB 让位外层统一 FAB）；账本=CategoryPage；
// 我的=GoalPage（保留其定目标 FAB，该页外层记一笔 FAB 隐藏，偏差见提审单）.

class RootShell extends StatefulWidget {
  const RootShell({super.key, required this.db});

  final AppDb db;

  @override
  State<RootShell> createState() => RootShellState();
}

class RootShellState extends State<RootShell> {
  int index = 0;

  Future<void> _openAdd() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => QuickAddPage(db: widget.db)),
    );
  }

  DateTime? _lastBack;

  /// SB-044 · 双击返回退出：首按提示、2 秒内再按才真退（防误触一键退丢上下文）.
  void _handleBack() {
    final DateTime now = DateTime.now();
    if (_lastBack != null &&
        now.difference(_lastBack!) < const Duration(seconds: 2)) {
      // canPop:false 下 maybePop 会被自身拦截，真退须走 SystemNavigator.
      SystemNavigator.pop();
      return;
    }
    _lastBack = now;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('再按一次退出攒够'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        body: IndexedStack(
          index: index,
          children: <Widget>[
            HomePage(db: widget.db, showFab: false),
            CategoryPage(db: widget.db),
            GoalPage(db: widget.db),
          ],
        ),
        floatingActionButton: index == 2
            ? null
            : FloatingActionButton(
                onPressed: _openAdd,
                tooltip: '记一笔',
                key: const Key('shellAdd'),
                child: const Icon(Icons.add),
              ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (int i) => setState(() => index = i),
          destinations: <Widget>[
            NavigationDestination(
              icon: RunwayIcon(RunwayIconKind.home),
              selectedIcon: RunwayIcon(RunwayIconKind.homeFilled),
              label: '首页',
            ),
            NavigationDestination(
              icon: RunwayIcon(RunwayIconKind.book),
              selectedIcon: RunwayIcon(RunwayIconKind.bookFilled),
              label: '账本',
            ),
            NavigationDestination(
              icon: RunwayIcon(RunwayIconKind.user),
              selectedIcon: RunwayIcon(RunwayIconKind.userFilled),
              label: '我的',
            ),
          ],
        ),
      ),
    );
  }
}
