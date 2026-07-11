/// PDF 阅读器加载阶段与整体进度（0–100）。
enum PdfLoadStage {
  engine,
  download,
  stream,
  document,
  pageRender,
  done,
  error,
}

class PdfLoadProgress {
  const PdfLoadProgress({
    required this.stage,
    required this.percent,
    required this.message,
  });

  const PdfLoadProgress.initial()
      : stage = PdfLoadStage.engine,
        percent = 0,
        message = '正在初始化…';

  final PdfLoadStage stage;
  final int percent;
  final String message;

  bool get isComplete => stage == PdfLoadStage.done;
  bool get isError => stage == PdfLoadStage.error;

  PdfLoadProgress copyWith({
    PdfLoadStage? stage,
    int? percent,
    String? message,
  }) {
    return PdfLoadProgress(
      stage: stage ?? this.stage,
      percent: percent ?? this.percent,
      message: message ?? this.message,
    );
  }
}

String formatByteProgress(int received, int? total) {
  if (total != null && total > 0) {
    return '${_formatBytes(received)} / ${_formatBytes(total)}';
  }
  return _formatBytes(received);
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

/// 各阶段在总进度条上的权重区间。
int mapDownloadPercent(int received, int? total) {
  const start = 12;
  const span = 60;
  if (total != null && total > 0) {
    final ratio = (received / total).clamp(0.0, 1.0);
    return start + (ratio * span).round();
  }
  // 无 Content-Length 时用已下载量估算，上限 72%。
  final heuristic = start + (received ~/ (256 * 1024));
  return heuristic.clamp(start, start + span);
}

/// 流式 URL 加载阶段（pdf.js onProgress）在总进度条上的区间：15–60%。
/// 按已拉取字节估算，不用 loaded/total 比例（避免暗示必须下完全书）。
int mapStreamPercent(int loaded, int total) {
  const start = 15;
  const span = 45;
  final heuristic = start + (loaded ~/ (512 * 1024));
  return heuristic.clamp(start, start + span);
}

/// 将 pdf.js / 网络层异常转为用户可读文案。
String formatPdfOpenError(Object error) {
  final raw = error.toString();
  final lower = raw.toLowerCase();

  if (lower.contains('pdfjs') ||
      lower.contains('pdf.min.mjs') ||
      lower.contains('pdfjs library not loaded')) {
    return 'PDF 引擎（pdf.js）加载失败：请检查网络、广告拦截扩展，或刷新后重试';
  }
  if (lower.contains('platformnotsupported') ||
      lower.contains('actual platform not supported')) {
    return 'PDF 引擎未在 Web 端初始化，请刷新页面；若仍失败请重新部署 Apps Web';
  }
  if (lower.contains('failed to fetch') ||
      lower.contains('networkerror') ||
      lower.contains('connection refused') ||
      lower.contains('err_connection')) {
    return '无法连接 PDF 文件，请确认 mediacenter 已启动（:18026）且网络正常';
  }
  if (lower.contains('cors')) {
    return '跨域访问被拒绝，请检查 mediacenter CORS 是否允许当前页面源';
  }
  if (lower.contains('404') || lower.contains('not found')) {
    return 'PDF 文件不存在或已被移除';
  }
  if (lower.contains('401') || lower.contains('403') || lower.contains('forbidden')) {
    return '无权访问该 PDF 文件';
  }
  if (lower.contains('502') || lower.contains('503') || lower.contains('bad gateway')) {
    return 'mediacenter 服务不可用，请稍后重试';
  }
  if (lower.contains('password') || lower.contains('encrypted')) {
    return '该 PDF 需要密码或已加密，暂不支持';
  }

  const prefixes = ['Exception: ', 'StateError: ', 'ArgumentError: '];
  for (final prefix in prefixes) {
    if (raw.startsWith(prefix)) {
      return raw.substring(prefix.length);
    }
  }
  return raw.isNotEmpty ? raw : 'PDF 文档打开失败';
}
