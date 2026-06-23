import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_product_flags.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/platform_link_launcher.dart';
import '../../../core/widgets/shell_screen_header.dart';
import '../../../shared/providers/shopping_ui_providers.dart';
import '../../dashboard/providers/family_api_base_url_provider.dart';
import '../data/shopping_models.dart';
import '../data/shopping_remote_write.dart';

const Color _kCardBg = Color(0xFF1E222D);

class ShoppingListPage extends ConsumerWidget {
  const ShoppingListPage({super.key});

  static const _filters = [
    ('false', '待买'),
    ('true', '已购'),
    ('all', '全部'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(shoppingFilterPurchasedProvider);
    final itemsAsync = ref.watch(shoppingItemsAsyncProvider);
    final apiConfigured = ref.watch(familyApiIsConfiguredProvider);
    final allowWrite = apiConfigured && !kEffectiveReadOnlyDataMode;

    return Scaffold(
      backgroundColor: AppTheme.shellBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShellScreenHeader(
              title: '购物清单',
              icon: Icons.shopping_bag_outlined,
              onBack: () => context.pop(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Wrap(
                spacing: 8,
                children: _filters.map((f) {
                  final selected = filter == f.$1;
                  return FilterChip(
                    label: Text(f.$2),
                    selected: selected,
                    onSelected: (_) {
                      ref.read(shoppingFilterPurchasedProvider.notifier).state =
                          f.$1;
                    },
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: itemsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('加载失败：$e', style: const TextStyle(color: Colors.white70)),
                ),
                data: (items) {
                  if (!apiConfigured) {
                    return const Center(
                      child: Text(
                        '请先在设置中配置数据中心地址',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }
                  if (items.isEmpty) {
                    return const Center(
                      child: Text(
                        '暂无商品\n可通过 AI 发送截图或链接添加',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, height: 1.5),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(shoppingItemsAsyncProvider);
                      await ref.read(shoppingItemsAsyncProvider.future);
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _ShoppingItemCard(
                          item: items[index],
                          allowWrite: allowWrite,
                          onOpenDetail: () =>
                              context.push('/shopping/item/${items[index].itemId}'),
                        );
                      },
                    ),
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

class _ShoppingItemCard extends ConsumerWidget {
  const _ShoppingItemCard({
    required this.item,
    required this.allowWrite,
    required this.onOpenDetail,
  });

  final ShoppingItem item;
  final bool allowWrite;
  final VoidCallback onOpenDetail;

  Future<void> _copyName(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: item.copyText));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已复制：${item.copyText}')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priceLabel = item.currentPrice != null
        ? '${item.currency == 'CNY' ? '¥' : ''}${item.currentPrice!.toStringAsFixed(item.currentPrice! % 1 == 0 ? 0 : 2)}'
        : '价格待确认';

    return Material(
      color: _kCardBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onOpenDetail,
        onLongPress: () => _copyName(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (item.specText != null &&
                            item.specText!.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              item.specText!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (item.purchased)
                    const Chip(
                      label: Text('已购', style: TextStyle(fontSize: 11)),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                priceLabel,
                style: TextStyle(
                  color: item.currentPrice != null
                      ? const Color(0xFFFFAB91)
                      : Colors.white54,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (item.hasLinks)
                    ...item.links.where((l) => l.url.isNotEmpty).map((link) {
                      final label = link.label ?? link.platform ?? '打开';
                      return OutlinedButton.icon(
                        onPressed: () async {
                          final ok = await openShoppingLink(link.url);
                          if (!context.mounted) return;
                          if (!ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('无法打开链接')),
                            );
                          }
                        },
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: Text(label),
                      );
                    })
                  else ...[
                    OutlinedButton.icon(
                      onPressed: () => _copyName(context),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('复制名称'),
                    ),
                    const Text(
                      '暂无链接，可发给 AI 补链',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                  if (allowWrite)
                    TextButton.icon(
                      onPressed: () async {
                        await toggleShoppingPurchasedRemote(ref, item.itemId);
                      },
                      icon: Icon(
                        item.purchased
                            ? Icons.undo_rounded
                            : Icons.check_circle_outline,
                        size: 18,
                      ),
                      label: Text(item.purchased ? '取消已购' : '标记已购'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
