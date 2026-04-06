import 'package:flutter/material.dart';

/// 子页统一顶栏：返回 + 居中「图标 + 标题」一行，无独立背景（随 [Scaffold] 壳色）。
class ShellScreenHeader extends StatelessWidget {
  const ShellScreenHeader({
    super.key,
    required this.onBack,
    required this.icon,
    required this.title,
    this.iconColor,
    this.trailing,
  });

  final VoidCallback onBack;
  final IconData icon;
  final String title;
  final Color? iconColor;
  /// 右侧操作区（与左侧返回同宽占位对齐）；为 null 时保留空白占位。
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ic = iconColor ?? Colors.white.withValues(alpha: 0.95);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 8, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: Colors.white70,
            visualDensity: VisualDensity.compact,
            onPressed: onBack,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: ic, size: 24),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          trailing ??
              const SizedBox(
                width: 48,
                height: 48,
              ),
        ],
      ),
    );
  }
}
