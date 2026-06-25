import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/confirm_dialog.dart';
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
            ? const Center(child: Text('No categories yet. Tap + to add one.'))
            : ListView(children: [for (final n in nodes) _tile(context, ref, n, 0)]),
      ),
    );
  }

  Widget _tile(BuildContext context, WidgetRef ref, CategoryNode node, int depth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.0 * depth),
          child: ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: Text(node.category.name),
            onTap: () => _openEditor(context, existing: node.category),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(context, ref, node.category),
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
