import 'dart:async';
import 'dart:io' show File, Platform;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../../app/router.dart';
import '../providers/voice_recordings_provider.dart';
import '../voice_playback_helper.dart';

const Duration _kHoldToRecord = Duration(milliseconds: 380);
const double _kMicSize = 58;
const double _kScaleEnd = 1.12;

String _fmtMmSs(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (d.inHours > 0) {
    return '${d.inHours}:$m:$s';
  }
  return '$m:$s';
}

class GlobalMicOverlay extends ConsumerStatefulWidget {
  const GlobalMicOverlay({super.key});

  @override
  ConsumerState<GlobalMicOverlay> createState() => _GlobalMicOverlayState();
}

class _GlobalMicOverlayState extends ConsumerState<GlobalMicOverlay>
    with TickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _previewPlayer = AudioPlayer();

  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  Timer? _holdTimer;
  Timer? _recordUiTimer;
  bool _pointerDown = false;
  bool _recording = false;
  String? _currentTempPath;
  String? _lastPath;
  Duration _lastDuration = Duration.zero;
  bool _showActions = false;
  final Stopwatch _sw = Stopwatch();

  bool _previewPlaying = false;
  Duration _previewPosition = Duration.zero;
  Duration _previewTotal = Duration.zero;
  StreamSubscription<Duration>? _previewPosSub;
  StreamSubscription<Duration>? _previewDurSub;
  StreamSubscription<void>? _previewCompleteSub;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _scaleAnim = Tween<double>(begin: 1, end: _kScaleEnd).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOutCubic),
    );
    _previewCompleteSub = _previewPlayer.onPlayerComplete.listen((_) {
      _clearPreviewProgressSubs();
      if (mounted) {
        setState(() {
          _previewPlaying = false;
          _previewPosition = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _recordUiTimer?.cancel();
    _clearPreviewProgressSubs();
    unawaited(_previewCompleteSub?.cancel() ?? Future.value());
    _scaleCtrl.dispose();
    _previewPlayer.dispose();
    unawaited(_recorder.dispose());
    super.dispose();
  }

  void _clearPreviewProgressSubs() {
    unawaited(_previewPosSub?.cancel() ?? Future.value());
    unawaited(_previewDurSub?.cancel() ?? Future.value());
    _previewPosSub = null;
    _previewDurSub = null;
  }

  void _startRecordUiTicker() {
    _recordUiTimer?.cancel();
    _recordUiTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted && _recording) setState(() {});
    });
  }

  void _stopRecordUiTicker() {
    _recordUiTimer?.cancel();
    _recordUiTimer = null;
  }

  void _snack(String text) {
    final m = ScaffoldMessenger.maybeOf(context);
    m?.showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _startRecording() async {
    if (_recording) return;
    if (kIsWeb) {
      _snack('当前平台暂不支持录音');
      return;
    }
    final perm = await Permission.microphone.request();
    if (!perm.isGranted) {
      _snack('需要麦克风权限才能录音');
      return;
    }
    final allowed = await _recorder.hasPermission();
    if (allowed != true) {
      _snack('无法访问麦克风');
      return;
    }
    final dir = await getTemporaryDirectory();
    final useWav =
        Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    final ext = useWav ? 'wav' : 'm4a';
    final path =
        '${dir.path}/voice_cap_${DateTime.now().millisecondsSinceEpoch}.$ext';
    try {
      await _recorder.start(
        RecordConfig(
          encoder: useWav ? AudioEncoder.wav : AudioEncoder.aacLc,
        ),
        path: path,
      );
      if (!mounted) return;
      setState(() {
        _recording = true;
        _currentTempPath = path;
        _showActions = false;
      });
      _sw.reset();
      _sw.start();
      _startRecordUiTicker();
      _scaleCtrl.forward();
    } catch (_) {
      _snack('录音启动失败');
    }
  }

  Future<void> _finishRecordingSession() async {
    _holdTimer?.cancel();
    _stopRecordUiTicker();
    _sw.stop();
    final elapsed = _sw.elapsed;
    _sw.reset();

    String? path;
    if (_recording) {
      try {
        path = await _recorder.stop();
      } catch (_) {
        path = _currentTempPath;
      }
    }
    path ??= _currentTempPath;

    await _scaleCtrl.reverse();

    if (!mounted) return;

    setState(() {
      _recording = false;
      _currentTempPath = null;
    });

    if (path == null || elapsed < const Duration(milliseconds: 280)) {
      if (path != null && File(path).existsSync()) {
        await ref.read(voiceRecordingsProvider.notifier).discardTemp(path);
      }
      setState(() {
        _showActions = false;
        _lastPath = null;
        _previewPlaying = false;
        _previewPosition = Duration.zero;
      });
      _clearPreviewProgressSubs();
      return;
    }

    setState(() {
      _lastPath = path;
      _lastDuration = elapsed;
      _showActions = true;
      _previewPlaying = false;
      _previewPosition = Duration.zero;
      _previewTotal = elapsed;
    });
    _clearPreviewProgressSubs();
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointerDown = true;
    _holdTimer?.cancel();
    _holdTimer = Timer(_kHoldToRecord, () {
      if (_pointerDown && mounted) {
        unawaited(_startRecording());
      }
    });
  }

  void _onPointerUpEvent(PointerUpEvent event) {
    _pointerDown = false;
    _holdTimer?.cancel();
    if (_recording) {
      unawaited(_finishRecordingSession());
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _pointerDown = false;
    _holdTimer?.cancel();
    if (_recording) {
      unawaited(_finishRecordingSession());
    }
  }

  void _onDoubleTap() {
    if (_recording) return;
    final navCtx = rootNavigatorKey.currentContext;
    if (navCtx != null && navCtx.mounted) {
      navCtx.push('/voice-history');
    }
  }

  Future<void> _playPreview() async {
    final p = _lastPath;
    if (p == null || !File(p).existsSync()) return;
    if (_previewPlaying) {
      await _previewPlayer.stop();
      _clearPreviewProgressSubs();
      if (mounted) {
        setState(() {
          _previewPlaying = false;
          _previewPosition = Duration.zero;
        });
      }
      return;
    }
    await _previewPlayer.stop();
    _clearPreviewProgressSubs();
    if (!mounted) return;
    setState(() {
      _previewPlaying = true;
      _previewPosition = Duration.zero;
      _previewTotal = _lastDuration;
    });
    _previewPosSub = _previewPlayer.onPositionChanged.listen((pos) {
      if (!mounted || !_previewPlaying) return;
      setState(() => _previewPosition = pos);
    });
    _previewDurSub = _previewPlayer.onDurationChanged.listen((dur) {
      if (!mounted || !_previewPlaying) return;
      if (dur > Duration.zero) setState(() => _previewTotal = dur);
    });

    final ok = await playVoiceFile(
      _previewPlayer,
      p,
      onError: _snack,
    );
    if (!ok) {
      _clearPreviewProgressSubs();
      if (mounted) {
        setState(() {
          _previewPlaying = false;
          _previewPosition = Duration.zero;
        });
      }
      return;
    }
    final d = await _previewPlayer.getDuration();
    if (mounted &&
        _previewPlaying &&
        d != null &&
        d > Duration.zero) {
      setState(() => _previewTotal = d);
    }
  }

  Future<void> _cancelRecording() async {
    final p = _lastPath;
    await _previewPlayer.stop();
    _clearPreviewProgressSubs();
    if (mounted) {
      setState(() {
        _showActions = false;
        _lastPath = null;
        _previewPlaying = false;
        _previewPosition = Duration.zero;
      });
    }
    if (p != null) {
      await ref.read(voiceRecordingsProvider.notifier).discardTemp(p);
    }
  }

  Future<void> _sendRecording() async {
    final p = _lastPath;
    final d = _lastDuration;
    if (p == null) return;
    await _previewPlayer.stop();
    _clearPreviewProgressSubs();
    if (mounted) {
      setState(() {
        _showActions = false;
        _lastPath = null;
        _previewPlaying = false;
        _previewPosition = Duration.zero;
      });
    }
    _snack('已保存到本地语音记录');
    await ref.read(voiceRecordingsProvider.notifier).commitFromTemp(p, d);
  }

  static BoxDecoration _voiceCardDecoration() {
    return BoxDecoration(
      color: const Color(0xFF1E1E28).withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.1),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  /// 录音进行中：单独一块计时卡片（在麦克风上方）
  Widget _buildRecordingCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: _voiceCardDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF5252),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _fmtMmSs(_sw.elapsed),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                  letterSpacing: 0.6,
                  fontFeatures: [FontFeature.tabularFigures()],
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '录音中…',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 12,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  /// 录音完成后：时间与「播放 / 取消 / 发送」同处一块卡片内
  Widget _buildPostRecordCard(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    Duration mainTime;
    String hint;
    bool showCountdownStyle = false;
    double? progress;

    if (_previewPlaying) {
      final total =
          _previewTotal > Duration.zero ? _previewTotal : _lastDuration;
      var rem = total - _previewPosition;
      if (rem.isNegative) rem = Duration.zero;
      mainTime = rem;
      hint = '剩余时间';
      showCountdownStyle = true;
      final tm = total.inMilliseconds;
      if (tm > 0) {
        progress =
            (_previewPosition.inMilliseconds / tm).clamp(0.0, 1.0).toDouble();
      }
    } else {
      mainTime = _lastDuration;
      hint = '录音完成 · 可试听或发送';
    }

    final dividerColor = Colors.white.withValues(alpha: 0.08);

    return Container(
      width: double.infinity,
      decoration: _voiceCardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _fmtMmSs(mainTime),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: showCountdownStyle ? primary : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 26,
                    letterSpacing: 0.6,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hint,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                    decoration: TextDecoration.none,
                  ),
                ),
                if (progress != null) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        primary.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: dividerColor),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: _RoundMiniAction(
                      icon: _previewPlaying
                          ? Icons.stop_rounded
                          : Icons.play_arrow_rounded,
                      color: const Color(0xFF66BB6A),
                      onTap: _playPreview,
                    ),
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: dividerColor,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _RoundMiniAction(
                      icon: Icons.close_rounded,
                      color: const Color(0xFFEF5350),
                      onTap: _cancelRecording,
                    ),
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: dividerColor,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _RoundMiniAction(
                      icon: Icons.send_rounded,
                      color: const Color(0xFF42A5F5),
                      onTap: _sendRecording,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final bottom = 20 + bottomInset + keyboard;

    final micColors = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF7C4DFF),
        Color(0xFF5C6BC0),
      ],
    );

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottom,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_recording) _buildRecordingCard(context),
                    if (_showActions && _lastPath != null && !_recording)
                      _buildPostRecordCard(context),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Listener(
                onPointerDown: _onPointerDown,
                onPointerUp: _onPointerUpEvent,
                onPointerCancel: _onPointerCancel,
                child: GestureDetector(
                  onDoubleTap: _onDoubleTap,
                  behavior: HitTestBehavior.opaque,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: _kMicSize,
                      height: _kMicSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: micColors,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C4DFF)
                                .withValues(alpha: 0.45),
                            blurRadius: _recording ? 18 : 12,
                            spreadRadius: _recording ? 2 : 0,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.mic_rounded,
                        color: Colors.white,
                        size: _recording ? 30 : 28,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundMiniAction extends StatelessWidget {
  const _RoundMiniAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.22),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: color, size: 26),
        ),
      ),
    );
  }
}
