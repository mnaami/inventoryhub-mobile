import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventoryhub_mobile/app/theme/theme_controller.dart';
import 'package:inventoryhub_mobile/features/onboarding/presentation/onboarding_controller.dart';

Future<ProviderContainer> _container(Map<String, Object> seedPrefs) async {
  SharedPreferences.setMockInitialValues(seedPrefs);
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('defaults to not seen', () async {
    final c = await _container({});
    expect(c.read(onboardingSeenProvider), isFalse);
  });

  test('restores seen when persisted', () async {
    final c = await _container({'onboarding.seen': true});
    expect(c.read(onboardingSeenProvider), isTrue);
  });

  test('markSeen flips state and persists', () async {
    final c = await _container({});
    await c.read(onboardingSeenProvider.notifier).markSeen();
    expect(c.read(onboardingSeenProvider), isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('onboarding.seen'), isTrue);
  });
}
