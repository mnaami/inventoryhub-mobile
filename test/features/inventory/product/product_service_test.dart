import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/result/app_exception.dart';
import 'package:inventoryhub_mobile/features/inventory/product/data/product_dao.dart';
import 'package:inventoryhub_mobile/features/inventory/product/data/product_repository_impl.dart';
import 'package:inventoryhub_mobile/features/inventory/product/domain/product_usecases.dart';
import '../../../helpers/test_db.dart';

void main() {
  late ProductService service;
  late dynamic db;

  setUp(() {
    db = newTestDb();
    service = ProductService(
      repository: ProductRepositoryImpl(ProductDao(db)),
      ids: const IdGenerator(),
      organizationId: 'org1',
    );
  });
  tearDown(() => db.close());

  test('create starts a product at zero stock', () async {
    final p = await service.create(name: 'Widget', unitId: 'pc');
    expect(p.currentStock, 0);
    expect((await service.get(p.id))!.name, 'Widget');
  });

  test('create rejects a blank name', () async {
    expect(() => service.create(name: '  ', unitId: 'pc'),
        throwsA(isA<ValidationException>()));
  });

  test('findByBarcode returns the matching product', () async {
    await service.create(name: 'Widget', unitId: 'pc', barcode: '12345');
    expect((await service.findByBarcode('12345'))!.name, 'Widget');
    expect(await service.findByBarcode('00000'), isNull);
  });

  test('edit never changes current stock', () async {
    final p = await service.create(name: 'Widget', unitId: 'pc');
    // simulate stock having been changed by the ledger
    final withStock = p.copyWith(currentStock: 99);
    await service.edit(withStock.copyWith(name: 'Renamed'));
    final reloaded = await service.get(p.id);
    expect(reloaded!.name, 'Renamed');
    expect(reloaded.currentStock, 0); // update companion omitted current_stock
  });
}
