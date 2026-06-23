import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_product_flags.dart';
import '../../../core/mock/mock_data_notifier.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shell_screen_header.dart';
import '../../../features/dashboard/data/family_api_client.dart';
import '../../../features/dashboard/providers/dashboard_remote_providers.dart';
import '../../../features/dashboard/providers/family_api_base_url_provider.dart';
import '../../../features/dashboard/providers/family_api_write_refresh.dart';
import '../../../shared/models/member_entity.dart';
import '../../../shared/providers/task_ui_providers.dart';
import '../../../shared/providers/wishwall_ui_providers.dart';
import '../data/wishwall_prototype_models.dart';
import '../data/wishwall_remote_write.dart';

const Color _kCardBg = Color(0xFF1E222D);
const Color _kCardBgFulfilled = Color(0xFF1A2420);
const Color _kChipSelected = Color(0xFF7C4DFF);
const Color _kChipUnselected = Color(0xFF2C2C3E);
const Color _kAccentBlue = Color(0xFF2196F3);
const Color _kWishPending = Color(0xFFFFB74D);
const Color _kWishFulfilled = Color(0xFF66BB6A);

/// 首页主标题「心愿墙」、下行为「许下心愿 · 美好期待」，箭头旁角标「未来」；本页顶栏为「未来」。
class WishwallPage extends ConsumerWidget {
  const WishwallPage({super.key});

  /// 未配置 API 时筛选条：与 Mock 成员一致
  static const _kMockMemberChips = <_ChipDef>[
    _ChipDef(id: 'xixi', label: '曦曦', emoji: '👧'),
    _ChipDef(id: 'chuan', label: '川川', emoji: '👦'),
    _ChipDef(id: 'mx', label: 'mx', emoji: '👦'),
  ];

  static const _kTailChips = <_ChipDef>[
    _ChipDef(id: 'unrealized', label: '未实现', emoji: '🔥'),
    _ChipDef(id: 'realized', label: '已实现', emoji: '✅'),
  ];

  List<_ChipDef> _buildChips(WidgetRef ref) {
    const head = _ChipDef(id: 'all', label: '全部', emoji: null);
    if (!ref.watch(familyApiIsConfiguredProvider)) {
      return [head, ..._kMockMemberChips, ..._kTailChips];
    }
    final childrenAsync = ref.watch(homeworkChildrenAsyncProvider);
    final children = childrenAsync.valueOrNull;
    if (children == null || children.isEmpty) {
      return [head, ..._kTailChips];
    }
    final memberChips = children
        .map(
          (c) => _ChipDef(
            id: c.memberCode,
            label: c.name,
            emoji: (c.avatar != null && c.avatar!.isNotEmpty) ? c.avatar : null,
          ),
        )
        .toList();
    return [head, ...memberChips, ..._kTailChips];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterId = ref.watch(wishwallFilterIdProvider);
    final wishesAsync = ref.watch(wishwallItemsAsyncProvider);
    final filtered = ref.watch(filteredWishwallItemsProvider);
    final chips = _buildChips(ref);
    final apiConfigured = ref.watch(familyApiIsConfiguredProvider);
    final allowWrite = apiConfigured && !kEffectiveReadOnlyDataMode;

    ref.listen(homeworkChildrenAsyncProvider, (prev, next) {
      next.whenData((children) {
        if (children.isEmpty) return;
        final sel = ref.read(wishwallFilterIdProvider);
        final ids = children.map((c) => c.memberCode).toSet();
        if (ids.contains(sel)) return;
        if (sel == 'xixi' || sel == 'chuan' || sel == 'mx') {
          if (!ids.contains(sel)) {
            ref.read(wishwallFilterIdProvider.notifier).state = 'all';
          }
        }
      });
    });

    String nameForCode(String code) {
      if (!ref.read(familyApiIsConfiguredProvider)) {
        for (final m in ref.read(mockDataNotifierProvider).members) {
          if (m.memberCode == code) return m.name;
        }
        return code;
      }
      final list = ref.read(homeworkChildrenAsyncProvider).valueOrNull;
      if (list != null) {
        for (final m in list) {
          if (m.memberCode == code) return m.name;
        }
      }
      return code;
    }

    return Scaffold(
      backgroundColor: AppTheme.shellBackground,
      floatingActionButton: allowWrite
          ? FloatingActionButton(
              onPressed: () => _showAddWishDialog(context, ref),
              backgroundColor: _kChipSelected,
              child: const Icon(Icons.add_rounded),
            )
          : null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShellScreenHeader(
              onBack: () => context.pop(),
              icon: Icons.auto_awesome_rounded,
              title: '未来',
            ),
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: chips.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final c = chips[i];
                  final sel = c.id == filterId;
                  return Material(
                    color: sel ? _kChipSelected : _kChipUnselected,
                    borderRadius: BorderRadius.circular(22),
                    child: InkWell(
                      onTap: () {
                        ref.read(wishwallFilterIdProvider.notifier).state =
                            c.id;
                      },
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: sel
                                ? _kChipSelected
                                : Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              c.label,
                              style: TextStyle(
                                color: sel ? Colors.white : Colors.white70,
                                fontWeight: sel
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                            if (c.emoji != null) ...[
                              const SizedBox(width: 4),
                              Text(
                                c.emoji!,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: wishesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      '心愿加载失败：$e',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                data: (_) {
                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        '暂无心愿',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 15,
                        ),
                      ),
                    );
                  }
                  return _WishwallCardList(
                    items: filtered,
                    nameForCode: nameForCode,
                    allowToggle: allowWrite,
                    onToggleWish: allowWrite
                        ? (item) => _toggleWishRemote(ref, context, item)
                        : null,
                    onDeleteWish: allowWrite
                        ? (item) => _deleteWishRemote(ref, context, item)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _toggleWishRemote(
  WidgetRef ref,
  BuildContext context,
  WishwallItem item,
) async {
  final wishId = int.tryParse(item.id);
  if (wishId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('心愿 ID 无效，无法切换状态')),
    );
    return;
  }
  final messenger = ScaffoldMessenger.of(context);
  try {
    final client = ref.read(familyApiClientProvider);
    await client.toggleWish(wishId);
    refreshAfterFamilyApiWrite(ref);
  } on FamilyApiException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('切换失败：$e')));
  }
}

Future<void> _deleteWishRemote(
  WidgetRef ref,
  BuildContext context,
  WishwallItem item,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('删除心愿'),
      content: const Text('确定删除这条心愿吗？'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除')),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  try {
    await deleteWishRemote(ref, item);
  } on FamilyApiException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('删除失败：$e')));
  }
}

Future<void> _showAddWishDialog(BuildContext context, WidgetRef ref) async {
  final children =
      ref.read(homeworkChildrenAsyncProvider).valueOrNull ?? const <MemberEntity>[];
  if (children.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('暂无孩子成员，无法许愿')),
    );
    return;
  }
  final contentCtrl = TextEditingController();
  var memberCode = children.first.memberCode;
  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) => AlertDialog(
        title: const Text('许下心愿'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: contentCtrl,
              autofocus: true,
              maxLines: 3,
              decoration: const InputDecoration(hintText: '写下你的心愿…'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: memberCode,
              decoration: const InputDecoration(labelText: '成员'),
              items: [
                for (final c in children)
                  DropdownMenuItem(value: c.memberCode, child: Text(c.name)),
              ],
              onChanged: (v) {
                if (v != null) setLocal(() => memberCode = v);
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () async {
              final member = children.firstWhere((c) => c.memberCode == memberCode);
              try {
                await syncWishRemote(
                  ref,
                  content: contentCtrl.text,
                  memberCode: member.memberCode,
                  displayName: member.name,
                );
                if (ctx.mounted) Navigator.pop(ctx);
              } on FamilyApiException catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(e.message)),
                  );
                }
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    ),
  );
  contentCtrl.dispose();
}

class _ChipDef {
  const _ChipDef({required this.id, required this.label, this.emoji});

  final String id;
  final String label;
  final String? emoji;
}

const TextStyle _kWishContentStyle = TextStyle(
  color: Colors.white,
  fontSize: 15,
  height: 1.45,
  fontWeight: FontWeight.w500,
);

/// 折叠时正文最多行数（约等于默认最大可视高度）
const int _kWishCollapsedMaxLines = 5;

class _WishwallCardList extends StatelessWidget {
  const _WishwallCardList({
    required this.items,
    required this.nameForCode,
    this.allowToggle = false,
    this.onToggleWish,
    this.onDeleteWish,
  });

  final List<WishwallItem> items;
  final String Function(String code) nameForCode;
  final bool allowToggle;
  final Future<void> Function(WishwallItem item)? onToggleWish;
  final Future<void> Function(WishwallItem item)? onDeleteWish;

  @override
  Widget build(BuildContext context) {
    const pad = 16.0;
    const gap = 14.0;
    return LayoutBuilder(
      builder: (context, c) {
        final maxW = c.maxWidth;
        final twoCol = maxW >= 520;
        final cardInnerW = twoCol ? (maxW - pad * 2 - gap) / 2 : maxW - pad * 2;

        Widget cardFor(WishwallItem it) {
          final owner = (it.displayName != null && it.displayName!.isNotEmpty)
              ? it.displayName!
              : nameForCode(it.memberCode);
          return _WishCard(
            item: it,
            ownerName: owner,
            minContentWidth: cardInnerW - 32,
            allowToggle: allowToggle,
            onToggleFulfillment: onToggleWish == null
                ? null
                : () => onToggleWish!(it),
            onDelete: onDeleteWish == null ? null : () => onDeleteWish!(it),
          );
        }

        if (!twoCol) {
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(pad, 8, pad, 24),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: gap),
            itemBuilder: (context, i) => cardFor(items[i]),
          );
        }

        final left = <Widget>[];
        final right = <Widget>[];
        for (var i = 0; i < items.length; i++) {
          final w = Padding(
            padding: const EdgeInsets.only(bottom: gap),
            child: cardFor(items[i]),
          );
          if (i.isEven) {
            left.add(w);
          } else {
            right.add(w);
          }
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(pad, 8, pad, 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Column(children: left)),
              const SizedBox(width: gap),
              Expanded(child: Column(children: right)),
            ],
          ),
        );
      },
    );
  }
}

class _WishCard extends StatefulWidget {
  const _WishCard({
    required this.item,
    required this.ownerName,
    required this.minContentWidth,
    this.allowToggle = false,
    this.onToggleFulfillment,
    this.onDelete,
  });

  final WishwallItem item;
  final String ownerName;

  /// 用于判断正文是否超过折叠行数（与卡片内容区宽度一致）
  final double minContentWidth;
  final bool allowToggle;
  final Future<void> Function()? onToggleFulfillment;
  final Future<void> Function()? onDelete;

  @override
  State<_WishCard> createState() => _WishCardState();
}

class _WishCardState extends State<_WishCard> {
  bool _expanded = false;

  bool _exceedsCollapsed(double textMaxWidth) {
    if (textMaxWidth <= 0) return false;
    final tp = TextPainter(
      text: TextSpan(text: widget.item.content, style: _kWishContentStyle),
      maxLines: _kWishCollapsedMaxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: textMaxWidth);
    return tp.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textMaxW = (constraints.maxWidth - 32).clamp(
          0.0,
          double.infinity,
        );
        final measureW = textMaxW > 0 ? textMaxW : widget.minContentWidth;
        final canExpand = _exceedsCollapsed(measureW);

        void onTap() {
          if (!canExpand) return;
          setState(() => _expanded = !_expanded);
        }

        final fulfilled = widget.item.fulfilled;

        return Material(
          color: fulfilled ? _kCardBgFulfilled : _kCardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: fulfilled
                  ? _kWishFulfilled.withValues(alpha: 0.55)
                  : _kWishPending.withValues(alpha: 0.42),
              width: 1.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            onLongPress: widget.onDelete,
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Opacity(
                        opacity: fulfilled ? 0.45 : 1,
                        child: Text(
                          widget.item.cardEmoji,
                          style: const TextStyle(fontSize: 40, height: 1),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.topLeft,
                        child: Text(
                          widget.item.content,
                          style: _kWishContentStyle.copyWith(
                            color: fulfilled
                                ? Colors.white.withValues(alpha: 0.42)
                                : Colors.white,
                            decoration: fulfilled
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor:
                                Colors.white.withValues(alpha: 0.35),
                          ),
                          maxLines: (canExpand && !_expanded)
                              ? _kWishCollapsedMaxLines
                              : null,
                          overflow: (canExpand && !_expanded)
                              ? TextOverflow.ellipsis
                              : TextOverflow.visible,
                        ),
                      ),
                      if (canExpand) ...[
                        const SizedBox(height: 6),
                        Text(
                          _expanded ? '点击收起' : '点击展开全文',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.38),
                            fontSize: 11,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _kAccentBlue.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _kAccentBlue.withValues(alpha: 0.6),
                              ),
                            ),
                            child: Text(
                              widget.ownerName,
                              style: const TextStyle(
                                color: Color(0xFF90CAF9),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            widget.item.createdAtLabel,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.38),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: widget.allowToggle && widget.onToggleFulfillment != null
                      ? _WishFulfillmentToggle(
                          fulfilled: fulfilled,
                          onTap: widget.onToggleFulfillment!,
                        )
                      : _WishStatusBadge(fulfilled: fulfilled),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WishFulfillmentToggle extends StatelessWidget {
  const _WishFulfillmentToggle({
    required this.fulfilled,
    required this.onTap,
  });

  final bool fulfilled;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: fulfilled ? const Color(0xFF388E3C) : const Color(0xFFF57C00),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                fulfilled
                    ? Icons.check_circle_rounded
                    : Icons.hourglass_top_rounded,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                fulfilled ? '已实现' : '待实现',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WishStatusBadge extends StatelessWidget {
  const _WishStatusBadge({required this.fulfilled});

  final bool fulfilled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
      decoration: BoxDecoration(
        color: fulfilled
            ? const Color(0xFF388E3C).withValues(alpha: 0.95)
            : const Color(0xFFF57C00).withValues(alpha: 0.95),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 6,
            offset: const Offset(-2, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            fulfilled
                ? Icons.check_circle_rounded
                : Icons.hourglass_top_rounded,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            fulfilled ? '已实现' : '待实现',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
