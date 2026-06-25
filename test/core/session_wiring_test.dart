import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import '../helpers/test_db.dart';

void main() {
  testWidgets('a widget can read the seeded org from sessionProvider',
      (tester) async {
    final db = newTestDb();
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sessionProvider.overrideWithValue(session),
      ],
      child: MaterialApp(
        home: Consumer(builder: (c, ref, _) {
          return Text(ref.watch(sessionProvider).organizationId,
              textDirection: TextDirection.ltr);
        }),
      ),
    ));

    expect(find.text(session.organizationId), findsOneWidget);
    await db.close();
  });
}
