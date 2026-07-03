import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/providers.dart';
import '../../../../core/result/app_exception.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../l10n/app_localizations.dart';
import '../../category/domain/category.dart';
import '../../category/presentation/category_providers.dart';
import '../../unit/presentation/unit_providers.dart';
import '../domain/product.dart';
import 'barcode_scan_screen.dart';
import 'product_providers.dart';

class AddEditProductScreen extends ConsumerStatefulWidget {
  const AddEditProductScreen({super.key, this.existing});
  final Product? existing;
  @override
  ConsumerState<AddEditProductScreen> createState() => _State();
}

class _State extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _desc =
      TextEditingController(text: widget.existing?.description ?? '');
  late final _purchase = TextEditingController(
      text: (widget.existing?.purchasePrice ?? 0).toString());
  late final _selling = TextEditingController(
      text: (widget.existing?.sellingPrice ?? 0).toString());
  late final _min = TextEditingController(
      text: (widget.existing?.minimumStock ?? 0).toString());
  late final _barcode =
      TextEditingController(text: widget.existing?.barcode ?? '');
  String? _categoryId;
  String? _unitId;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.existing?.categoryId;
    _unitId = widget.existing?.unitId;
    _imagePath = widget.existing?.imagePath;
  }

  @override
  void dispose() {
    for (final c in [_name, _desc, _purchase, _selling, _min, _barcode]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEdit = widget.existing != null;
    _unitId ??= ref.watch(sessionProvider).defaultUnitId;
    final categories = ref.watch(categoryTreeProvider);
    final units = ref.watch(unitsProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
          title: Text(isEdit ? l10n.productEditTitle : l10n.productNewTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            _photoPicker(l10n),
            const SizedBox(height: AppTokens.space24),

            // Details card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.productDetailsHeading,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _name,
                    decoration: InputDecoration(
                      labelText: l10n.productNameLabel,
                      prefixIcon: const Icon(Icons.label_outline),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.productNameRequired
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _desc,
                    decoration: InputDecoration(
                      labelText: l10n.productDescriptionLabel,
                      prefixIcon: const Icon(Icons.notes_outlined),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  categories.maybeWhen(
                    data: (nodes) => DropdownButtonFormField<String?>(
                      value: _categoryId,
                      decoration: InputDecoration(
                        labelText: l10n.productCategoryLabel,
                        prefixIcon: const Icon(Icons.folder_outlined),
                      ),
                      items: [
                        DropdownMenuItem(
                            value: null, child: Text(l10n.productCategoryNone)),
                        for (final c in _flatten(nodes))
                          DropdownMenuItem(value: c.id, child: Text(c.name)),
                      ],
                      onChanged: (v) => setState(() => _categoryId = v),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 16),
                  units.maybeWhen(
                    data: (list) => DropdownButtonFormField<String>(
                      value: _unitId,
                      decoration: InputDecoration(
                        labelText: l10n.productUnitLabel,
                        prefixIcon: const Icon(Icons.straighten_outlined),
                      ),
                      items: [
                        for (final u in list)
                          DropdownMenuItem(value: u.id, child: Text(u.name)),
                      ],
                      onChanged: (v) => setState(() => _unitId = v),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.space16),

            // Pricing Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.productPricingHeading,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _purchase,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: l10n.productPurchasePriceLabel,
                            prefixIcon: const Icon(Icons.arrow_downward_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTokens.space12),
                      Expanded(
                        child: TextFormField(
                          controller: _selling,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: l10n.productSellingPriceLabel,
                            prefixIcon: const Icon(Icons.arrow_upward_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.space16),

            // Stock & Identification Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.productStockIdHeading,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _min,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: l10n.productMinimumStockLabel,
                      prefixIcon: const Icon(Icons.inventory_2_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _barcode,
                    decoration: InputDecoration(
                      labelText: l10n.productBarcodeLabel,
                      prefixIcon: const Icon(Icons.qr_code_outlined),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: _scan,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.space24),

            FilledButton(
              onPressed: _save,
              child: Text(l10n.productSave),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoPicker(AppLocalizations l10n) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _imagePath != null
                ? Image.file(File(_imagePath!), height: 100, width: 100, fit: BoxFit.cover)
                : Container(
                    height: 100,
                    width: 100,
                    color: scheme.primary.withOpacity(0.08),
                    child: Icon(Icons.inventory_2_outlined, size: 48, color: scheme.primary),
                  ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _pickPhoto,
            icon: const Icon(Icons.photo_camera_outlined),
            label: Text(
                _imagePath != null ? l10n.productChangePhoto : l10n.productAddPhoto),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final storage = await ref.read(photoStorageProvider.future);
    final path = await storage.save(File(picked.path));
    setState(() => _imagePath = path);
  }

  Future<void> _scan() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const BarcodeScanScreen()),
    );
    if (code != null) setState(() => _barcode.text = code);
  }

  List<Category> _flatten(List<CategoryNode> nodes) => [
        for (final n in nodes) ...[n.category, ..._flatten(n.children)],
      ];

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final service = ref.read(productServiceProvider);
    final barcode = _barcode.text.trim().isEmpty ? null : _barcode.text.trim();
    try {
      if (widget.existing == null) {
        await service.create(
          name: _name.text,
          unitId: _unitId!,
          description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
          categoryId: _categoryId,
          purchasePrice: double.tryParse(_purchase.text) ?? 0,
          sellingPrice: double.tryParse(_selling.text) ?? 0,
          minimumStock: double.tryParse(_min.text) ?? 0,
          barcode: barcode,
          imagePath: _imagePath,
        );
      } else {
        await service.edit(widget.existing!.copyWith(
          name: _name.text.trim(),
          description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
          categoryId: _categoryId,
          unitId: _unitId!,
          purchasePrice: double.tryParse(_purchase.text) ?? 0,
          sellingPrice: double.tryParse(_selling.text) ?? 0,
          minimumStock: double.tryParse(_min.text) ?? 0,
          barcode: barcode,
          imagePath: _imagePath,
        ));
      }
      if (mounted) Navigator.of(context).pop(true);
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}
