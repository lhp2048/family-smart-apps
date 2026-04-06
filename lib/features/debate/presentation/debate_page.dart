import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shell_screen_header.dart';
import '../../../features/dashboard/providers/family_api_base_url_provider.dart';
import '../../../shared/providers/debate_ui_providers.dart';
import '../data/debate_prototype_models.dart';

const Color _kCard = Color(0xFF1E1E28);
const Color _kOrange = Color(0xFFFF9800);
const Color _kSidebarSelected = Color(0xFF5D4037);
const Color _kProGreen = Color(0xFF66BB6A);
const Color _kConRed = Color(0xFFEF5350);

class DebatePage extends ConsumerWidget {
  const DebatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiOn = ref.watch(familyApiIsConfiguredProvider);
    if (apiOn) {
      final daysAsync = ref.watch(debateRemoteDaysAsyncProvider);
      if (daysAsync.isLoading) {
        return Scaffold(
          backgroundColor: AppTheme.shellBackground,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ShellScreenHeader(
                  onBack: () => context.pop(),
                  icon: Icons.forum_rounded,
                  title: '话题辩论',
                ),
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
          ),
        );
      }
      if (daysAsync.hasError) {
        return Scaffold(
          backgroundColor: AppTheme.shellBackground,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ShellScreenHeader(
                  onBack: () => context.pop(),
                  icon: Icons.forum_rounded,
                  title: '话题辩论',
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        '辩论日期加载失败：${daysAsync.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    final dates = ref.watch(debateBizDatesProvider);
    final effective = ref.watch(debateEffectiveBizDateProvider);
    final bundleAsync = ref.watch(debateSelectedBundleAsyncProvider);

    Widget emptyBody(String msg) {
      return Expanded(
        child: Center(
          child: Text(
            msg,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.shellBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShellScreenHeader(
              onBack: () => context.pop(),
              icon: Icons.forum_rounded,
              title: '话题辩论',
            ),
            if (dates.isEmpty)
              emptyBody('暂无辩论记录')
            else
              Expanded(
                child: bundleAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        '辩题加载失败：$e',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  data: (bundle) {
                    if (bundle == null) {
                      return Center(
                        child: Text(
                          '该日暂无辩题内容',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                          ),
                        ),
                      );
                    }
                    return LayoutBuilder(
                      builder: (context, c) {
                        final wide = c.maxWidth >= 720;
                        if (wide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                width: 136,
                                child: _HistorySidebar(
                                  bizDates: dates,
                                  selectedBizDate: effective,
                                  onSelect: (bd) {
                                    ref
                                        .read(selectedDebateBizDateProvider
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
                                child: _DebateMainScroll(bundle: bundle),
                              ),
                            ],
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height: 96,
                              child: _HistorySidebar(
                                bizDates: dates,
                                selectedBizDate: effective,
                                horizontal: true,
                                onSelect: (bd) {
                                  ref
                                      .read(selectedDebateBizDateProvider
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
                              child: _DebateMainScroll(bundle: bundle),
                            ),
                          ],
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

class _HistorySidebar extends StatelessWidget {
  const _HistorySidebar({
    required this.bizDates,
    required this.selectedBizDate,
    required this.onSelect,
    this.horizontal = false,
  });

  final List<String> bizDates;
  final String selectedBizDate;
  final void Function(String bizDate) onSelect;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    Widget tile(String bd) {
      final sel = bd == selectedBizDate;
      final text = debateSidebarLabel(bd);
      return Padding(
        padding: horizontal
            ? const EdgeInsets.only(left: 8, right: 4, top: 6, bottom: 8)
            : const EdgeInsets.fromLTRB(10, 0, 10, 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onSelect(bd),
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              decoration: BoxDecoration(
                color: sel ? _kSidebarSelected : _kCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: sel
                      ? _kOrange.withValues(alpha: 0.45)
                      : Colors.white.withValues(alpha: 0.06),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Row(
                mainAxisSize: horizontal ? MainAxisSize.min : MainAxisSize.max,
                children: [
                  Icon(
                    Icons.restaurant_menu_rounded,
                    size: 18,
                    color: sel ? Colors.white : Colors.white54,
                  ),
                  const SizedBox(width: 8),
                  if (horizontal)
                    Text(
                      text,
                      style: TextStyle(
                        color: sel ? Colors.white : Colors.white60,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 13,
                      ),
                    )
                  else
                    Expanded(
                      child: Text(
                        text,
                        style: TextStyle(
                          color: sel ? Colors.white : Colors.white60,
                          fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: sel ? Colors.white54 : Colors.white24,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (horizontal) {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        itemCount: bizDates.length,
        itemBuilder: (context, i) => tile(bizDates[i]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      itemCount: bizDates.length,
      itemBuilder: (context, i) => tile(bizDates[i]),
    );
  }
}

class _DebateMainScroll extends StatelessWidget {
  const _DebateMainScroll({required this.bundle});

  final DebateDayBundle bundle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        ...bundle.topics.map(
          (t) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _TopicCard(topic: t),
          ),
        ),
      ],
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic});

  final DebateTopicItem topic;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _kOrange.withValues(alpha: 0.75)),
                ),
                child: Text(
                  topic.categoryTag,
                  style: const TextStyle(
                    color: _kOrange,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '话题 ${topic.topicIndex}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topic.question,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_box_rounded, color: _kProGreen, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '正方观点',
                      style: TextStyle(
                        color: _kProGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      topic.proBody,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.close_rounded, color: _kConRed, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '反方观点',
                      style: TextStyle(
                        color: _kConRed,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      topic.conBody,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
