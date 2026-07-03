import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/seed/sample_data_providers.dart';
import '../../../core/seed/sample_data_service.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/section_header.dart';
import '../../inventory/category/presentation/category_providers.dart';
import '../../inventory/product/presentation/product_providers.dart';
import '../../inventory/stock_movement/presentation/stock_providers.dart';
import '../../inventory/unit/presentation/unit_providers.dart';
import '../../home/presentation/home_providers.dart';
import '../../purchasing/purchase_order/presentation/purchase_order_providers.dart';
import '../../purchasing/supplier/presentation/supplier_providers.dart';
import '../../sales/customer/presentation/customer_providers.dart';
import '../../sales/sale_order/presentation/sale_order_providers.dart';

class SampleDataSection extends ConsumerStatefulWidget {
  const SampleDataSection({super.key});

  @override
  ConsumerState<SampleDataSection> createState() => _SampleDataSectionState();
}

class _SampleDataSectionState extends ConsumerState<SampleDataSection> {
  bool _busy = false;

  Future<void> _load() async {
    setState(() => _busy = true);
    try {
      await ref.read(sampleDataServiceProvider).load();
      ref.invalidate(sampleDataSummaryProvider);
      _refreshDataViews();
      _toast('Sample data added.');
    } catch (_) {
      _toast('Could not add sample data.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove() async {
    final ok = await confirmDialog(
      context,
      title: 'Remove sample data',
      message:
          'This permanently deletes all demo records. Your own data is kept.',
      confirmLabel: 'Remove',
    );
    if (!ok) return;
    if (!mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(sampleDataServiceProvider).remove();
      ref.invalidate(sampleDataSummaryProvider);
      _refreshDataViews();
      _toast('Sample data removed.');
    } catch (_) {
      _toast('Could not remove sample data.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _refreshDataViews() {
    ref.invalidate(homeDashboardProvider);
    ref.invalidate(productListProvider);
    ref.invalidate(productProvider);
    ref.invalidate(lowStockProductsProvider);
    ref.invalidate(stockLedgerProvider);
    ref.invalidate(categoryTreeProvider);
    ref.invalidate(unitsProvider);
    ref.invalidate(saleOrdersProvider);
    ref.invalidate(saleDashboardProvider);
    ref.invalidate(customersProvider);
    ref.invalidate(purchaseOrdersProvider);
    ref.invalidate(purchaseDashboardProvider);
    ref.invalidate(suppliersProvider);
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(sampleDataSummaryProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader('Sample Data'),
        AppCard(
          padding: const EdgeInsets.all(18),
          child: summary.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppTokens.space8),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const Text('Could not read sample-data status.'),
            data: (s) => _body(context, s),
          ),
        ),
      ],
    );
  }

  Widget _body(BuildContext context, SampleDataSummary s) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    if (_busy) {
      return const Padding(
        padding: EdgeInsets.all(AppTokens.space8),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!s.isLoaded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Load a demo hardware-store dataset to explore the app.',
            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.download_rounded),
              label: const Text('Load sample data'),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sample data loaded — ${s.products} products, ${s.sales} sales, ${s.purchases} purchases.',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _remove,
            style: OutlinedButton.styleFrom(
              foregroundColor: scheme.error,
              side: BorderSide(color: scheme.error.withOpacity(0.5)),
            ),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Remove sample data'),
          ),
        ),
      ],
    );
  }
}
