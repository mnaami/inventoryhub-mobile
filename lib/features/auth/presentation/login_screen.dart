import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/l10n/l10n_ext.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _error = false;
  bool _submitting = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _fillDemo() {
    setState(() {
      _username.text = 'admin';
      _password.text = 'admin';
      _error = false;
    });
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = false;
    });
    final ok = await ref
        .read(authControllerProvider.notifier)
        .signIn(_username.text, _password.text);
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _error = !ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.inventory_2_outlined, size: 56, color: scheme.primary),
                const SizedBox(height: AppTokens.space16),
                Text(l10n.appTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppTokens.space8),
                Text(l10n.authSignInSubtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: AppTokens.space24),
                TextField(
                  key: const Key('login_username'),
                  controller: _username,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.authUsernameLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppTokens.space12),
                TextField(
                  key: const Key('login_password'),
                  controller: _password,
                  obscureText: true,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: l10n.authPasswordLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                if (_error) ...[
                  const SizedBox(height: AppTokens.space12),
                  Text(l10n.authInvalidCredentials,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.error)),
                ],
                const SizedBox(height: AppTokens.space24),
                FilledButton(
                  key: const Key('login_submit'),
                  onPressed: _submitting ? null : _submit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(l10n.authSignInButton),
                  ),
                ),
                const SizedBox(height: AppTokens.space16),
                InkWell(
                  key: const Key('login_demo_hint'),
                  onTap: _submitting ? null : _fillDemo,
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.space8, vertical: AppTokens.space4),
                    child: Text(l10n.authDemoHint,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: scheme.primary)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
