/// 规范化 API KEY：去首尾空白、BOM/零宽字符，并去掉用户误粘贴的 `X-API-Key:` / `Bearer ` 前缀。
///
/// 值作为请求头 `X-API-Key` 发送。
String normalizeBearerSecret(String raw) {
  var s = raw.trim();
  s = s.replaceAll(RegExp(r'[\uFEFF\u200B\u200C\u200D]'), '');
  s = s.trim();
  if (s.isEmpty) return '';
  if (s.toLowerCase().startsWith('x-api-key:')) {
    s = s.substring('x-api-key:'.length).trim();
  }
  if (s.length >= 7 && s.substring(0, 7).toLowerCase() == 'bearer ') {
    s = s.substring(7).trim();
  }
  return s;
}
