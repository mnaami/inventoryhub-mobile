import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/features/inventory/product/data/photo_storage.dart';

void main() {
  test('save copies the file into product_photos and returns its path',
      () async {
    final base = await Directory.systemTemp.createTemp('photos_test');
    addTearDown(() => base.delete(recursive: true));
    final source = File('${base.path}/src.jpg')..writeAsBytesSync([1, 2, 3]);

    final storage = PhotoStorage(base, const IdGenerator());
    final saved = await storage.save(source);

    expect(saved, contains('product_photos'));
    expect(File(saved).existsSync(), isTrue);
    expect(File(saved).readAsBytesSync(), [1, 2, 3]);

    await storage.delete(saved);
    expect(File(saved).existsSync(), isFalse);
  });
}
