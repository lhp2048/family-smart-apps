import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/data/family_api_client.dart';
import '../../dashboard/providers/dashboard_remote_providers.dart';
import '../../dashboard/providers/family_api_write_refresh.dart';
import '../models/calendar_models.dart';

Future<void> syncCalendarEventRemote(
  WidgetRef ref, {
  required FamilyEventItem event,
}) async {
  final client = ref.read(familyApiClientProvider);
  await client.syncCalendarEvent(event.toSyncPayload());
  refreshAfterFamilyApiWrite(ref);
}

Future<void> deleteCalendarEventRemote(
  WidgetRef ref, {
  required String eventId,
}) async {
  if (eventId.isEmpty) {
    throw FamilyApiException('事件 ID 无效');
  }
  final client = ref.read(familyApiClientProvider);
  await client.deleteCalendarEvent(eventId);
  refreshAfterFamilyApiWrite(ref);
}

Future<void> toggleCalendarEventDoneRemote(
  WidgetRef ref, {
  required FamilyEventItem event,
}) async {
  await syncCalendarEventRemote(
    ref,
    event: FamilyEventItem(
      eventId: event.eventId,
      eventType: event.eventType,
      bizDate: event.bizDate,
      title: event.title,
      content: event.content,
      memberCode: event.memberCode,
      status: event.isDone ? 'pending' : 'done',
      startAt: event.startAt,
      endAt: event.endAt,
      remindAt: event.remindAt,
    ),
  );
}
