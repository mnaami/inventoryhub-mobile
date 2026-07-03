import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../domain/category.dart';
import 'add_edit_category_screen.dart';
import 'category_providers.dart';

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tree = ref.watch(categoryTreeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.categoriesTitle)),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () => _openEditor(context),
        child: const Icon(Icons.add),
      ),
      body: AsyncValueView<List<CategoryNode>>(
        value: tree,
        data: (nodes) => nodes.isEmpty
            ? EmptyState(
                icon: Icons.category_outlined,
                title: l10n.categoryEmptyTitle,
                subtitle: l10n.categoryEmptySubtitle,
                actionLabel: l10n.categoryEmptyAction,
                onAction: () => _openEditor(context),
              )
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  for (final n in nodes) _tile(context, ref, n, 0),
                ],
              ),
      ),
    );
  }

  Widget _tile(BuildContext context, WidgetRef ref, CategoryNode node, int depth) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: AppTokens.space16 * depth,
            bottom: AppTokens.space8,
          ),
          child: AppCard(
            onTap: () => _openEditor(context, existing: node.category),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            child: Row(
              children: [
                // Color/icon swatch
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.folder_outlined,
                    size: 18,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: AppTokens.space12),
                Expanded(
                  child: Text(
                    node.category.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                if (node.children.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: AppTokens.space4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: scheme.onSurfaceVariant.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${node.children.length}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
                  onPressed: () => _delete(context, ref, node.category),
                ),
              ],
            ),
          ),
        ),
        for (final child in node.children) _tile(context, ref, child, depth + 1),
      ],
    );
  }

  Future<void> _openEditor(BuildContext context, {Category? existing}) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AddEditCategoryScreen(existing: existing),
    ));
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Category c) async {
    final l10n = context.l10n;
    if (!await confirmDialog(context,
        title: l10n.categoryDeleteTitle,
        message: l10n.categoryDeleteConfirm(c.name))) {
      return;
    }
    try {
      await ref.read(categoryServiceProvider).delete(c.id);
      ref.invalidate(categoryTreeProvider);
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}
