import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/theme_controller.dart'; // sharedPrefsProvider

final onboardingSeenProvider =
    NotifierProvider<OnboardingController, bool>(OnboardingController.new);

class OnboardingController extends Notifier<bool> {
  static const _key = 'onboarding.seen';

  @override
  bool build() => ref.watch(sharedPrefsProvider).getBool(_key) ?? false;

  Future<void> markSeen() async {
    await ref.read(sharedPrefsProvider).setBool(_key, true);
    state = true;
  }
}
