import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers.dart';
import '../data/stock_movement_dao.dart';
import '../data/stock_movement_repository_impl.dart';
import '../domain/stock_movement.dart';
import '../domain/stock_movement_usecases.dart';

final stockServiceProvider = Provider<StockService>((ref) {
  final session = ref.watch(sessionProvider);
  return StockService(
    repository: StockMovementRepositoryImpl(
        StockMovementDao(ref.watch(appDatabaseProvider))),
    ids: ref.watch(idGeneratorProvider),
    organizationId: session.organizationId,
    userId: session.userId,
  );
});

final productHistoryProvider =
    FutureProvider.family<List<StockMovement>, String>((ref, productId) {
  return ref.watch(stockServiceProvider).history(productId);
});

final stockLedgerProvider = FutureProvider<List<StockMovement>>((ref) {
  return ref.watch(stockServiceProvider).ledger();
});
