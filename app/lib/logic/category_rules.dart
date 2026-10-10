// SB-005 · 规则引擎自动归类（PRD §2 自动归类 / §3 其他>5%即故障 / §4 领域层纯 Dart）.
// 本文件禁 import flutter（DEV §2 四层依赖方向：logic 不依赖 ui/flutter）.
// 金额一律为分（整数）；文本匹配大小写不敏感（latin 商户名归一小写，中文不受影响）.

/// 引擎标准类目（卡验收 1：食/行/居/玩/用/其他）.
const List<String> ruleCategories = <String>['食', '行', '居', '玩', '用', '其他'];

/// 兜底类目：无规则命中即归入"其他"（PRD §3 失败态口径）.
const String otherCategory = '其他';

/// SB-004 旧类目名 → 引擎标准名（存量数据兼容；新数据一律标准名）.
const Map<String, String> legacyCategoryAlias = <String, String>{
  '餐饮': '食',
  '交通': '行',
  '居住': '居',
  '娱乐': '玩',
  '购物': '用',
  '其他': '其他',
};

/// 类目名归一：标准名直通，旧名映射，未知原样返回（不强制改写用户自建类目）.
String canonicalCategory(String raw) {
  if (ruleCategories.contains(raw)) return raw;
  return legacyCategoryAlias[raw] ?? raw;
}

/// 单条规则：文本含 [keyword] 且金额落在 [minFen, maxFen] 即命中.
/// 金额 bound 为 null = 不限该侧；keyword 为空串 = 纯金额规则.
class CategoryRule {
  const CategoryRule(this.keyword, this.category, {this.minFen, this.maxFen});

  final String keyword;
  final String category;
  final int? minFen;
  final int? maxFen;

  bool matches(String haystack, int amountFen) {
    if (keyword.isNotEmpty && !haystack.contains(keyword)) return false;
    if (minFen != null && amountFen < minFen!) return false;
    if (maxFen != null && amountFen > maxFen!) return false;
    return true;
  }
}

/// 内置默认规则表（关键词/商户同走文本包含匹配 + 金额区间消歧）.
/// 排序：金额消歧对优先（互斥区间，顺序无关，集中声明意图）.
const List<CategoryRule> defaultRules = <CategoryRule>[
  // —— 金额区间消歧（同一关键词，大额/小额分流）——
  CategoryRule('苹果', '用', minFen: 10000), // ≥100 元：数码果（合成阈值，见单测）
  CategoryRule('苹果', '食', maxFen: 9999), // <100 元：水果
  // —— 食 ——
  CategoryRule('早餐', '食'),
  CategoryRule('早点', '食'),
  CategoryRule('午餐', '食'),
  CategoryRule('午饭', '食'),
  CategoryRule('晚餐', '食'),
  CategoryRule('晚饭', '食'),
  CategoryRule('夜宵', '食'),
  CategoryRule('外卖', '食'),
  CategoryRule('食堂', '食'),
  CategoryRule('餐厅', '食'),
  CategoryRule('饭店', '食'),
  CategoryRule('小吃', '食'),
  CategoryRule('面馆', '食'),
  CategoryRule('拉面', '食'),
  CategoryRule('沙县', '食'),
  CategoryRule('火锅', '食'),
  CategoryRule('烧烤', '食'),
  CategoryRule('烤肉', '食'),
  CategoryRule('麻辣烫', '食'),
  CategoryRule('奶茶', '食'),
  CategoryRule('咖啡', '食'),
  CategoryRule('瑞幸', '食'),
  CategoryRule('星巴克', '食'),
  CategoryRule('肯德基', '食'),
  CategoryRule('麦当劳', '食'),
  CategoryRule('面包', '食'),
  CategoryRule('水果', '食'),
  CategoryRule('买菜', '食'),
  CategoryRule('盒马', '食'),
  CategoryRule('生鲜', '食'),
  CategoryRule('零食', '食'),
  CategoryRule('便利店', '食'),
  CategoryRule('喜茶', '食'),
  CategoryRule('饺子', '食'),
  CategoryRule('包子', '食'),
  CategoryRule('寿司', '食'),
  CategoryRule('披萨', '食'),
  CategoryRule('快餐', '食'),
  CategoryRule('甜品', '食'),
  CategoryRule('蛋糕', '食'),
  CategoryRule('聚餐', '食'),
  CategoryRule('starbucks', '食'),
  CategoryRule('luckin', '食'),
  CategoryRule('kfc', '食'),
  CategoryRule('mcdonald', '食'),
  CategoryRule('pizza', '食'),
  // —— 行 ——
  CategoryRule('地铁', '行'),
  CategoryRule('公交', '行'),
  CategoryRule('打车', '行'),
  CategoryRule('滴滴', '行'),
  CategoryRule('出租车', '行'),
  CategoryRule('网约车', '行'),
  CategoryRule('高铁', '行'),
  CategoryRule('动车', '行'),
  CategoryRule('火车', '行'),
  CategoryRule('机票', '行'),
  CategoryRule('航班', '行'),
  CategoryRule('加油', '行'),
  CategoryRule('停车', '行'),
  CategoryRule('过路费', '行'),
  CategoryRule('高速', '行'),
  CategoryRule('单车', '行'),
  CategoryRule('哈啰', '行'),
  CategoryRule('洗车', '行'),
  CategoryRule('修车', '行'),
  CategoryRule('保养', '行'),
  CategoryRule('船票', '行'),
  CategoryRule('机场', '行'),
  CategoryRule('的士', '行'),
  CategoryRule('顺风车', '行'),
  CategoryRule('交通卡', '行'),
  CategoryRule('didi', '行'),
  // —— 居 ——
  CategoryRule('房租', '居'),
  CategoryRule('租金', '居'),
  CategoryRule('租房', '居'),
  CategoryRule('续租', '居'),
  CategoryRule('物业', '居'),
  CategoryRule('水费', '居'),
  CategoryRule('电费', '居'),
  CategoryRule('燃气', '居'),
  CategoryRule('宽带', '居'),
  CategoryRule('网费', '居'),
  CategoryRule('话费', '居'),
  CategoryRule('取暖', '居'),
  CategoryRule('暖气', '居'),
  CategoryRule('家电', '居'),
  CategoryRule('家具', '居'),
  CategoryRule('搬家', '居'),
  CategoryRule('中介费', '居'),
  CategoryRule('押金', '居'),
  CategoryRule('水电', '居'),
  CategoryRule('家政', '居'),
  CategoryRule('保洁', '居'),
  CategoryRule('灯具', '居'),
  CategoryRule('窗帘', '居'),
  CategoryRule('床垫', '居'),
  // —— 玩 ——
  CategoryRule('电影', '玩'),
  CategoryRule('影院', '玩'),
  CategoryRule('观影', '玩'),
  CategoryRule('游戏', '玩'),
  CategoryRule('手游', '玩'),
  CategoryRule('电竞', '玩'),
  CategoryRule('会员', '玩'),
  CategoryRule('爱奇艺', '玩'),
  CategoryRule('腾讯视频', '玩'),
  CategoryRule('优酷', '玩'),
  CategoryRule('b站', '玩'),
  CategoryRule('哔哩哔哩', '玩'),
  CategoryRule('演出', '玩'),
  CategoryRule('演唱会', '玩'),
  CategoryRule('门票', '玩'),
  CategoryRule('旅游', '玩'),
  CategoryRule('旅行', '玩'),
  CategoryRule('酒店', '玩'),
  CategoryRule('民宿', '玩'),
  CategoryRule('乐园', '玩'),
  CategoryRule('迪士尼', '玩'),
  CategoryRule('ktv', '玩'),
  CategoryRule('酒吧', '玩'),
  CategoryRule('剧本杀', '玩'),
  CategoryRule('密室', '玩'),
  CategoryRule('桌游', '玩'),
  CategoryRule('健身', '玩'),
  CategoryRule('游泳', '玩'),
  CategoryRule('足浴', '玩'),
  CategoryRule('按摩', '玩'),
  CategoryRule('展览', '玩'),
  CategoryRule('博物馆', '玩'),
  CategoryRule('露营', '玩'),
  CategoryRule('度假', '玩'),
  CategoryRule('话剧', '玩'),
  CategoryRule('音乐会', '玩'),
  CategoryRule('滑雪', '玩'),
  CategoryRule('温泉', '玩'),
  // —— 用 ——
  CategoryRule('超市', '用'),
  CategoryRule('商场', '用'),
  CategoryRule('淘宝', '用'),
  CategoryRule('天猫', '用'),
  CategoryRule('京东', '用'),
  CategoryRule('拼多多', '用'),
  CategoryRule('衣服', '用'),
  CategoryRule('服装', '用'),
  CategoryRule('鞋子', '用'),
  CategoryRule('日用', '用'),
  CategoryRule('纸巾', '用'),
  CategoryRule('洗发水', '用'),
  CategoryRule('沐浴露', '用'),
  CategoryRule('牙膏', '用'),
  CategoryRule('洗衣液', '用'),
  CategoryRule('文具', '用'),
  CategoryRule('理发', '用'),
  CategoryRule('剪发', '用'),
  CategoryRule('药店', '用'),
  CategoryRule('买药', '用'),
  CategoryRule('医院', '用'),
  CategoryRule('挂号', '用'),
  CategoryRule('门诊', '用'),
  CategoryRule('体检', '用'),
  CategoryRule('眼镜', '用'),
  CategoryRule('化妆品', '用'),
  CategoryRule('护肤', '用'),
  CategoryRule('母婴', '用'),
  CategoryRule('奶粉', '用'),
  CategoryRule('宠物', '用'),
  CategoryRule('猫粮', '用'),
  CategoryRule('快递', '用'),
  CategoryRule('邮费', '用'),
  CategoryRule('打印', '用'),
  CategoryRule('书店', '用'),
  CategoryRule('买书', '用'),
  CategoryRule('课程', '用'),
  CategoryRule('培训', '用'),
  CategoryRule('学费', '用'),
  CategoryRule('数码', '用'),
  CategoryRule('耳机', '用'),
  CategoryRule('雨伞', '用'),
  CategoryRule('行李箱', '用'),
];

/// 自动归类：纠正优先 → 默认规则表 → 兜底"其他".
/// [merchant]/[note] 合并为待匹配文本（商户/关键词同口径）.
/// [correctionLookup] 为纠正表查询（`CategoryCorrections.lookup` 直接传入，
/// 签名解耦以避免 logic 内循环 import）.
String classifyTransaction({
  String merchant = '',
  String note = '',
  int amountFen = 0,
  String? Function({required String merchant, required String note})?
  correctionLookup,
}) {
  final String hay = '$merchant $note'.trim().toLowerCase();
  final String? hit = correctionLookup?.call(merchant: merchant, note: note);
  if (hit != null && hit.isNotEmpty) return hit;
  for (final CategoryRule rule in defaultRules) {
    if (rule.matches(hay, amountFen)) return rule.category;
  }
  return otherCategory;
}
