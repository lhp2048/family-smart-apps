import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/models/member_entity.dart';
import '../../data/models/task_item_entity.dart';

class TaskItemTile extends StatelessWidget {
  const TaskItemTile({
    super.key,
    required this.item,
    required this.members,
    required this.onToggle,
  });

  final TaskItemEntity item;
  final List<MemberEntity> members;
  final void Function(String memberCode) onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    Map<String, dynamic> status = {};
    try {
      status = jsonDecode(item.statusByMemberJson) as Map<String, dynamic>;
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Text(
                  '+${item.score}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.warning,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: members.map((m) {
                final done = status[m.memberCode] == true;
                return FilterChip(
                  label: Text(m.name),
                  selected: done,
                  onSelected: (_) => onToggle(m.memberCode),
                  avatar: Icon(
                    done ? Icons.check_circle : Icons.circle_outlined,
                    size: 18,
                    color: done ? colors.success : colors.onSurfaceVariant,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
