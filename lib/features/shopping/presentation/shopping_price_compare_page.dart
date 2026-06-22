import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shell_screen_header.dart';
import '../../../shared/providers/shopping_ui_providers.dart';
import '../data/shopping_models.dart';

enum _ChartMode { absolute, percent }

class ShoppingPriceComparePage extends ConsumerStatefulWidget {
  const ShoppingPriceComparePage({super.key});

  @override
  ConsumerState<ShoppingPriceComparePage> createState() =>
      _ShoppingPriceComparePageState();
}

class _ShoppingPriceComparePageState
    extends ConsumerState<ShoppingPriceComparePage> {
  _ChartMode _mode = _ChartMode.absolute;
  final _colors = const [
    Color(0xFFFFAB91),
    Color(0xFF90CAF9),
    Color(0xFFA5D6A7),
    Color(0xFFCE93D8),
    Color(0xFFFFF176),
  ];

  @override
  Widget build(BuildContext context) {
    final ids = ref.watch(shoppingCompareItemIdsProvider);
    final trendsAsync = ref.watch(shoppingPriceTrendsAsyncProvider);
    final itemsAsync = ref.watch(shoppingItemsAsyncProvider);

    return Scaffold(
      backgroundColor: AppTheme.shellBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShellScreenHeader(
              title: '走势对比',
              icon: Icons.show_chart,
              onBack: () => context.pop(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<_ChartMode>(
                segments: const [
                  ButtonSegment(
                    value: _ChartMode.absolute,
                    label: Text('绝对价格'),
                  ),
                  ButtonSegment(
                    value: _ChartMode.percent,
                    label: Text('相对涨跌 %'),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (s) {
                  setState(() => _mode = s.first);
                },
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...ids.map(
                    (id) => InputChip(
                      label: Text(_titleFor(id, itemsAsync.valueOrNull ?? [])),
                      onDeleted: () {
                        ref.read(shoppingCompareItemIdsProvider.notifier).state =
                            ids.where((x) => x != id).toList();
                      },
                    ),
                  ),
                  if (ids.length < 5)
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: const Text('添加商品'),
                      onPressed: () => _pickItem(context, itemsAsync.valueOrNull ?? []),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: trendsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) {
                    if (e is StateError && e.message == 'currencyConflict') {
                      return const Center(
                        child: Text(
                          '所选商品币种不同，请分开查看',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }
                    return Center(child: Text('加载失败：$e'));
                  },
                  data: (series) {
                    if (ids.isEmpty) {
                      return const Center(
                        child: Text(
                          '请添加要对比的商品',
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    }
                    if (series.isEmpty) {
                      return const Center(
                        child: Text(
                          '暂无足够走势数据',
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    }
                    return _MultiPriceChart(
                      series: series,
                      mode: _mode,
                      colors: _colors,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _titleFor(String id, List<ShoppingItem> items) {
    for (final item in items) {
      if (item.itemId == id) return item.title;
    }
    return id;
  }

  Future<void> _pickItem(BuildContext context, List<ShoppingItem> items) async {
    final pending = items.where((e) => !e.purchased).toList();
    if (pending.isEmpty) return;
    final picked = await showModalBottomSheet<ShoppingItem>(
      context: context,
      backgroundColor: const Color(0xFF1E222D),
      builder: (ctx) {
        return ListView(
          children: pending
              .map(
                (e) => ListTile(
                  title: Text(e.title, style: const TextStyle(color: Colors.white)),
                  subtitle: e.specText != null
                      ? Text(e.specText!, style: const TextStyle(color: Colors.white54))
                      : null,
                  onTap: () => Navigator.pop(ctx, e),
                ),
              )
              .toList(),
        );
      },
    );
    if (picked == null) return;
    final current = ref.read(shoppingCompareItemIdsProvider);
    if (current.contains(picked.itemId) || current.length >= 5) return;
    ref.read(shoppingCompareItemIdsProvider.notifier).state =
        [...current, picked.itemId];
  }
}

class _MultiPriceChart extends StatelessWidget {
  const _MultiPriceChart({
    required this.series,
    required this.mode,
    required this.colors,
  });

  final List<ShoppingPriceSeries> series;
  final _ChartMode mode;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final lines = <LineChartBarData>[];
    var maxLen = 0;
    for (var si = 0; si < series.length; si++) {
      final s = series[si];
      if (s.points.isEmpty) continue;
      maxLen = s.points.length > maxLen ? s.points.length : maxLen;
      final initial = s.points.first.price;
      final spots = <FlSpot>[];
      for (var i = 0; i < s.points.length; i++) {
        final p = s.points[i].price;
        final y = mode == _ChartMode.percent && initial != 0
            ? (p / initial - 1) * 100
            : p;
        spots.add(FlSpot(i.toDouble(), y));
      }
      lines.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: colors[si % colors.length],
          barWidth: 2.5,
          dotData: const FlDotData(show: false),
        ),
      );
    }
    if (lines.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return Column(
      children: [
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              titlesData: const FlTitlesData(
                bottomTitles: AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 44),
                ),
                topTitles: AxisTitles(),
                rightTitles: AxisTitles(),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: lines,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: [
            for (var i = 0; i < series.length; i++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[i % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    series[i].title,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
