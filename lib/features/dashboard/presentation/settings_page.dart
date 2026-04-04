import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 设置（占位，后续可接主题、通知、关于等）
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Text(
            '更多选项即将开放',
            style: TextStyle(color: muted, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
