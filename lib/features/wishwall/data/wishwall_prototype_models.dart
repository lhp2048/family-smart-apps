/// 心愿墙原型：单条心愿卡片数据（仅详情页使用；首页入口不展示列表摘要）。
class WishwallItem {
  const WishwallItem({
    required this.id,
    required this.memberCode,
    required this.content,
    required this.cardEmoji,
    required this.fulfilled,
    required this.createdAtLabel,
    this.displayName,
  });

  final String id;
  final String memberCode;
  final String content;
  final String cardEmoji;
  final bool fulfilled;
  final String createdAtLabel;
  /// 接口 `displayName`；非空时优先于成员列表展示
  final String? displayName;
}
