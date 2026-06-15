import '../../../shared/models/feature_entry_entity.dart';
import 'family_api_client.dart';

FeatureEntryEntity featureEntryFromApiMap(Map<String, dynamic> m) {
  final e = FeatureEntryEntity();
  e.entryKey = m['entryKey']?.toString() ?? m['entry_key']?.toString() ?? '';
  e.title = m['title']?.toString() ?? '';
  e.icon = m['icon']?.toString() ?? 'apps_outlined';
  e.sort = (m['sort'] as num?)?.toInt() ??
      (m['sortOrder'] as num?)?.toInt() ??
      (m['sort_order'] as num?)?.toInt() ??
      0;
  final enabledRaw = m['enabled'];
  e.enabled = enabledRaw == true ||
      enabledRaw == 1 ||
      enabledRaw == '1' ||
      enabledRaw == 'true' ||
      enabledRaw == null;
  e.updatedAt = DateTime.now();
  return e;
}

Future<List<FeatureEntryEntity>> fetchFeatureEntriesRemote(
  FamilyApiClient client,
) async {
  final data = await client.fetchFeatureEntries();
  final raw = data['list'];
  if (raw is! List) return const [];
  final out = <FeatureEntryEntity>[];
  for (final item in raw) {
    if (item is! Map) continue;
    final e = featureEntryFromApiMap(Map<String, dynamic>.from(item));
    if (e.entryKey.isEmpty || !e.enabled) continue;
    out.add(e);
  }
  out.sort((a, b) => a.sort.compareTo(b.sort));
  return out;
}
