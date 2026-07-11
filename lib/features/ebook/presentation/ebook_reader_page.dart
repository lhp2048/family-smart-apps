import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shell_screen_header.dart';
import '../../dashboard/providers/family_api_base_url_provider.dart';
import '../data/ebook_models.dart';
import 'reader/ebook_native_reader_view.dart';

class EbookReaderPage extends ConsumerWidget {
  const EbookReaderPage({
    super.key,
    required this.subPath,
    required this.title,
    required this.fileUrl,
    required this.kind,
  });

  final String subPath;
  final String title;
  final String fileUrl;
  final EbookKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final origin = ref.watch(familyMediacenterOriginSyncProvider);
    final resolvedUrl = resolveEbookFileUrl(
      publicUrl: fileUrl,
      subPath: subPath,
      mediacenterOrigin: origin,
    );

    return Scaffold(
      backgroundColor: AppTheme.shellBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShellScreenHeader(
              onBack: () => context.pop(),
              icon: Icons.menu_book_rounded,
              title: title.isEmpty ? '阅读' : title,
            ),
            Expanded(
              child: resolvedUrl.isEmpty
                  ? Center(
                      child: Text(
                        '文件地址无效或未连接 mediacenter',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    )
                  : EbookNativeReaderView(
                      fileUrl: resolvedUrl,
                      kind: kind,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

String resolveEbookFileUrl({
  required String publicUrl,
  required String subPath,
  required String mediacenterOrigin,
}) {
  final trimmed = publicUrl.trim();
  if (trimmed.isNotEmpty) return trimmed;
  if (mediacenterOrigin.isEmpty || subPath.isEmpty) return '';
  final origin = mediacenterOrigin.replaceAll(RegExp(r'/+$'), '');
  final encodedPath = subPath
      .split('/')
      .where((part) => part.isNotEmpty)
      .map(Uri.encodeComponent)
      .join('/');
  return '$origin/files/ebooks/$encodedPath';
}
