// SB-023 · 测试固定时钟夹具（三族统一入口）.
// DEV_WORKFLOW 测试时钟规范（2026-10-12 转正）：凡涉及"今天/本周"语义的
// 测试种子一律由此派生，禁止在测试文件中直调 DateTime.now()/new Date().
// 双模：today() 动态封装（相对种子，保月份/周关系，行为与直调一致）；
// fixedMonday 绝对钉（SB-023 落定当周周一 2026-10-12，供周报页 nowOverride
// 与绝对种子，全年渲染确定）.本文件是测试目录唯一允许直调 DateTime.now
// 之处（卡验收"固定夹具封装除外"口径）.
class FixedClock {
  /// 动态今天（相对种子用；与直调 DateTime.now() 同行为）.
  static DateTime today() => DateTime.now();

  /// 绝对周一钉（周报页时钟与绝对种子用；渲染全年确定）.
  static DateTime get fixedMonday => DateTime(2026, 10, 12);

  /// 上周一钉（周报历史种子用）.
  static DateTime get lastWeekMonday =>
      fixedMonday.subtract(const Duration(days: 7));
}
