import '../layout/home_layout_models.dart';
import 'home_card_preview_models.dart';

HomeCardPreview parseHomeCardPreview(Map<String, dynamic> data) {
  final cardId = data['cardId']?.toString() ?? '';
  final size = HomeCardSize.fromJson(data['size']?.toString());
  final presentationRaw = data['presentation'];
  final presentation = presentationRaw is Map
      ? _parsePresentation(Map<String, dynamic>.from(presentationRaw))
      : const HomeCardPresentationEmpty();
  return HomeCardPreview(
    cardId: cardId,
    size: size,
    presentation: presentation,
    title: _optionalNonEmpty(data['title']?.toString()),
    subtitle: _optionalNonEmpty(data['subtitle']?.toString()),
    updatedAt: data['updatedAt']?.toString(),
  );
}

String? _optionalNonEmpty(String? raw) {
  final v = raw?.trim();
  if (v == null || v.isEmpty) return null;
  return v;
}

HomeCardPresentation _parsePresentation(Map<String, dynamic> m) {
  switch (m['type']?.toString()) {
    case 'compact':
      final badge = m['badge']?.toString().trim();
      final hint = m['hint']?.toString().trim();
      return HomeCardPresentationCompact(
        badge: badge == null || badge.isEmpty ? null : badge,
        hint: hint == null || hint.isEmpty ? null : hint,
      );
    case 'rows':
      final rowsRaw = m['rows'];
      final rows = <HomeCardPreviewRow>[];
      if (rowsRaw is List) {
        for (final e in rowsRaw) {
          if (e is! Map) continue;
          final row = Map<String, dynamic>.from(e);
          rows.add(
            HomeCardPreviewRow(
              label: row['label']?.toString() ?? '',
              value: row['value']?.toString() ?? '',
              secondary: row['secondary']?.toString(),
            ),
          );
        }
      }
      final footer = m['footer']?.toString().trim();
      return HomeCardPresentationRows(
        rows: rows,
        footer: footer == null || footer.isEmpty ? null : footer,
      );
    case 'highlights':
      final hlRaw = m['highlights'];
      final highlights = <HomeCardPreviewHighlight>[];
      if (hlRaw is List) {
        for (final e in hlRaw) {
          if (e is! Map) continue;
          final h = Map<String, dynamic>.from(e);
          highlights.add(
            HomeCardPreviewHighlight(
              type: h['type']?.toString() ?? '',
              label: h['label']?.toString() ?? '',
              detail: h['detail']?.toString() ?? '',
            ),
          );
        }
      }
      return HomeCardPresentationHighlights(highlights: highlights);
    case 'empty':
      return HomeCardPresentationEmpty(
        message: m['message']?.toString() ?? '',
      );
    default:
      return const HomeCardPresentationEmpty();
  }
}
