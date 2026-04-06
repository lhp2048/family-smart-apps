import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mock/mock_data_notifier.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shell_screen_header.dart';
import '../../../features/dashboard/providers/family_api_base_url_provider.dart';
import '../../../shared/providers/task_ui_providers.dart';
import '../../../shared/providers/wishwall_ui_providers.dart';
import '../data/wishwall_prototype_models.dart';

const Color _kCardBg = Color(0xFF1E222D);
const Color _kChipSelected = Color(0xFF7C4DFF);
const Color _kChipUnselected = Color(0xFF2C2C3E);
const Color _kAccentBlue = Color(0xFF2196F3);

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
  const _WishwallCardList({required this.items, required this.nameForCode});

  final List<WishwallItem> items;
  final String Function(String code) nameForCode;

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
  });

  final WishwallItem item;
  final String ownerName;

  /// 用于判断正文是否超过折叠行数（与卡片内容区宽度一致）
  final double minContentWidth;

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

        return Material(
          color: _kCardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
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
                      Text(
                        widget.item.cardEmoji,
                        style: const TextStyle(fontSize: 40, height: 1),
                      ),
                      const SizedBox(height: 12),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.topLeft,
                        child: Text(
                          widget.item.content,
                          style: _kWishContentStyle,
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
                Positioned(top: 0, right: 0, child: _CornerLeafTag()),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 右上角蓝色装饰角标（近似原型「叶片」）
class _CornerLeafTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 40,
      alignment: Alignment.topRight,
      child: Container(
        width: 48,
        height: 36,
        decoration: BoxDecoration(
          color: _kAccentBlue.withValues(alpha: 0.92),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(-2, 2),
            ),
          ],
        ),
      ),
    );
  }
}
