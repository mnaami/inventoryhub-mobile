// test/core/widgets/ui_kit_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/widgets/status_badge.dart';
import 'package:inventoryhub_mobile/core/widgets/empty_state.dart';
import '../../helpers/l10n.dart';

Widget _wrap(Widget c) => localizedApp(home: Scaffold(body: c));

void main() {
  testWidgets('StatusBadge.low renders exactly "Low"', (tester) async {
    await tester.pumpWidget(_wrap(const StatusBadge.low()));
    expect(find.text('Low'), findsOneWidget);
  });

  testWidgets('StatusBadge.out renders exactly "Out"', (tester) async {
    await tester.pumpWidget(_wrap(const StatusBadge.out()));
    expect(find.text('Out'), findsOneWidget);
  });

  testWidgets('EmptyState shows CTA only when action provided', (tester) async {
    await tester.pumpWidget(_wrap(const EmptyState(
      icon: Icons.inbox, title: 'Nothing', subtitle: 'sub')));
    expect(find.byType(FilledButton), findsNothing);

    await tester.pumpWidget(_wrap(EmptyState(
      icon: Icons.inbox, title: 'Nothing', actionLabel: 'Add', onAction: () {})));
    expect(find.widgetWithText(FilledButton, 'Add'), findsOneWidget);
  });
}
