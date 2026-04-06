import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_theme.dart';

/// 扫描二维码，解析出含 `http(s)://` 的字符串后 `pop` 返回。
class ServerOriginQrScanPage extends StatefulWidget {
  const ServerOriginQrScanPage({super.key});

  @override
  State<ServerOriginQrScanPage> createState() => _ServerOriginQrScanPageState();
}

class _ServerOriginQrScanPageState extends State<ServerOriginQrScanPage> {
  final MobileScannerController _controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
  );

  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled || !mounted) return;
    for (final b in capture.barcodes) {
      final raw = b.rawValue;
      if (raw == null || raw.isEmpty) continue;
      final url = extractHttpUrlFromQrPayload(raw);
      if (url != null) {
        _handled = true;
        _controller.stop();
        Navigator.of(context).pop(url);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.shellBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.shellBackground,
        foregroundColor: Colors.white,
        title: const Text('扫描服务器地址'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 48,
            child: Text(
              '将二维码对准框内，需包含 http:// 或 https:// 地址',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 14,
                shadows: const [
                  Shadow(blurRadius: 8, color: Colors.black87),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 从扫码原文中提取一段 URL（支持整段为 URL，或文本中嵌入的 URL）。
String? extractHttpUrlFromQrPayload(String raw) {
  var s = raw.trim();
  final m = RegExp(r'https?://[^\s<>"{}|\\^`\[\]]+').firstMatch(s);
  if (m != null) {
    s = m.group(0)!;
  }
  s = s.split('"').first.trim();
  if (s.startsWith('http://') || s.startsWith('https://')) {
    return s;
  }
  return null;
}
