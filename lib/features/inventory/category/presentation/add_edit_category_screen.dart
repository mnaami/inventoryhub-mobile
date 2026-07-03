import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../core/l10n/l10n_ext.dart';
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
    final l10n = context.l10n;
    final isEdit = widget.existing != null;
    final treeAsync = ref.watch(categoryTreeProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
          title: Text(isEdit ? l10n.categoryEditTitle : l10n.categoryNewTitle)),
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
                    l10n.categoryDetailsHeading,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _name,
                    decoration: InputDecoration(
                      labelText: l10n.categoryNameLabel,
                      prefixIcon: const Icon(Icons.label_outline),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.categoryNameRequired
                        : null,
                  ),
                  const SizedBox(height: 16),
                  treeAsync.maybeWhen(
                    data: (nodes) => DropdownButtonFormField<String?>(
                      value: _parentId,
                      decoration: InputDecoration(
                        labelText: l10n.categoryParentLabel,
                        prefixIcon: const Icon(Icons.account_tree_outlined),
                      ),
                      items: [
                        DropdownMenuItem(
                            value: null, child: Text(l10n.categoryParentNone)),
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
            FilledButton(onPressed: _save, child: Text(l10n.categorySave)),
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
