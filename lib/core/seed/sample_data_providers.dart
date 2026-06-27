import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import 'sample_data_service.dart';

final sampleDataServiceProvider = Provider<SampleDataService>((ref) {
  return SampleDataService(
    ref.watch(appDatabaseProvider),
    ref.watch(idGeneratorProvider),
    ref.watch(sessionProvider),
  );
});

/// Current demo-data counts for the Settings UI. Invalidate after load/remove.
final sampleDataSummaryProvider = FutureProvider<SampleDataSummary>((ref) {
  return ref.watch(sampleDataServiceProvider).summary();
});
