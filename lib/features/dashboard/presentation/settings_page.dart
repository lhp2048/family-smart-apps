import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/api_config.dart' show kFamilyApiDefaultOrigin;
import '../../../core/constants/build_stamp.dart' show kAppBuildStamp;
import '../../../core/utils/bearer_token.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shell_screen_header.dart';
import '../../../shared/models/member_entity.dart';
import '../../../shared/providers/task_ui_providers.dart';
import '../data/family_api_client.dart';
import '../providers/dashboard_home_title_provider.dart';
import '../providers/family_api_access_token_provider.dart';
import '../providers/family_api_cache_invalidation.dart';
import '../providers/family_api_base_url_provider.dart';
import 'server_origin_qr_scan_page.dart';

String _memberRoleLabel(String role) {
  switch (role) {
    case 'parent':
      return '家长';
    case 'child':
      return '孩子';
    default:
      return role.isEmpty ? '—' : role;
  }
}

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
  /// 仅改 API KEY：不展开服务器地址输入，也不触发 GET /members 校验。
  bool _editingTokenOnly = false;
  bool _validating = false;
  bool _tokenObscured = true;
  late final TextEditingController _homeTitleCtrl = TextEditingController();
  late final TextEditingController _serverCtrl = TextEditingController();
  late final TextEditingController _tokenCtrl = TextEditingController();

  @override
  void dispose() {
    _homeTitleCtrl.dispose();
    _serverCtrl.dispose();
    _tokenCtrl.dispose();
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('主页标题已保存')));
  }

  void _startEdit(String currentUrl, String currentToken) {
    setState(() {
      _editingServer = true;
      _editingTokenOnly = false;
      _serverCtrl.text = currentUrl;
      _tokenObscured = true;
      _tokenCtrl.text = currentToken;
    });
  }

  void _cancelEdit() {
    final t = ref.read(familyApiAccessTokenNotifierProvider).valueOrNull ?? '';
    setState(() {
      _editingServer = false;
      _validating = false;
      _tokenCtrl.text = t;
    });
  }

  void _startEditTokenOnly(String current) {
    setState(() {
      _editingTokenOnly = true;
      _editingServer = false;
      _tokenObscured = true;
      _tokenCtrl.text = current;
    });
  }

  void _cancelTokenOnly() {
    final t = ref.read(familyApiAccessTokenNotifierProvider).valueOrNull ?? '';
    setState(() {
      _editingTokenOnly = false;
      _tokenCtrl.text = t;
    });
  }

  Future<void> _saveTokenOnly() async {
    final key = normalizeBearerSecret(_tokenCtrl.text);
    if (key.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请填写访问API KEY')));
      return;
    }
    await ref
        .read(familyApiAccessTokenNotifierProvider.notifier)
        .persistToken(_tokenCtrl.text);
    invalidateFamilyApiCaches(ref);
    if (!mounted) return;
    setState(() => _editingTokenOnly = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('访问API KEY 已保存')));
  }

  /// 进入 [FamilyApiClient.validateServerBaseUrl] 前须已填写服务器地址与非空访问 API KEY。
  bool _ensureServerAndApiKeyForValidation() {
    if (!mounted) return false;
    final trimmed = _serverCtrl.text.trim();
    if (trimmed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写有效的服务器地址')),
      );
      return false;
    }
    final apiKey = normalizeBearerSecret(_tokenCtrl.text);
    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写访问API KEY')),
      );
      return false;
    }
    return true;
  }

  Future<void> _scanAndApplyServerUrl() async {
    if (!_serverOriginScanSupported) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('当前平台不支持扫码')));
      return;
    }
    final url = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const ServerOriginQrScanPage()),
    );
    if (!mounted || url == null || url.isEmpty) return;
    final t = ref.read(familyApiAccessTokenNotifierProvider).valueOrNull ?? '';
    setState(() {
      _editingServer = true;
      _editingTokenOnly = false;
      _serverCtrl.text = url;
      _tokenCtrl.text = t;
    });
    await _confirmServerUrl();
  }

  Future<void> _confirmServerUrl() async {
    if (_validating) return;
    if (!_ensureServerAndApiKeyForValidation()) return;
    final trimmed = _serverCtrl.text.trim();
    final token = normalizeBearerSecret(_tokenCtrl.text);
    setState(() => _validating = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(familyApiAccessTokenNotifierProvider.notifier)
          .persistToken(_tokenCtrl.text);
      await FamilyApiClient.validateServerBaseUrl(
        trimmed,
        accessToken: token,
      );
      await ref
          .read(familyApiOriginNotifierProvider.notifier)
          .persistValidatedOrigin(trimmed);
      invalidateFamilyApiCaches(ref);
      if (!mounted) return;
      setState(() {
        _editingServer = false;
        _validating = false;
      });
      messenger.showSnackBar(const SnackBar(content: Text('服务器地址已保存')));
    } on FamilyApiException catch (e) {
      if (!mounted) return;
      setState(() => _validating = false);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _validating = false);
      messenger.showSnackBar(SnackBar(content: Text('校验失败：$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.55);
    final baseAsync = ref.watch(familyApiOriginNotifierProvider);
    final displayOrigin = baseAsync.valueOrNull ?? kFamilyApiDefaultOrigin;
    final apiConfigured = ref.watch(familyApiIsConfiguredProvider);
    final membersAsync = ref.watch(familyMembersAllAsyncProvider);
    final homeTitleAsync = ref.watch(dashboardHomeTitleProvider);
    final displayHomeTitle =
        homeTitleAsync.valueOrNull ?? DashboardHomeTitleNotifier.kDefaultTitle;
    final tokenAsync = ref.watch(familyApiAccessTokenNotifierProvider);
    final displayToken = tokenAsync.valueOrNull ?? '';

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
                            '我家',
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
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
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
                                    : () =>
                                          _startEditHomeTitle(displayHomeTitle),
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
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Expanded(
                                child: Text(
                                  '服务器地址',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (!_editingServer && !_editingTokenOnly)
                                TextButton(
                                  onPressed: baseAsync.isLoading
                                      ? null
                                      : () =>
                                            _startEditTokenOnly(displayToken),
                                  style: TextButton.styleFrom(
                                    minimumSize: Size.zero,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'API KEY',
                                    style: TextStyle(
                                      color: muted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: _editingServer
                                    ? TextField(
                                        controller: _serverCtrl,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          hintText:
                                              'http://192.168.2.11:18024',
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
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
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
                                      )
                                    : Text(
                                        displayOrigin.isEmpty
                                            ? '示例：http://192.168.2.11:18024'
                                            : displayOrigin,
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.55,
                                          ),
                                          fontSize: 13,
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
                                onPressed: (baseAsync.isLoading || _validating)
                                    ? null
                                    : _editingServer
                                    ? _confirmServerUrl
                                    : () => _startEdit(
                                        displayOrigin.isEmpty
                                            ? ''
                                            : displayOrigin,
                                        displayToken,
                                      ),
                                onLongPress: _editingServer ||
                                        _editingTokenOnly ||
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
                                    : _editingTokenOnly
                                    ? '编辑服务器与 API KEY'
                                    : _serverOriginScanSupported
                                    ? '点击手动输入，长按扫码'
                                    : '手动输入',
                              ),
                            ],
                          ),
                          if (_editingServer) ...[
                            const SizedBox(height: 12),
                            Text(
                              '访问API KEY',
                              style: TextStyle(
                                color: muted,
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _tokenCtrl,
                              obscureText: _tokenObscured,
                              autocorrect: false,
                              enableSuggestions: false,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: '粘贴或输入 API KEY',
                                hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.35),
                                ),
                                filled: true,
                                fillColor: Colors.black.withValues(alpha: 0.25),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: IconButton(
                                  tooltip: _tokenObscured ? '显示' : '隐藏',
                                  onPressed: () => setState(
                                    () => _tokenObscured = !_tokenObscured,
                                  ),
                                  icon: Icon(
                                    _tokenObscured
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: Colors.white.withValues(alpha: 0.65),
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (_editingTokenOnly) ...[
                            const SizedBox(height: 12),
                            Text(
                              '访问API KEY',
                              style: TextStyle(
                                color: muted,
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _tokenCtrl,
                                    autofocus: true,
                                    obscureText: _tokenObscured,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: '粘贴或输入 API KEY',
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
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                      suffixIcon: IconButton(
                                        tooltip: _tokenObscured ? '显示' : '隐藏',
                                        onPressed: () => setState(
                                          () => _tokenObscured =
                                              !_tokenObscured,
                                        ),
                                        icon: Icon(
                                          _tokenObscured
                                              ? Icons.visibility_off_rounded
                                              : Icons.visibility_rounded,
                                          color: Colors.white.withValues(
                                            alpha: 0.65,
                                          ),
                                          size: 22,
                                        ),
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
                                  onPressed: _saveTokenOnly,
                                  icon: const Icon(
                                    Icons.check_rounded,
                                    color: Color(0xFF69F0AE),
                                  ),
                                  tooltip: '保存 API KEY',
                                ),
                              ],
                            ),
                          ],
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
                      '确定后将请求 GET {上述地址}/api/v1/members 校验；成功且成员非空后保存站点根（不含 /api/v1）。'
                      ' 当前输入的 API KEY 会一并保存。',
                      style: TextStyle(
                        color: muted,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                  if (_editingTokenOnly) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _cancelTokenOnly,
                        child: const Text('取消'),
                      ),
                    ),
                    Text(
                      '仅保存 API KEY，不会校验服务器地址。点右侧编辑图标可改为同时编辑地址与 API KEY。',
                      style: TextStyle(
                        color: muted,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
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
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  '成员',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (apiConfigured)
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 40,
                                    minHeight: 40,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  tooltip: '重新拉取',
                                  onPressed: () {
                                    ref.invalidate(
                                      familyMembersAllAsyncProvider,
                                    );
                                  },
                                  icon: Icon(
                                    Icons.refresh_rounded,
                                    color: Colors.white.withValues(alpha: 0.75),
                                    size: 22,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (!apiConfigured)
                            Text(
                              '保存并校验通过服务器地址后，将在此显示从接口获取的成员信息。',
                              style: TextStyle(
                                color: muted,
                                fontSize: 13,
                                height: 1.35,
                              ),
                            )
                          else
                            membersAsync.when(
                              loading: () => const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                              error: (e, _) => Text(
                                '成员加载失败：$e',
                                style: TextStyle(
                                  color: Colors.orange.shade400,
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
                              data: (members) {
                                if (members.isEmpty) {
                                  return Text(
                                    '暂无成员数据',
                                    style: TextStyle(
                                      color: muted,
                                      fontSize: 13,
                                    ),
                                  );
                                }
                                return Column(
                                  children: [
                                    for (
                                      var i = 0;
                                      i < members.length;
                                      i++
                                    ) ...[
                                      if (i > 0)
                                        Divider(
                                          height: 1,
                                          color: Colors.white.withValues(
                                            alpha: 0.08,
                                          ),
                                        ),
                                      _SettingsMemberTile(member: members[i]),
                                    ],
                                  ],
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
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

String _settingsFirstGrapheme(String s) {
  if (s.isEmpty) return '?';
  final it = s.runes.iterator;
  return it.moveNext() ? String.fromCharCode(it.current) : '?';
}

class _SettingsMemberTile extends StatelessWidget {
  const _SettingsMemberTile({required this.member});

  final MemberEntity member;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.55);
    final avatar = member.avatar;
    final looksEmoji =
        avatar != null &&
        avatar.isNotEmpty &&
        avatar.length <= 8 &&
        !avatar.toLowerCase().startsWith('http');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white.withValues(alpha: 0.12),
            child: Text(
              looksEmoji ? avatar : _settingsFirstGrapheme(member.name),
              style: TextStyle(
                fontSize: looksEmoji ? 20 : 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_memberRoleLabel(member.role)} · ${member.memberCode}'
                  '${member.status.isNotEmpty ? ' · ${member.status}' : ''}',
                  style: TextStyle(color: muted, fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
