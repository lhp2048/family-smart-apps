import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Web：无全局按住说话（避免 dart:io / 原生录音依赖）
class GlobalMicOverlay extends ConsumerWidget {
  const GlobalMicOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}
