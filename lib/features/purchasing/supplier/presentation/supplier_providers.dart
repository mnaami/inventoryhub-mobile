import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers.dart';
import '../data/supplier_dao.dart';
import '../data/supplier_repository_impl.dart';
import '../domain/supplier.dart';
import '../domain/supplier_usecases.dart';

final supplierServiceProvider = Provider<SupplierService>((ref) {
  return SupplierService(
    repository:
        SupplierRepositoryImpl(SupplierDao(ref.watch(appDatabaseProvider))),
    ids: ref.watch(idGeneratorProvider),
    organizationId: ref.watch(sessionProvider).organizationId,
  );
});

final suppliersProvider = FutureProvider<List<Supplier>>((ref) {
  return ref.watch(supplierServiceProvider).list();
});

final supplierProvider =
    FutureProvider.family<Supplier?, String>((ref, id) {
  return ref.watch(supplierServiceProvider).get(id);
});
