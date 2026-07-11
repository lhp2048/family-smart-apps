import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/pdf_load_progress.dart';

class EbookPdfLoadingPanel extends StatelessWidget {
  const EbookPdfLoadingPanel({
    super.key,
    required this.progress,
  });

  final PdfLoadProgress progress;

  @override
  Widget build(BuildContext context) {
    final percent = progress.percent.clamp(0, 100);
    return ColoredBox(
      color: AppTheme.shellBackground,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: percent / 100,
                        strokeWidth: 4,
                        color: const Color(0xFF7C9EFF),
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                      ),
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          color: Color(0xFFE8E8E8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  progress.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: percent / 100,
                    minHeight: 4,
                    color: const Color(0xFF7C9EFF),
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
