import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/result/app_exception.dart';
import '../domain/category.dart';
import 'add_edit_category_screen.dart';
import 'category_providers.dart';

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tree = ref.watch(categoryTreeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(context),
        child: const Icon(Icons.add),
      ),
      body: AsyncValueView<List<CategoryNode>>(
        value: tree,
        data: (nodes) => nodes.isEmpty
            ? EmptyState(
                icon: Icons.category_outlined,
                title: 'No categories yet',
                subtitle: 'Group your products with categories.',
                actionLabel: 'Add category',
                onAction: () => _openEditor(context),
              )
            : ListView(
                padding: const EdgeInsets.all(AppTokens.space16),
                children: [for (final n in nodes) _tile(context, ref, n, 0)],
              ),
      ),
    );
  }

  Widget _tile(BuildContext context, WidgetRef ref, CategoryNode node, int depth) {
    final scheme = Theme.of(context).colorScheme;
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
              horizontal: AppTokens.space12,
              vertical: AppTokens.space8,
            ),
            child: Row(
              children: [
                // Color/icon swatch
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  ),
                  child: Icon(
                    Icons.folder_outlined,
                    size: 20,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: AppTokens.space12),
                Expanded(
                  child: Text(
                    node.category.name,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                if (node.children.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: AppTokens.space4),
                    child: Text(
                      '${node.children.length}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
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
    if (!await confirmDialog(context,
        title: 'Delete category', message: 'Delete "${c.name}"?')) {
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
