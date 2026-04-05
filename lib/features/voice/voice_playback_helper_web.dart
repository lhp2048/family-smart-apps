import 'package:audioplayers/audioplayers.dart';

AudioContext voicePlaybackAudioContext() => AudioContext();

Future<bool> playVoiceFile(
  AudioPlayer player,
  String path, {
  void Function(String message)? onError,
}) async {
  onError?.call('当前平台不支持本地文件播放');
  return false;
}
