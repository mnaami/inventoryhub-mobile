import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/db/app_database.dart';
import 'core/id/id_generator.dart';
import 'core/providers.dart';
import 'core/seed/seed_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase.open();
  final session = await SeedService(db, const IdGenerator()).ensureSeeded();
  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sessionProvider.overrideWithValue(session),
      ],
      child: const _BootstrapApp(),
    ),
  );
}

// Temporary home; replaced by the router in Phase 6 (Task 20).
class _BootstrapApp extends ConsumerWidget {
  const _BootstrapApp();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Org: ${session.organizationId}')),
      ),
    );
  }
}
