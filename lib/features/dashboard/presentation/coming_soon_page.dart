import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shell_screen_header.dart';

/// 原型中尚未实现的模块占位
class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({
    super.key,
    required this.title,
    this.icon = Icons.construction_rounded,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.shellBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShellScreenHeader(
              onBack: () => context.pop(),
              icon: icon,
              title: title,
            ),
            Expanded(
              child: Center(
                child: Text(
                  '$title\n敬请期待',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
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
