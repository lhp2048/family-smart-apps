enum EbookKind {
  folder,
  markdown,
  pdf,
  epub,
  text,
  unknown,
}

class EbookFolderMeta {
  const EbookFolderMeta({
    this.title = '',
    this.description = '',
    this.author = '',
    this.tags = const [],
    this.coverUrl = '',
  });

  final String title;
  final String description;
  final String author;
  final List<String> tags;
  final String coverUrl;
}

class EbookEntry {
  const EbookEntry({
    required this.name,
    required this.subPath,
    required this.relPath,
    required this.isDir,
    required this.kind,
    this.size = 0,
    this.modifiedAt,
    this.publicUrl = '',
  });

  final String name;
  final String subPath;
  final String relPath;
  final bool isDir;
  final EbookKind kind;
  final int size;
  final DateTime? modifiedAt;
  final String publicUrl;
}

class EbookBrowseResult {
  const EbookBrowseResult({
    required this.root,
    required this.dir,
    required this.path,
    required this.parent,
    required this.folder,
    required this.entries,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  final String root;
  final String dir;
  final String path;
  final String parent;
  final EbookFolderMeta folder;
  final List<EbookEntry> entries;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;
}
