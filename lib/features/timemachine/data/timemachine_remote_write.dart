import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/data/family_api_client.dart';
import '../../dashboard/providers/dashboard_remote_providers.dart';
import '../../dashboard/providers/family_api_write_refresh.dart';

Future<void> syncTimelineEntryRemote(
  WidgetRef ref, {
  required String bizDate,
  required String title,
  required String content,
  String? dayLabel,
}) async {
  final t = title.trim();
  final c = content.trim();
  if (t.isEmpty && c.isEmpty) {
    throw FamilyApiException('标题与内容不能同时为空');
  }
  final monthKey = bizDate.length >= 7 ? bizDate.substring(0, 7) : bizDate;
  final client = ref.read(familyApiClientProvider);
  await client.syncTimelineEntry({
    'bizDate': bizDate,
    'monthKey': monthKey,
    'dayLabel': dayLabel ?? bizDate,
    'title': t.isNotEmpty ? t : '日记',
    'content': c,
  });
  refreshAfterFamilyApiWrite(ref);
}
