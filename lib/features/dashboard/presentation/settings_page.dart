import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/api_config.dart' show kFamilyApiDefaultOrigin;
import '../../../core/constants/build_stamp.dart' show kAppBuildStamp;
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shell_screen_header.dart';
import '../data/family_api_client.dart';
import '../providers/dashboard_home_title_provider.dart';
import '../providers/dashboard_remote_providers.dart';
import '../providers/family_api_base_url_provider.dart';
import '../../../shared/providers/task_ui_providers.dart';
import 'server_origin_qr_scan_page.dart';

bool get _serverOriginScanSupported =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS);

/// 设置：服务器地址等
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _editingHomeTitle = false;
  bool _editingServer = false;
  bool _validating = false;
  late final TextEditingController _homeTitleCtrl = TextEditingController();
  late final TextEditingController _serverCtrl = TextEditingController();

  @override
  void dispose() {
    _homeTitleCtrl.dispose();
    _serverCtrl.dispose();
    super.dispose();
  }

  void _startEditHomeTitle(String current) {
    setState(() {
      _editingHomeTitle = true;
      _homeTitleCtrl.text = current;
    });
  }

  void _cancelHomeTitle() {
    setState(() => _editingHomeTitle = false);
  }

  Future<void> _saveHomeTitle() async {
    await ref
        .read(dashboardHomeTitleProvider.notifier)
        .persistTitle(_homeTitleCtrl.text);
    if (!mounted) return;
    setState(() => _editingHomeTitle = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('主页标题已保存')),
    );
  }

  void _startEdit(String currentUrl) {
    setState(() {
      _editingServer = true;
      _serverCtrl.text = currentUrl;
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingServer = false;
      _validating = false;
    });
  }

  Future<void> _scanAndApplyServerUrl() async {
    if (!_serverOriginScanSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('当前平台不支持扫码')),
      );
      return;
    }
    final url = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => const ServerOriginQrScanPage(),
      ),
    );
    if (!mounted || url == null || url.isEmpty) return;
    setState(() {
      _editingServer = true;
      _serverCtrl.text = url;
    });
    await _confirmServerUrl();
  }

  Future<void> _confirmServerUrl() async {
    if (_validating) return;
    setState(() => _validating = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await FamilyApiClient.validateServerBaseUrl(_serverCtrl.text);
      await ref
          .read(familyApiOriginNotifierProvider.notifier)
          .persistValidatedOrigin(_serverCtrl.text);
      ref.invalidate(dashboardHomeworkRowsProvider);
      ref.invalidate(dashboardPointsRowsProvider);
      ref.invalidate(dashboardLifeMenuItemsProvider);
      ref.read(taskRemoteRefreshProvider.notifier).state++;
      if (!mounted) return;
      setState(() {
        _editingServer = false;
        _validating = false;
      });
      messenger.showSnackBar(
        const SnackBar(content: Text('服务器地址已保存')),
      );
    } on FamilyApiException catch (e) {
      if (!mounted) return;
      setState(() => _validating = false);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _validating = false);
      messenger.showSnackBar(
        SnackBar(content: Text('校验失败：$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final muted =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    final baseAsync = ref.watch(familyApiOriginNotifierProvider);
    final displayOrigin = baseAsync.valueOrNull ?? kFamilyApiDefaultOrigin;
    final homeTitleAsync = ref.watch(dashboardHomeTitleProvider);
    final displayHomeTitle = homeTitleAsync.valueOrNull ??
        DashboardHomeTitleNotifier.kDefaultTitle;

    return Scaffold(
      backgroundColor: AppTheme.shellBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShellScreenHeader(
              onBack: () => context.pop(),
              icon: Icons.settings_rounded,
              title: '设置',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                children: [
                  Material(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            '标题设置',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: !_editingHomeTitle
                                    ? Text(
                                        displayHomeTitle,
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.85,
                                          ),
                                          fontSize: 15,
                                        ),
                                      )
                                    : TextField(
                                        controller: _homeTitleCtrl,
                                        autofocus: true,
                                        maxLength: 32,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          counterText: '',
                                          hintText: '例如：我家',
                                          hintStyle: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.35,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.black.withValues(
                                            alpha: 0.25,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 40,
                                ),
                                visualDensity: VisualDensity.compact,
                                onPressed: _editingHomeTitle
                                    ? _saveHomeTitle
                                    : () => _startEditHomeTitle(
                                          displayHomeTitle,
                                        ),
                                icon: Icon(
                                  _editingHomeTitle
                                      ? Icons.check_rounded
                                      : Icons.edit_rounded,
                                  color: _editingHomeTitle
                                      ? const Color(0xFF69F0AE)
                                      : Colors.white.withValues(alpha: 0.75),
                                ),
                                tooltip: _editingHomeTitle ? '保存' : '编辑',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_editingHomeTitle) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _cancelHomeTitle,
                        child: const Text('取消'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Material(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            '服务器地址',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: !_editingServer
                                    ? Text(
                                        displayOrigin.isEmpty
                                            ? '示例：http://192.168.2.11:18024'
                                            : displayOrigin,
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.55,
                                          ),
                                          fontSize: 13,
                                        ),
                                      )
                                    : TextField(
                                        controller: _serverCtrl,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          hintText: 'http://192.168.2.11:18024',
                                          hintStyle: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.35,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.black.withValues(
                                            alpha: 0.25,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        keyboardType: TextInputType.url,
                                        autocorrect: false,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.deny(
                                            RegExp(r'\s'),
                                          ),
                                        ],
                                      ),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 40,
                                ),
                                visualDensity: VisualDensity.compact,
                                onPressed: (baseAsync.isLoading || _validating)
                                    ? null
                                    : _editingServer
                                        ? _confirmServerUrl
                                        : () => _startEdit(
                                              displayOrigin.isEmpty
                                                  ? ''
                                                  : displayOrigin,
                                            ),
                                onLongPress: _editingServer ||
                                        !_serverOriginScanSupported ||
                                        baseAsync.isLoading ||
                                        _validating
                                    ? null
                                    : _scanAndApplyServerUrl,
                                icon: _editingServer && _validating
                                    ? SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white.withValues(
                                            alpha: 0.85,
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        _editingServer
                                            ? Icons.check_rounded
                                            : Icons.edit_rounded,
                                        color: _editingServer
                                            ? const Color(0xFF69F0AE)
                                            : Colors.white.withValues(
                                                alpha: 0.75,
                                              ),
                                      ),
                                tooltip: _editingServer
                                    ? '保存并校验'
                                    : _serverOriginScanSupported
                                        ? '点击手动输入，长按扫码'
                                        : '手动输入',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_editingServer) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _validating ? null : _cancelEdit,
                        child: const Text('取消'),
                      ),
                    ),
                    Text(
                      '确定后将请求 GET {上述地址}/api/v1/members 校验；成功且成员非空后保存站点根（不含 /api/v1）。',
                      style: TextStyle(color: muted, fontSize: 12, height: 1.35),
                    ),
                  ],
                  const SizedBox(height: 28),
                  Text(
                    '更多选项即将开放',
                    style: TextStyle(color: muted, fontSize: 14),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                '版本 $kAppBuildStamp',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: muted,
                  fontSize: 12,
                  height: 1.3,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
