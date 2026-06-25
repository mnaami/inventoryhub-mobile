import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'db/app_database.dart';
import 'id/id_generator.dart';
import 'seed/seed_service.dart';

final idGeneratorProvider = Provider<IdGenerator>((_) => const IdGenerator());

/// Overridden in main() with the opened on-device database.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('appDatabaseProvider must be overridden in main()');
});

final seedServiceProvider = Provider<SeedService>((ref) => SeedService(
      ref.watch(appDatabaseProvider),
      ref.watch(idGeneratorProvider),
    ));

/// Overridden in main() after seeding completes.
final sessionProvider = Provider<SeededContext>((ref) {
  throw UnimplementedError('sessionProvider must be overridden in main()');
});
