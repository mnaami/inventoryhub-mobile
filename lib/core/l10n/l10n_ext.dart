import 'package:flutter/widgets.dart';
import 'package:inventoryhub_mobile/l10n/app_localizations.dart';

/// Shorthand for the generated localizations: `context.l10n.someKey`.
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
