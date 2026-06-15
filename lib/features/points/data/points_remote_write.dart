import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/data/family_api_client.dart';
import '../../dashboard/providers/dashboard_remote_providers.dart';
import '../../dashboard/providers/family_api_write_refresh.dart';

Future<void> syncPointsRecordRemote(
  WidgetRef ref, {
  required String bizDate,
  required String memberCode,
  required String displayName,
  required String description,
  required int delta,
  String? ruleCode,
  String? note,
}) async {
  final client = ref.read(familyApiClientProvider);
  final sign = delta >= 0 ? '+' : '';
  await client.syncPointsRecords([
    {
      'bizDate': bizDate,
      'memberCode': memberCode,
      'displayName': displayName,
      'person': displayName,
      'description': description,
      'delta': delta,
      'deltaStr': '$sign$delta',
      if (ruleCode != null && ruleCode.isNotEmpty) 'ruleCode': ruleCode,
      if (note != null && note.isNotEmpty) 'note': note,
    },
  ]);
  refreshAfterFamilyApiWrite(ref);
}
