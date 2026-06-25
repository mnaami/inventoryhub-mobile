// Placeholder widget test — will be replaced in later tasks.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Placeholder smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: Center(child: Text('InventoryHub'))),
        ),
      ),
    );
    expect(find.text('InventoryHub'), findsOneWidget);
  });
}
