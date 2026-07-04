import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers.dart';
import '../data/unit_dao.dart';
import '../data/unit_repository_impl.dart';
import '../domain/unit.dart';
import '../domain/unit_usecases.dart';

final unitServiceProvider = Provider<UnitService>((ref) {
  return UnitService(
    repository: UnitRepositoryImpl(UnitDao(ref.watch(appDatabaseProvider))),
    ids: ref.watch(idGeneratorProvider),
    organizationId: ref.watch(sessionProvider).organizationId,
  );
});

final unitsProvider = FutureProvider<List<Unit>>((ref) {
  return ref.watch(unitServiceProvider).list();
});

/// Resolves a unit id to its display symbol (e.g. `kg`). Returns an empty
/// string when the unit is unknown, so callers can render just the quantity.
final unitSymbolProvider = FutureProvider.family<String, String>((ref, unitId) async {
  final units = await ref.watch(unitsProvider.future);
  for (final u in units) {
    if (u.id == unitId) return u.symbol;
  }
  return '';
});
