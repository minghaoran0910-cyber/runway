// SB-005 · 类目统计仓储（thin wrapper：Transactions 行 → 领域汇总，无 schema 变更）.
// DEV §2.3 禁区合规：不动 schema、不加 migration，只读现有 transactions 表.

import '../logic/category_feedback.dart';
import '../logic/category_rules.dart';
import 'app_db.dart';

/// 全量行汇总（含旧类目名归一）；空库返回零汇总（otherShare=0，不误报故障）.
CategorySummary summarizeTransactions(List<Transaction> rows) {
  return summarizeFlows(
    rows.map(
      (Transaction r) =>
          (amountFen: r.amountFen, category: canonicalCategory(r.category)),
    ),
  );
}
