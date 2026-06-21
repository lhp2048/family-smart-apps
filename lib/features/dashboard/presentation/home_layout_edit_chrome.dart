import 'package:flutter/material.dart';

import '../layout/home_card_catalog.dart';
import '../layout/home_layout_models.dart';

/// 编辑态首页顶栏：标题 + 添加分隔 / 恢复默认 / 完成。
class HomeLayoutEditBar extends StatelessWidget {
  const HomeLayoutEditBar({
    super.key,
    required this.onAddSeparator,
    required this.onRestoreDefault,
    required this.onDone,
  });

  final VoidCallback onAddSeparator;
  final VoidCallback onRestoreDefault;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '编辑首页',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onAddSeparator,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              foregroundColor: Colors.white70,
            ),
            child: const Text('添加分隔'),
          ),
          TextButton(
            onPressed: onRestoreDefault,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              foregroundColor: Colors.white70,
            ),
            child: const Text('恢复默认'),
          ),
          TextButton(
            onPressed: onDone,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              foregroundColor: Colors.white,
            ),
            child: const Text('完成'),
          ),
        ],
      ),
    );
  }
}

/// 编辑态底部：已隐藏项入口。
class HomeLayoutHiddenBanner extends StatelessWidget {
  const HomeLayoutHiddenBanner({
    super.key,
    required this.hiddenCount,
    required this.onTap,
  });

  final int hiddenCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (hiddenCount <= 0) return const SizedBox.shrink();
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.visibility_off_outlined,
                size: 18,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Text(
                '已隐藏 ($hiddenCount)',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String homeLayoutItemLabel(HomeLayoutItem item) {
  if (item is HomeSeparatorLayoutItem) {
    return item.title.trim().isEmpty ? '未命名分隔' : item.title;
  }
  if (item is HomeFeatureLayoutItem) {
    return homeCardCatalogEntry(item.cardId)?.title ?? item.cardId;
  }
  return item.itemId;
}

Future<void> showHomeLayoutHiddenSheet(
  BuildContext context, {
  required List<HomeLayoutItem> hiddenItems,
  required ValueChanged<String> onRestore,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                '已隐藏 (${hiddenItems.length})',
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: hiddenItems.length,
                itemBuilder: (context, index) {
                  final item = hiddenItems[index];
                  return ListTile(
                    title: Text(homeLayoutItemLabel(item)),
                    trailing: TextButton(
                      onPressed: () {
                        onRestore(item.itemId);
                        if (hiddenItems.length <= 1) {
                          Navigator.pop(ctx);
                        }
                      },
                      child: const Text('恢复'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<bool?> confirmRestoreDefaultLayout(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('恢复默认布局'),
      content: const Text('将重置首页卡片顺序、展示样式与分隔标题，是否继续？'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('恢复'),
        ),
      ],
    ),
  );
}

Future<String?> promptSeparatorTitleEdit(
  BuildContext context, {
  required String initial,
}) {
  final ctrl = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('编辑分隔标题'),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: '分组标题',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (v) => Navigator.pop(ctx, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, ctrl.text),
          child: const Text('确定'),
        ),
      ],
    ),
  );
}

Future<bool?> confirmDeleteSeparator(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('删除分隔标题'),
      content: const Text('确定删除此分隔标题吗？'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('删除'),
        ),
      ],
    ),
  );
}
