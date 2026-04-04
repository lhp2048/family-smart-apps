import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../data/voice_recording_item.dart';

class VoiceRecordingsNotifier extends Notifier<List<VoiceRecordingItem>> {
  late final Future<void> _ready = _loadPersisted();

  @override
  List<VoiceRecordingItem> build() {
    unawaited(_ready);
    return [];
  }

  Future<Directory> _voiceDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final voiceDir = Directory('${dir.path}/voice_recordings');
    if (!await voiceDir.exists()) {
      await voiceDir.create(recursive: true);
    }
    return voiceDir;
  }

  Future<void> _loadPersisted() async {
    if (kIsWeb) return;
    try {
      final voiceDir = await _voiceDir();
      final indexFile = File('${voiceDir.path}/index.json');
      if (!await indexFile.exists()) return;
      final raw = await indexFile.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      final list = <VoiceRecordingItem>[];
      for (final e in decoded) {
        if (e is! Map) continue;
        final item = VoiceRecordingItem.fromJson(
          Map<String, dynamic>.from(e),
          voiceDir.path,
        );
        if (item != null && await File(item.filePath).exists()) {
          list.add(item);
        }
      }
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      state = list;
    } catch (_) {
      // 损坏时保持空列表，避免启动崩溃
    }
  }

  Future<void> _saveIndex() async {
    if (kIsWeb) return;
    final voiceDir = await _voiceDir();
    final indexFile = File('${voiceDir.path}/index.json');
    final encoded = jsonEncode(state.map((e) => e.toJson()).toList());
    await indexFile.writeAsString(encoded);
  }

  /// 将临时文件移入应用目录并加入本地聊天记录（点「发送」时调用）
  Future<void> commitFromTemp(String tempPath, Duration duration) async {
    if (kIsWeb) return;
    await _ready;
    final temp = File(tempPath);
    if (!await temp.exists()) return;
    final voiceDir = await _voiceDir();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final ext = tempPath.contains('.wav') ? 'wav' : 'm4a';
    final target = File('${voiceDir.path}/$id.$ext');
    await temp.copy(target.path);
    await temp.delete();
    state = [
      ...state,
      VoiceRecordingItem(
        id: id,
        filePath: target.path,
        createdAt: DateTime.now(),
        duration: duration,
      ),
    ];
    await _saveIndex();
  }

  Future<void> discardTemp(String tempPath) async {
    if (kIsWeb) return;
    final f = File(tempPath);
    if (await f.exists()) await f.delete();
  }
}

final voiceRecordingsProvider =
    NotifierProvider<VoiceRecordingsNotifier, List<VoiceRecordingItem>>(
  VoiceRecordingsNotifier.new,
);
