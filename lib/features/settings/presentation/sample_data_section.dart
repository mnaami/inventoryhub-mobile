import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/seed/sample_data_providers.dart';
import '../../../core/seed/sample_data_service.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/section_header.dart';

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
      _toast('Sample data removed.');
    } catch (_) {
      _toast('Could not remove sample data.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
          const Text('Load a demo hardware-store dataset to explore the app.'),
          const SizedBox(height: AppTokens.space12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.download),
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
        ),
        const SizedBox(height: AppTokens.space12),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _remove,
            style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Remove sample data'),
          ),
        ),
      ],
    );
  }
}
