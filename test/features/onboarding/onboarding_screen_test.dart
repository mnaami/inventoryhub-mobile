import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventoryhub_mobile/app/theme/theme_controller.dart';
import 'package:inventoryhub_mobile/features/onboarding/presentation/onboarding_controller.dart';
import 'package:inventoryhub_mobile/features/onboarding/presentation/onboarding_screen.dart';
import '../../helpers/l10n.dart';

Future<ProviderContainer> _pump(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: localizedApp(home: const OnboardingScreen()),
  ));
  return container;
}

void main() {
  testWidgets('shows the first slide title', (tester) async {
    await _pump(tester);
    expect(find.text('Know your stock'), findsOneWidget);
  });

  testWidgets('Skip marks onboarding seen', (tester) async {
    final c = await _pump(tester);
    await tester.tap(find.byKey(const Key('onboarding_skip')));
    await tester.pumpAndSettle();
    expect(c.read(onboardingSeenProvider), isTrue);
  });

  testWidgets('swiping to the last slide reveals Get started, which marks seen',
      (tester) async {
    final c = await _pump(tester);
    await tester.fling(
        find.byType(PageView), const Offset(-600, 0), 1000);
    await tester.pumpAndSettle();
    await tester.fling(
        find.byType(PageView), const Offset(-600, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Make and manage'), findsOneWidget);
    await tester.tap(find.byKey(const Key('onboarding_get_started')));
    await tester.pumpAndSettle();
    expect(c.read(onboardingSeenProvider), isTrue);
  });
}
