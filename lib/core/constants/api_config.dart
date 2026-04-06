/// 未在设置中保存服务器时，内置为空（不预置任何测试地址）。
///
/// 用户在设置中只填写站点根，例如 `http://192.168.2.11:18024`；
/// 实际请求基址为 `{origin}/api/v1`，成员校验为 `GET {origin}/api/v1/members`。
const String kFamilyApiDefaultOrigin = '';
