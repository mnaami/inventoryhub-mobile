import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/providers.dart';
import '../../../../core/result/app_exception.dart';
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
    final isEdit = widget.existing != null;
    _unitId ??= ref.watch(sessionProvider).defaultUnitId;
    final categories = ref.watch(categoryTreeProvider);
    final units = ref.watch(unitsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit product' : 'New product')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _photoPicker(),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            TextFormField(
              controller: _desc,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            categories.maybeWhen(
              data: (nodes) => DropdownButtonFormField<String?>(
                initialValue: _categoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('— None —')),
                  for (final c in _flatten(nodes))
                    DropdownMenuItem(value: c.id, child: Text(c.name)),
                ],
                onChanged: (v) => setState(() => _categoryId = v),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
            units.maybeWhen(
              data: (list) => DropdownButtonFormField<String>(
                initialValue: _unitId,
                decoration: const InputDecoration(labelText: 'Unit'),
                items: [
                  for (final u in list)
                    DropdownMenuItem(value: u.id, child: Text(u.name)),
                ],
                onChanged: (v) => setState(() => _unitId = v),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _purchase,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Purchase price'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _selling,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Selling price'),
                ),
              ),
            ]),
            TextFormField(
              controller: _min,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Minimum stock'),
            ),
            TextFormField(
              controller: _barcode,
              decoration: InputDecoration(
                labelText: 'Barcode',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _scan,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }

  Widget _photoPicker() {
    return Center(
      child: Column(children: [
        if (_imagePath != null)
          Image.file(File(_imagePath!), height: 120, fit: BoxFit.cover)
        else
          const Icon(Icons.inventory_2_outlined, size: 96),
        TextButton.icon(
          onPressed: _pickPhoto,
          icon: const Icon(Icons.photo_camera),
          label: const Text('Add photo'),
        ),
      ]),
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
