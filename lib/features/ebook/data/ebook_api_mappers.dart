import 'ebook_models.dart';

EbookKind ebookKindFromApi(String? raw, {required bool isDir}) {
  if (isDir) return EbookKind.folder;
  switch (raw?.toLowerCase()) {
    case 'markdown':
      return EbookKind.markdown;
    case 'pdf':
      return EbookKind.pdf;
    case 'epub':
      return EbookKind.epub;
    case 'text':
      return EbookKind.text;
    default:
      return EbookKind.unknown;
  }
}

DateTime? _parseDateTime(dynamic raw) {
  if (raw == null) return null;
  final text = raw.toString().trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text);
}

EbookFolderMeta mapEbookFolderMeta(Map<String, dynamic>? raw) {
  if (raw == null) return const EbookFolderMeta();
  final tagsRaw = raw['tags'];
  final tags = tagsRaw is List
      ? tagsRaw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
      : <String>[];
  return EbookFolderMeta(
    title: raw['title']?.toString() ?? '',
    description: raw['description']?.toString() ?? '',
    author: raw['author']?.toString() ?? '',
    tags: tags,
    coverUrl: raw['cover_url']?.toString() ?? '',
  );
}

EbookEntry mapEbookEntry(Map<String, dynamic> raw) {
  final isDir = raw['is_dir'] == true;
  return EbookEntry(
    name: raw['name']?.toString() ?? '',
    subPath: raw['sub_path']?.toString() ?? '',
    relPath: raw['rel_path']?.toString() ?? '',
    isDir: isDir,
    kind: ebookKindFromApi(raw['kind']?.toString(), isDir: isDir),
    size: raw['size'] is int
        ? raw['size'] as int
        : int.tryParse('${raw['size']}') ?? 0,
    modifiedAt: _parseDateTime(raw['modified_at']),
    publicUrl: raw['public_url']?.toString() ?? '',
  );
}

EbookBrowseResult mapEbookBrowseResult(Map<String, dynamic> raw) {
  final entriesRaw = raw['entries'];
  final entries = entriesRaw is List
      ? entriesRaw
          .whereType<Map>()
          .map((e) => mapEbookEntry(Map<String, dynamic>.from(e)))
          .toList()
      : <EbookEntry>[];
  return EbookBrowseResult(
    root: raw['root']?.toString() ?? '',
    dir: raw['dir']?.toString() ?? '',
    path: raw['path']?.toString() ?? '',
    parent: raw['parent']?.toString() ?? '',
    folder: mapEbookFolderMeta(
      raw['folder'] is Map
          ? Map<String, dynamic>.from(raw['folder'] as Map)
          : null,
    ),
    entries: entries,
    total: raw['total'] is int
        ? raw['total'] as int
        : int.tryParse('${raw['total']}') ?? entries.length,
    page: raw['page'] is int
        ? raw['page'] as int
        : int.tryParse('${raw['page']}') ?? 1,
    pageSize: raw['page_size'] is int
        ? raw['page_size'] as int
        : int.tryParse('${raw['page_size']}') ?? 15,
    totalPages: raw['total_pages'] is int
        ? raw['total_pages'] as int
        : int.tryParse('${raw['total_pages']}') ?? 1,
  );
}

EbookKind ebookKindFromRoute(String? raw) {
  switch (raw?.toLowerCase()) {
    case 'markdown':
      return EbookKind.markdown;
    case 'pdf':
      return EbookKind.pdf;
    case 'epub':
      return EbookKind.epub;
    case 'text':
      return EbookKind.text;
    default:
      return EbookKind.unknown;
  }
}

String ebookKindLabel(EbookKind kind) {
  switch (kind) {
    case EbookKind.folder:
      return '文件夹';
    case EbookKind.markdown:
      return 'Markdown';
    case EbookKind.pdf:
      return 'PDF';
    case EbookKind.epub:
      return 'EPUB';
    case EbookKind.text:
      return 'TXT';
    case EbookKind.unknown:
      return '文件';
  }
}

String ebookKindEmoji(EbookKind kind) {
  switch (kind) {
    case EbookKind.folder:
      return '📁';
    case EbookKind.markdown:
      return '📝';
    case EbookKind.pdf:
      return '📕';
    case EbookKind.epub:
      return '📘';
    case EbookKind.text:
      return '📄';
    case EbookKind.unknown:
      return '📖';
  }
}
