/// 未在设置中保存门户时，内置为空（不预置任何测试地址）。
///
/// 用户在设置中只填写门户根，例如 `http://192.168.2.11:18024`（family_smart_center_web）；
/// App 经 `GET {portal}/api/v1/portal/services` 发现数据中心 `apiBaseUrl`，
/// 再直连 `GET {apiBaseUrl}/members` 校验。
///
/// 请求头 `X-API-Key` 仅在设置「访问API KEY」中配置，不在代码中硬编码。
const String kFamilyPortalDefaultOrigin = '';

/// @deprecated 使用 [kFamilyPortalDefaultOrigin]
const String kFamilyApiDefaultOrigin = kFamilyPortalDefaultOrigin;
