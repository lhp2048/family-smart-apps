import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shell_screen_header.dart';
import '../../../shared/providers/debate_ui_providers.dart';
import '../data/debate_prototype_models.dart';

const Color _kCard = Color(0xFF1E1E28);
const Color _kOrange = Color(0xFFFF9800);
const Color _kSidebarSelected = Color(0xFF5D4037);
const Color _kGuideBlue = Color(0xFF42A5F5);
const Color _kProGreen = Color(0xFF66BB6A);
const Color _kConRed = Color(0xFFEF5350);

class DebatePage extends ConsumerWidget {
  const DebatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bundles = ref.watch(debateDayBundlesProvider);
    final selected = ref.watch(selectedDebateBizDateProvider);
    final bundle = ref.watch(selectedDebateBundleProvider);

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
              child: bundles.isEmpty || bundle == null
                  ? Center(
                      child: Text(
                        '暂无辩论记录',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, c) {
                        final wide = c.maxWidth >= 720;
                        if (wide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                width: 136,
                                child: _HistorySidebar(
                                  bundles: bundles,
                                  selectedBizDate: selected,
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
                                bundles: bundles,
                                selectedBizDate: selected,
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
    required this.bundles,
    required this.selectedBizDate,
    required this.onSelect,
    this.horizontal = false,
  });

  final List<DebateDayBundle> bundles;
  final String selectedBizDate;
  final void Function(String bizDate) onSelect;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    Widget tile(DebateDayBundle b) {
      final sel = b.bizDate == selectedBizDate;
      final text = debateSidebarLabel(b.bizDate);
      return Padding(
        padding: horizontal
            ? const EdgeInsets.only(left: 8, right: 4, top: 6, bottom: 8)
            : const EdgeInsets.fromLTRB(10, 0, 10, 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onSelect(b.bizDate),
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
        itemCount: bundles.length,
        itemBuilder: (context, i) => tile(bundles[i]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      itemCount: bundles.length,
      itemBuilder: (context, i) => tile(bundles[i]),
    );
  }
}

class _DebateMainScroll extends StatelessWidget {
  const _DebateMainScroll({required this.bundle});

  final DebateDayBundle bundle;

  @override
  Widget build(BuildContext context) {
    final pill = debateHeaderPillLabel(bundle.bizDate);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _kOrange.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _kOrange.withValues(alpha: 0.55)),
              ),
              child: Text(
                pill,
                style: const TextStyle(
                  color: _kOrange,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '话题辩论',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _MainTitleCard(bundle: bundle),
        const SizedBox(height: 16),
        _GuideCard(steps: bundle.guideSteps),
        const SizedBox(height: 18),
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

class _MainTitleCard extends StatelessWidget {
  const _MainTitleCard({required this.bundle});

  final DebateDayBundle bundle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF3E2723).withValues(alpha: 0.95),
            _kCard,
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.restaurant_menu_rounded,
              color: Colors.white, size: 32),
          const SizedBox(height: 12),
          Text(
            bundle.mainTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bundle.scheduleHint,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.steps});

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: _kGuideBlue.withValues(alpha: 0.95), width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_rounded,
                  color: _kGuideBlue, size: 22),
              const SizedBox(width: 8),
              const Text(
                '辩论指南',
                style: TextStyle(
                  color: _kGuideBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(steps.length, (i) {
            return Padding(
              padding: EdgeInsets.only(bottom: i == steps.length - 1 ? 0 : 6),
              child: Text(
                '${i + 1}. ${steps[i]}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            );
          }),
        ],
      ),
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
