import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_tokens.dart';
import 'onboarding_controller.dart';

class _Slide {
  const _Slide(this.icon, this.title, this.body);
  final IconData icon;
  final String title;
  final String body;
}

const _slides = <_Slide>[
  _Slide(Icons.inventory_2_outlined, 'Know your stock',
      'Track every product, category, and stock movement — instantly, and fully offline.'),
  _Slide(Icons.swap_horiz_rounded, 'Sell and restock',
      'Raise sale and purchase orders, record payments, and keep stock in sync automatically.'),
  _Slide(Icons.precision_manufacturing_outlined, 'Make and manage',
      'Turn ingredients into products with recipes, and track it all from live dashboards.'),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() =>
      ref.read(onboardingSeenProvider.notifier).markSeen();

  void _next() {
    if (_page == _slides.length - 1) {
      _finish();
    } else {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLast = _page == _slides.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                key: const Key('onboarding_skip'),
                onPressed: _finish,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  final s = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(s.icon, size: 96, color: scheme.primary),
                        const SizedBox(height: AppTokens.space24),
                        Text(s.title,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppTokens.space12),
                        Text(s.body,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? scheme.primary
                        : scheme.onSurfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppTokens.space24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: Key(isLast ? 'onboarding_get_started' : 'onboarding_next'),
                  onPressed: _next,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(isLast ? 'Get started' : 'Next'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTokens.space24),
          ],
        ),
      ),
    );
  }
}
