import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/timemachine_ui_providers.dart';
import '../data/timemachine_prototype_models.dart';

const Color _kTmBg = Color(0xFF121212);
const Color _kTmCard = Color(0xFF1E1E1E);
const Color _kTmGold = Color(0xFFD4AF37);

class TimemachinePage extends ConsumerWidget {
  const TimemachinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(timemachineEntriesProvider).length;
    final sections = ref.watch(timemachineSidebarSectionsProvider);
    final feedSections = ref.watch(timemachineFeedSectionsProvider);
    final selected = ref.watch(timemachineSelectedBizDateProvider);
    final filteredCount = ref.watch(filteredTimemachineEntriesProvider).length;

    final summaryPrefix = selected == null
        ? '全部记录'
        : '${timemachineSidebarDayLabel(selected)} 的记录';
    final summaryText = '$summaryPrefix · 共 $filteredCount 条';

    return Scaffold(
      backgroundColor: _kTmBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 12, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: Colors.white70,
                    onPressed: () => context.pop(),
                  ),
                  const Icon(Icons.hourglass_top_rounded,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    '时光机',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final wide = c.maxWidth >= 720;
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: 132,
                          child: _SidebarColumn(
                            totalCount: total,
                            sections: sections,
                            selectedBizDate: selected,
                            onSelectAll: () {
                              ref
                                  .read(timemachineSelectedBizDateProvider
                                      .notifier)
                                  .state = null;
                            },
                            onSelectDay: (bd) {
                              ref
                                  .read(timemachineSelectedBizDateProvider
                                      .notifier)
                                  .state = bd;
                            },
                          ),
                        ),
                        VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                        Expanded(
                          child: _FeedColumn(
                            summaryText: summaryText,
                            feedSections: feedSections,
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 132,
                        child: _SidebarHorizontal(
                          totalCount: total,
                          sections: sections,
                          selectedBizDate: selected,
                          onSelectAll: () {
                            ref
                                .read(timemachineSelectedBizDateProvider
                                    .notifier)
                                .state = null;
                          },
                          onSelectDay: (bd) {
                            ref
                                .read(timemachineSelectedBizDateProvider
                                    .notifier)
                                .state = bd;
                          },
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      Expanded(
                        child: _FeedColumn(
                          summaryText: summaryText,
                          feedSections: feedSections,
                        ),
                      ),
                    ],
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

class _SidebarColumn extends StatelessWidget {
  const _SidebarColumn({
    required this.totalCount,
    required this.sections,
    required this.selectedBizDate,
    required this.onSelectAll,
    required this.onSelectDay,
  });

  final int totalCount;
  final List<TimemachineSidebarSection> sections;
  final String? selectedBizDate;
  final VoidCallback onSelectAll;
  final void Function(String bizDate) onSelectDay;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
      children: [
        _AllButton(
          totalCount: totalCount,
          selected: selectedBizDate == null,
          onTap: onSelectAll,
        ),
        const SizedBox(height: 14),
        ...sections.expand((sec) {
          return [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
              child: Text(
                sec.monthLabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                ),
              ),
            ),
            ...sec.days.map(
              (d) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _DayTile(
                  label: d.label,
                  count: d.entryCount,
                  selected: selectedBizDate == d.bizDate,
                  onTap: () => onSelectDay(d.bizDate),
                ),
              ),
            ),
          ];
        }),
      ],
    );
  }
}

class _SidebarHorizontal extends StatelessWidget {
  const _SidebarHorizontal({
    required this.totalCount,
    required this.sections,
    required this.selectedBizDate,
    required this.onSelectAll,
    required this.onSelectDay,
  });

  final int totalCount;
  final List<TimemachineSidebarSection> sections;
  final String? selectedBizDate;
  final VoidCallback onSelectAll;
  final void Function(String bizDate) onSelectDay;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      scrollDirection: Axis.horizontal,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          child: _AllButton(
            totalCount: totalCount,
            selected: selectedBizDate == null,
            onTap: onSelectAll,
          ),
        ),
        ...sections.expand((sec) {
          return [
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 16),
              child: Text(
                sec.monthLabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 11,
                ),
              ),
            ),
            ...sec.days.map(
              (d) => Padding(
                padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                child: _DayTile(
                  label: d.label,
                  count: d.entryCount,
                  selected: selectedBizDate == d.bizDate,
                  vertical: false,
                  onTap: () => onSelectDay(d.bizDate),
                ),
              ),
            ),
          ];
        }),
      ],
    );
  }
}

class _AllButton extends StatelessWidget {
  const _AllButton({
    required this.totalCount,
    required this.selected,
    required this.onTap,
  });

  final int totalCount;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: _kTmCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? _kTmGold : Colors.white.withValues(alpha: 0.1),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '全部',
                style: TextStyle(
                  color: selected ? _kTmGold : Colors.white70,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _kTmGold.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _kTmGold.withValues(alpha: 0.55),
                  ),
                ),
                child: Text(
                  '$totalCount',
                  style: const TextStyle(
                    color: _kTmGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
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

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.vertical = true,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints:
              vertical ? null : const BoxConstraints(minWidth: 100),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: _kTmCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? _kTmGold.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (count > 1) ...[
                const SizedBox(width: 6),
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _kTmGold.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _kTmGold.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: _kTmGold,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedColumn extends StatelessWidget {
  const _FeedColumn({
    required this.summaryText,
    required this.feedSections,
  });

  final String summaryText;
  final List<TimemachineFeedSection> feedSections;

  @override
  Widget build(BuildContext context) {
    if (feedSections.isEmpty) {
      return Center(
        child: Text(
          '暂无记录',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: _kTmGold,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                summaryText,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        ...feedSections.expand((sec) {
          return [
            Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 4),
              child: Text(
                sec.monthLabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...sec.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _EntryCard(entry: e),
              ),
            ),
          ];
        }),
      ],
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});

  final TimemachineEntry entry;

  @override
  Widget build(BuildContext context) {
    final pill = timemachineCardPillLabel(entry.bizDate);
    return Container(
      decoration: BoxDecoration(
        color: _kTmCard,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: _kTmGold.withValues(alpha: 0.9),
            width: 3,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _kTmGold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _kTmGold.withValues(alpha: 0.55)),
                ),
                child: Text(
                  pill,
                  style: const TextStyle(
                    color: _kTmGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entry.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            entry.body,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 14,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
