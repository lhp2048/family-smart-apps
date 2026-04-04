import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mock/mock_data_notifier.dart';
import '../../../shared/providers/wishwall_ui_providers.dart';
import '../data/wishwall_prototype_models.dart';

const Color _kWishBg = Color(0xFF12121A);
const Color _kCardBg = Color(0xFF1E222D);
const Color _kChipSelected = Color(0xFF7C4DFF);
const Color _kChipUnselected = Color(0xFF2C2C3E);
const Color _kAccentBlue = Color(0xFF2196F3);

class WishwallPage extends ConsumerWidget {
  const WishwallPage({super.key});

  static const _chips = <_ChipDef>[
    _ChipDef(id: 'all', label: '全部', emoji: null),
    _ChipDef(id: 'xixi', label: '曦曦', emoji: '👧'),
    _ChipDef(id: 'chuan', label: '川川', emoji: '👦'),
    _ChipDef(id: 'mx', label: 'mx', emoji: '👦'),
    _ChipDef(id: 'unrealized', label: '未实现', emoji: '🔥'),
    _ChipDef(id: 'realized', label: '已实现', emoji: '✅'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterId = ref.watch(wishwallFilterIdProvider);
    final filtered = ref.watch(filteredWishwallItemsProvider);
    final members = ref.watch(mockDataNotifierProvider).members;

    String nameForCode(String code) {
      for (final m in members) {
        if (m.memberCode == code) return m.name;
      }
      return code;
    }

    final subtitle =
        '${wishwallFilterSubtitleLabel(filterId)} • ${filtered.length} 个';

    return Scaffold(
      backgroundColor: _kWishBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: Colors.white70,
                    onPressed: () => context.pop(),
                  ),
                  const Icon(Icons.star_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    '心愿墙',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _chips.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final c = _chips[i];
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
                                fontWeight:
                                    sel ? FontWeight.w600 : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                            if (c.emoji != null) ...[
                              const SizedBox(width: 4),
                              Text(c.emoji!,
                                  style: const TextStyle(fontSize: 14)),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        '暂无心愿',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 15,
                        ),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, c) {
                        final cross = c.maxWidth >= 520 ? 2 : 1;
                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cross,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: cross == 2 ? 0.82 : 0.95,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            return _WishCard(
                              item: filtered[i],
                              ownerName: nameForCode(filtered[i].memberCode),
                            );
                          },
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
  const _ChipDef({
    required this.id,
    required this.label,
    this.emoji,
  });

  final String id;
  final String label;
  final String? emoji;
}

class _WishCard extends StatelessWidget {
  const _WishCard({
    required this.item,
    required this.ownerName,
  });

  final WishwallItem item;
  final String ownerName;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Container(
            width: double.infinity,
            color: _kCardBg,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.cardEmoji,
                  style: const TextStyle(fontSize: 40, height: 1),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Text(
                    item.content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
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
                        ownerName,
                        style: const TextStyle(
                          color: Color(0xFF90CAF9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.createdAtLabel,
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
            child: _CornerLeafTag(),
          ),
        ],
      ),
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
