import 'package:path/path.dart' as p;

class VoiceRecordingItem {
  const VoiceRecordingItem({
    required this.id,
    required this.filePath,
    required this.createdAt,
    required this.duration,
  });

  final String id;
  final String filePath;
  final DateTime createdAt;
  final Duration duration;

  String get fileName => p.basename(filePath);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': fileName,
        'createdAt': createdAt.toIso8601String(),
        'durationMs': duration.inMilliseconds,
      };

  /// [voiceDirPath] 为 `voice_recordings` 目录的绝对路径。
  static VoiceRecordingItem? fromJson(
    Map<String, dynamic> json,
    String voiceDirPath,
  ) {
    final id = json['id'] as String?;
    final name = json['name'] as String?;
    if (id == null || name == null) return null;
    final filePath = p.join(voiceDirPath, name);
    final createdRaw = json['createdAt'] as String?;
    if (createdRaw == null) return null;
    final createdAt = DateTime.tryParse(createdRaw);
    if (createdAt == null) return null;
    final dm = json['durationMs'];
    final durationMs = dm is int ? dm : (dm is num ? dm.round() : 0);
    return VoiceRecordingItem(
      id: id,
      filePath: filePath,
      createdAt: createdAt,
      duration: Duration(milliseconds: durationMs),
    );
  }
}
