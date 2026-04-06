/// 规范化用户输入的站点根：仅保留 `scheme://host:port`，不含路径。
///
/// 示例：`http://192.168.2.11:18024`、自动补 `http://`。
String normalizeFamilyApiOrigin(String input) {
  var s = input.trim();
  if (s.isEmpty) {
    throw FormatException('服务器地址不能为空');
  }
  if (!s.startsWith('http://') && !s.startsWith('https://')) {
    s = 'http://$s';
  }
  final uri = Uri.parse(s);
  if (!uri.hasScheme || uri.host.isEmpty) {
    throw FormatException('地址无效，请使用 http://IP或域名:端口');
  }
  return uri.origin;
}

/// 由站点根得到 v1 API 基址。
///
/// **末尾必须带 `/`**：Dio 用 URI 解析拼接相对路径时，若基址为 `.../api/v1`（无斜杠），
/// 相对路径 `members` 会被解析成 `.../api/members`（错误 404），而非 `.../api/v1/members`。
String familyOriginToApiV1Base(String origin) {
  final o = origin.trim();
  if (o.isEmpty) return '';
  final noSlash = o.endsWith('/') ? o.substring(0, o.length - 1) : o;
  return '$noSlash/api/v1/';
}

/// 供 Dio 使用：已配置则返回 `/api/v1` 基址，否则 `null`（表示未配置）。
String? effectiveFamilyApiV1Base(String? storedOrigin) {
  final o = storedOrigin?.trim() ?? '';
  if (o.isEmpty) return null;
  return familyOriginToApiV1Base(o);
}

/// 未配置站点时的占位基址（避免 Dio 构造异常；业务层应先判断再请求）。
const String kFamilyApiUnsetV1Placeholder = 'http://0.0.0.0:9/api/v1/';
