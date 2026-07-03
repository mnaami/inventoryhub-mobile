import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/widgets/search_field.dart';
import '../../helpers/l10n.dart';

Widget _wrap(Widget c) => localizedApp(home: Scaffold(body: c));

void main() {
  testWidgets('debounces onChanged until typing pauses', (tester) async {
    final calls = <String>[];
    await tester.pumpWidget(_wrap(SearchField(
      debounce: const Duration(milliseconds: 100),
      onChanged: calls.add,
    )));
    await tester.enterText(find.byType(TextField), 'ab');
    expect(calls, isEmpty); // not yet
    await tester.pump(const Duration(milliseconds: 120));
    expect(calls, ['ab']);
  });

  testWidgets('clear button empties and fires empty onChanged', (tester) async {
    final calls = <String>[];
    await tester.pumpWidget(_wrap(SearchField(
      debounce: const Duration(milliseconds: 50),
      onChanged: calls.add,
    )));
    await tester.enterText(find.byType(TextField), 'x');
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();
    expect(calls.last, '');
  });

  testWidgets('cancels pending debounce on dispose (no callback, no pending timer)',
      (tester) async {
    final calls = <String>[];
    await tester.pumpWidget(_wrap(SearchField(
      debounce: const Duration(milliseconds: 100),
      onChanged: calls.add,
    )));
    await tester.enterText(find.byType(TextField), 'abc');
    // Replace the widget (disposing the SearchField) before the timer fires.
    await tester.pumpWidget(_wrap(const SizedBox()));
    await tester.pump(const Duration(milliseconds: 200));
    expect(calls, isEmpty); // debounced callback was cancelled
    // Test completing without a "Timer is still pending" error proves cleanup.
  });
}
