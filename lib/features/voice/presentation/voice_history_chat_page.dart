import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../data/voice_recording_item.dart';
import '../providers/voice_recordings_provider.dart';
import '../voice_playback_helper.dart';

String _formatDuration(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (d.inHours > 0) {
    return '${d.inHours}:$m:$s';
  }
  return '$m:$s';
}

String _formatTime(DateTime t) {
  return '${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')} '
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

class VoiceHistoryChatPage extends ConsumerStatefulWidget {
  const VoiceHistoryChatPage({super.key});

  @override
  ConsumerState<VoiceHistoryChatPage> createState() =>
      _VoiceHistoryChatPageState();
}

class _VoiceHistoryChatPageState extends ConsumerState<VoiceHistoryChatPage> {
  final AudioPlayer _player = AudioPlayer();
  String? _playingId;
  StreamSubscription<void>? _completeSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;

  Duration _playPosition = Duration.zero;
  Duration _playTotal = Duration.zero;

  @override
  void initState() {
    super.initState();
    _completeSub = _player.onPlayerComplete.listen((_) {
      _clearPlaybackTicks();
      if (mounted) setState(() => _playingId = null);
    });
  }

  @override
  void dispose() {
    final sub = _completeSub;
    if (sub != null) unawaited(sub.cancel());
    unawaited(_positionSub?.cancel() ?? Future.value());
    unawaited(_durationSub?.cancel() ?? Future.value());
    _player.dispose();
    super.dispose();
  }

  void _clearPlaybackTicks() {
    unawaited(_positionSub?.cancel() ?? Future.value());
    unawaited(_durationSub?.cancel() ?? Future.value());
    _positionSub = null;
    _durationSub = null;
    _playPosition = Duration.zero;
    _playTotal = Duration.zero;
  }

  void _attachProgressStreams(String itemId) {
    unawaited(_positionSub?.cancel() ?? Future.value());
    unawaited(_durationSub?.cancel() ?? Future.value());
    _positionSub = _player.onPositionChanged.listen((pos) {
      if (!mounted || _playingId != itemId) return;
      setState(() => _playPosition = pos);
    });
    _durationSub = _player.onDurationChanged.listen((dur) {
      if (!mounted || _playingId != itemId) return;
      if (dur > Duration.zero) {
        setState(() => _playTotal = dur);
      }
    });
  }

  Duration _remainingForItem(VoiceRecordingItem item, bool playing) {
    if (!playing) return item.duration;
    final total = _playTotal > Duration.zero ? _playTotal : item.duration;
    var r = total - _playPosition;
    if (r.isNegative) r = Duration.zero;
    return r;
  }

  double? _progressForItem(VoiceRecordingItem item, bool playing) {
    if (!playing) return null;
    final totalMs = (_playTotal > Duration.zero ? _playTotal : item.duration)
        .inMilliseconds;
    if (totalMs <= 0) return null;
    final v = _playPosition.inMilliseconds / totalMs;
    return v.clamp(0.0, 1.0);
  }

  Future<void> _play(VoiceRecordingItem item) async {
    if (_playingId == item.id) {
      _clearPlaybackTicks();
      await _player.stop();
      if (mounted) setState(() => _playingId = null);
      return;
    }
    _clearPlaybackTicks();
    await _player.stop();
    if (!mounted) return;

    setState(() {
      _playingId = item.id;
      _playPosition = Duration.zero;
      _playTotal = item.duration;
    });
    _attachProgressStreams(item.id);

    final ok = await playVoiceFile(
      _player,
      item.filePath,
      onError: (m) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
      },
    );
    if (!ok) {
      _clearPlaybackTicks();
      if (mounted) setState(() => _playingId = null);
      return;
    }

    final d = await _player.getDuration();
    if (mounted &&
        _playingId == item.id &&
        d != null &&
        d > Duration.zero) {
      setState(() => _playTotal = d);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(voiceRecordingsProvider);
    final colors = context.appColors;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('语音记录'),
      ),
      body: items.isEmpty
          ? Center(
              child: Text(
                '暂无录音\n长按底部麦克风可录制',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[items.length - 1 - index];
                final playing = _playingId == item.id;
                final remaining = _remainingForItem(item, playing);
                final progress = _progressForItem(item, playing);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _play(item),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  playing
                                      ? Icons.stop_circle_outlined
                                      : Icons.play_circle_fill_rounded,
                                  color: primary,
                                  size: 40,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '语音消息',
                                    style: TextStyle(
                                      color: colors.onSurface,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      playing
                                          ? _formatDuration(remaining)
                                          : _formatDuration(item.duration),
                                      style: TextStyle(
                                        color: playing
                                            ? primary
                                            : colors.onSurfaceVariant,
                                        fontWeight: FontWeight.w700,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                        fontSize: 18,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    if (playing)
                                      Text(
                                        '剩余',
                                        style: TextStyle(
                                          color: colors.onSurfaceVariant,
                                          fontSize: 11,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatTime(item.createdAt),
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                            if (playing && progress != null) ...[
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 4,
                                  backgroundColor:
                                      colors.onSurfaceVariant.withValues(
                                    alpha: 0.15,
                                  ),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    primary.withValues(alpha: 0.85),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
