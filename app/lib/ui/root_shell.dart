import 'package:flutter/material.dart';

import '../data/app_db.dart';
import 'category_page.dart';
import 'goal_page.dart';
import 'home_page.dart';
import 'quick_add_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: '账本',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
