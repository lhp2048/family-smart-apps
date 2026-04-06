import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/shell_screen_header.dart';
import '../data/syllable_sheet_preview_args.dart';
import '../services/syllable_sheet_share_service.dart';

/// 全屏预览练习卷 PNG，支持双指缩放平移、保存与分享
class SyllableSheetPreviewPage extends StatefulWidget {
  const SyllableSheetPreviewPage({
    super.key,
    required this.title,
    required this.imageBytes,
  });

  final String title;
  final Uint8List imageBytes;

  factory SyllableSheetPreviewPage.fromArgs(SyllableSheetPreviewArgs args) {
    return SyllableSheetPreviewPage(
      title: args.title,
      imageBytes: args.pngBytes,
    );
  }

  @override
  State<SyllableSheetPreviewPage> createState() => _SyllableSheetPreviewPageState();
}

class _SyllableSheetPreviewPageState extends State<SyllableSheetPreviewPage> {
  bool _saving = false;
  bool _sharing = false;
  final GlobalKey _shareButtonKey = GlobalKey();

  bool get _anyBusy => _saving || _sharing;

  Future<void> _onSave() async {
    setState(() => _saving = true);
    try {
      final msg = await SyllableSheetShareService.savePng(
        bytes: widget.imageBytes,
        title: widget.title,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败：$e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Rect? _shareAnchorRect() {
    final ctx = _shareButtonKey.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    final topLeft = box.localToGlobal(Offset.zero);
    return topLeft & box.size;
  }

  Future<void> _onShare() async {
    setState(() => _sharing = true);
    try {
      await SyllableSheetShareService.sharePng(
        bytes: widget.imageBytes,
        title: widget.title,
        sharePositionOrigin: _shareAnchorRect(),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('分享失败：$e')),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  void _showExportHelp() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF2A2A32),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '导出与分享',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '「保存」：将图片写入相册（手机）或下载/文档目录（电脑）。\n\n'
                '「分享」：打开系统分享面板，可在列表中选择微信、QQ、电子邮件等已安装应用发送图片。',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShellScreenHeader(
              onBack: () => context.pop(),
              icon: Icons.description_rounded,
              title: widget.title,
              iconColor: Colors.white70,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: '保存图片',
                    visualDensity: VisualDensity.compact,
                    color: Colors.white70,
                    onPressed: _anyBusy ? null : _onSave,
                    icon: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white54,
                            ),
                          )
                        : const Icon(Icons.download_rounded),
                  ),
                  IconButton(
                    key: _shareButtonKey,
                    tooltip: '分享（微信、QQ、邮件等）',
                    visualDensity: VisualDensity.compact,
                    color: Colors.white70,
                    onPressed: _anyBusy ? null : _onShare,
                    icon: _sharing
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white54,
                            ),
                          )
                        : const Icon(Icons.share_rounded),
                  ),
                  IconButton(
                    tooltip: '说明',
                    visualDensity: VisualDensity.compact,
                    color: Colors.white54,
                    onPressed: _anyBusy ? null : _showExportHelp,
                    icon: const Icon(Icons.help_outline_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: InteractiveViewer(
                minScale: 0.35,
                maxScale: 4,
                boundaryMargin: const EdgeInsets.all(120),
                child: Center(
                  child: Image.memory(
                    widget.imageBytes,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
