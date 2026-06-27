import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/settings/presentation/sample_data_section.dart';
import '../../helpers/test_db.dart';

Future<Widget> _app(AppDatabase db, SeededContext session) async => ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sessionProvider.overrideWithValue(session),
      ],
      child: const MaterialApp(home: Scaffold(body: SampleDataSection())),
    );

void main() {
  late AppDatabase db;
  late SeededContext session;

  setUp(() async {
    db = newTestDb();
    session = await SeedService(db, const IdGenerator()).ensureSeeded();
  });
  tearDown(() => db.close());

  testWidgets('shows Load when empty, then switches to Remove after loading',
      (tester) async {
    await tester.pumpWidget(await _app(db, session));
    await tester.pumpAndSettle();

    expect(find.text('Load sample data'), findsOneWidget);
    expect(find.text('Remove sample data'), findsNothing);

    await tester.tap(find.text('Load sample data'));
    await tester.pumpAndSettle();

    expect(find.text('Remove sample data'), findsOneWidget);
    expect(find.text('Load sample data'), findsNothing);
  });

  testWidgets('Remove asks for confirmation and clears the data on confirm',
      (tester) async {
    // Pre-load via the service directly.
    await tester.pumpWidget(await _app(db, session));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Load sample data'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Remove sample data'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Remove'));
    await tester.pumpAndSettle();

    expect(find.text('Load sample data'), findsOneWidget);
    final samples =
        await (db.select(db.products)..where((p) => p.isSample.equals(true))).get();
    expect(samples, isEmpty);
  });
}
