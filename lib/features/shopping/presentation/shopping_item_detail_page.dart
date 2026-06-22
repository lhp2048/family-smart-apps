import 'package:fl_chart/fl_chart.dart';
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

class ShoppingItemDetailPage extends ConsumerWidget {
  const ShoppingItemDetailPage({super.key, required this.itemId});

  final String itemId;

  Future<void> _copyName(BuildContext context, ShoppingItem item) async {
    await Clipboard.setData(ClipboardData(text: item.copyText));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已复制：${item.copyText}')),
      );
    }
  }

  void _openCompare(WidgetRef ref, BuildContext context, ShoppingItem item) {
    ref.read(shoppingCompareItemIdsProvider.notifier).state = [item.itemId];
    context.push('/shopping/compare');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(shoppingItemDetailAsyncProvider(itemId));
    final trendAsync = ref.watch(shoppingPriceHistoryAsyncProvider(itemId));
    final auditAsync = ref.watch(shoppingPriceHistoryAuditAsyncProvider(itemId));
    final allowWrite = ref.watch(familyApiIsConfiguredProvider) &&
        !kEffectiveReadOnlyDataMode;

    return Scaffold(
      backgroundColor: AppTheme.shellBackground,
      body: SafeArea(
        child: itemAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('加载失败：$e')),
          data: (item) {
            if (item == null) {
              return Column(
                children: [
                  ShellScreenHeader(
                    title: '商品详情',
                    icon: Icons.shopping_bag_outlined,
                    onBack: () => context.pop(),
                  ),
                  const Expanded(
                    child: Center(child: Text('商品不存在')),
                  ),
                ],
              );
            }
            return DefaultTabController(
              length: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ShellScreenHeader(
                    title: '商品详情',
                    icon: Icons.shopping_bag_outlined,
                    onBack: () => context.pop(),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (item.specText != null &&
                                      item.specText!.trim().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        item.specText!,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _copyName(context, item),
                              icon: const Icon(Icons.copy, color: Colors.white70),
                              tooltip: '复制名称',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          label: '当前价',
                          value: item.currentPrice != null
                              ? '¥${item.currentPrice}'
                              : '待确认',
                        ),
                        if (item.platform != null)
                          _InfoRow(label: '平台', value: item.platform!),
                        if (item.quantity > 1)
                          _InfoRow(label: '数量', value: '${item.quantity}'),
                        if (item.notes != null && item.notes!.isNotEmpty)
                          _InfoRow(label: '备注', value: item.notes!),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (item.hasLinks)
                              ...item.links.where((l) => l.url.isNotEmpty).map(
                                (link) => FilledButton.icon(
                                  onPressed: () => openShoppingLink(link.url),
                                  icon: const Icon(Icons.open_in_new, size: 18),
                                  label:
                                      Text(link.label ?? link.platform ?? '打开'),
                                ),
                              )
                            else
                              FilledButton.icon(
                                onPressed: () => _copyName(context, item),
                                icon: const Icon(Icons.copy, size: 18),
                                label: const Text('复制名称去搜索'),
                              ),
                            if (allowWrite)
                              OutlinedButton.icon(
                                onPressed: () async {
                                  await toggleShoppingPurchasedRemote(
                                    ref,
                                    item.itemId,
                                  );
                                  ref.invalidate(
                                    shoppingItemDetailAsyncProvider(item.itemId),
                                  );
                                },
                                icon: Icon(
                                  item.purchased
                                      ? Icons.undo_rounded
                                      : Icons.check_circle_outline,
                                ),
                                label:
                                    Text(item.purchased ? '取消已购' : '标记已购'),
                              ),
                            OutlinedButton.icon(
                              onPressed: () => _openCompare(ref, context, item),
                              icon: const Icon(Icons.show_chart),
                              label: const Text('对比走势'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const TabBar(
                          tabs: [
                            Tab(text: '价格走势'),
                            Tab(text: '全部记录'),
                          ],
                        ),
                        SizedBox(
                          height: 320,
                          child: TabBarView(
                            children: [
                              trendAsync.when(
                                loading: () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                error: (e, _) => Center(child: Text('$e')),
                                data: (records) => _TrendTab(records: records),
                              ),
                              auditAsync.when(
                                loading: () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                error: (e, _) => Center(child: Text('$e')),
                                data: (records) => _AuditTab(records: records),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TrendTab extends StatelessWidget {
  const _TrendTab({required this.records});

  final List<ShoppingPriceRecord> records;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(
        child: Text('暂无价格记录', style: TextStyle(color: Colors.white54)),
      );
    }
    if (records.length < 2) {
      return Center(
        child: Text(
          '当前价 ¥${records.last.price}',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: _PriceChart(records: records),
    );
  }
}

class _AuditTab extends StatelessWidget {
  const _AuditTab({required this.records});

  final List<ShoppingPriceRecord> records;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(
        child: Text('暂无记录', style: TextStyle(color: Colors.white54)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(top: 12),
      itemCount: records.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final r = records[i];
        final label = r.voided
            ? '已作废'
            : r.recordKind == 'correction'
                ? '纠错'
                : r.recordKind;
        return ListTile(
          dense: true,
          title: Text(
            '¥${r.price}',
            style: TextStyle(
              color: r.voided ? Colors.white38 : Colors.white,
              decoration: r.voided ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
            '${r.recordedAt} · $label',
            style: const TextStyle(fontSize: 12),
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(label, style: const TextStyle(color: Colors.white54)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _PriceChart extends StatelessWidget {
  const _PriceChart({required this.records});

  final List<ShoppingPriceRecord> records;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (var i = 0; i < records.length; i++) {
      spots.add(FlSpot(i.toDouble(), records[i].price));
    }
    final minY = records.map((e) => e.price).reduce((a, b) => a < b ? a : b);
    final maxY = records.map((e) => e.price).reduce((a, b) => a > b ? a : b);
    final pad = (maxY - minY) * 0.1 + 1;

    return LineChart(
      LineChartData(
        minY: minY - pad,
        maxY: maxY + pad,
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= records.length) return const SizedBox.shrink();
                final d = records[i].recordedAt;
                final short = d.length >= 10 ? d.substring(5, 10) : d;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    short,
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ),
          ),
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFFFFAB91),
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}
