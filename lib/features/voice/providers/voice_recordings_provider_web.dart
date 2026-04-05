import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/voice_recording_item.dart';

class VoiceRecordingsNotifier extends Notifier<List<VoiceRecordingItem>> {
  @override
  List<VoiceRecordingItem> build() => [];

  Future<void> commitFromTemp(String tempPath, Duration duration) async {}

  Future<void> discardTemp(String tempPath) async {}
}

final voiceRecordingsProvider =
    NotifierProvider<VoiceRecordingsNotifier, List<VoiceRecordingItem>>(
  VoiceRecordingsNotifier.new,
);
