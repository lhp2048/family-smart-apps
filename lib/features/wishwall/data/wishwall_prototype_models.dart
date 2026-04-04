/// 心愿墙原型：单条心愿卡片数据
class WishwallItem {
  const WishwallItem({
    required this.id,
    required this.memberCode,
    required this.content,
    required this.cardEmoji,
    required this.fulfilled,
    required this.createdAtLabel,
  });

  final String id;
  final String memberCode;
  final String content;
  /// 卡片左上角大表情
  final String cardEmoji;
  final bool fulfilled;
  final String createdAtLabel;
}
