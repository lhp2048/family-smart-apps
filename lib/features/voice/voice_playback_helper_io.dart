import 'dart:io' show File, Platform;

import 'package:audioplayers/audioplayers.dart';

/// 录音后系统常停留在通信音频模式，MediaPlayer 会从听筒输出或几乎听不到声；
/// 同时本地 m4a 建议带上 MIME，避免部分机型无法解码。
AudioContext voicePlaybackAudioContext() {
  if (Platform.isAndroid) {
    return AudioContext(
      android: const AudioContextAndroid(
        isSpeakerphoneOn: true,
        audioMode: AndroidAudioMode.normal,
        contentType: AndroidContentType.speech,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gain,
      ),
    );
  }
  if (Platform.isIOS) {
    return AudioContextConfig(
      route: AudioContextConfigRoute.speaker,
      focus: AudioContextConfigFocus.gain,
    ).build();
  }
  return AudioContext();
}

String? _mimeForPath(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.wav')) return 'audio/wav';
  if (lower.endsWith('.m4a') ||
      lower.endsWith('.aac') ||
      lower.endsWith('.mp4')) {
    return 'audio/mp4';
  }
  return null;
}

/// 播放本地录音文件；失败时调用 [onError]（简短文案，适合 SnackBar）。
Future<bool> playVoiceFile(
  AudioPlayer player,
  String path, {
  void Function(String message)? onError,
}) async {
  final file = File(path);
  if (!await file.exists()) {
    onError?.call('录音文件不存在');
    return false;
  }
  if (await file.length() < 64) {
    onError?.call('录音文件无效或过短');
    return false;
  }

  try {
    if (Platform.isAndroid || Platform.isIOS) {
      await player.setAudioContext(voicePlaybackAudioContext());
    }
    await player.play(DeviceFileSource(path, mimeType: _mimeForPath(path)));
    return true;
  } catch (e, _) {
    onError?.call('无法播放，请稍后再试');
    return false;
  }
}
