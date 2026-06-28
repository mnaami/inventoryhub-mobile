import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/result/app_exception.dart';
import '../domain/category.dart';
import 'category_providers.dart';

class AddEditCategoryScreen extends ConsumerStatefulWidget {
  const AddEditCategoryScreen({super.key, this.existing});
  final Category? existing;

  @override
  ConsumerState<AddEditCategoryScreen> createState() => _State();
}

class _State extends ConsumerState<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.name ?? '');
  String? _parentId;

  @override
  void initState() {
    super.initState();
    _parentId = widget.existing?.parentCategoryId;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final treeAsync = ref.watch(categoryTreeProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit category' : 'New category')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Details Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category Details',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.label_outline),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  treeAsync.maybeWhen(
                    data: (nodes) => DropdownButtonFormField<String?>(
                      value: _parentId,
                      decoration: const InputDecoration(
                        labelText: 'Parent (optional)',
                        prefixIcon: Icon(Icons.account_tree_outlined),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('— None —')),
                        for (final c in _flatten(nodes))
                          if (c.id != widget.existing?.id)
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      ],
                      onChanged: (v) => setState(() => _parentId = v),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.space24),
            FilledButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }

  List<Category> _flatten(List<CategoryNode> nodes) => [
        for (final n in nodes) ...[n.category, ..._flatten(n.children)],
      ];

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final service = ref.read(categoryServiceProvider);
    try {
      if (widget.existing == null) {
        await service.create(name: _name.text, parentId: _parentId);
      } else {
        await service.rename(widget.existing!
            .copyWith(name: _name.text, parentCategoryId: _parentId));
      }
      ref.invalidate(categoryTreeProvider);
      if (mounted) Navigator.of(context).pop();
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}
