import 'package:flutter/foundation.dart' show kIsWeb;

/// 产品形态开关（集中在一处，便于日后恢复编辑能力）。
///
/// 为 `true` 时：隐藏全局语音按钮；作业进度页不可勾选，仅展示数据。
/// 业务数据由 OpenClaw 等外部服务维护时，可保持只读 App。
const bool kAppReadOnlyDataMode = false;

/// Web 自动只读；移动端由 [kAppReadOnlyDataMode] 控制。
bool get kEffectiveReadOnlyDataMode => kAppReadOnlyDataMode || kIsWeb;
