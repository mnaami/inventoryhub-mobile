import 'package:flutter_test/flutter_test.dart';
import '../../helpers/test_db.dart';

void main() {
  test('database opens and reports schema version', () async {
    final db = newTestDb();
    expect(db.schemaVersion, 3);
    await db.close();
  });
}
