import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';

/// 标签 / 筛选项
class AppTag extends StatelessWidget {
  const AppTag({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.primary.withValues(alpha: 0.25) : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: selected ? scheme.primary : null,
                  fontWeight: selected ? FontWeight.w600 : null,
                ),
          ),
        ),
      ),
    );
  }
}
