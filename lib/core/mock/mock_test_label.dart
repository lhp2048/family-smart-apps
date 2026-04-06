/// 本地原型 / 未接服务器时，与用户可见文案区分的前缀。
const String kMockDataLabelPrefix = '【测试】';

/// 为展示文案加前缀；已带前缀则不再重复添加。
String mockTestLabel(String text) {
  final t = text.trim();
  if (t.isEmpty) return kMockDataLabelPrefix;
  if (t.startsWith(kMockDataLabelPrefix)) return text;
  return '$kMockDataLabelPrefix$t';
}
