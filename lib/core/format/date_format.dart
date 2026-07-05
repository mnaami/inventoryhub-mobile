import 'package:intl/intl.dart';

final _dateFormat = DateFormat('MMM d, y', 'en');
final _dateTimeFormat = DateFormat('MMM d, y • h:mm a', 'en');

/// Formats a date using Latin digits and English month abbreviations,
/// regardless of the active app locale (e.g. 'Jan 5, 2026').
String formatDate(DateTime date) => _dateFormat.format(date);

/// Like [formatDate] but includes the time of day (e.g.
/// 'Jan 5, 2026 • 2:30 PM'). Normalizes to local time first so UTC-stamped
/// timestamps display at the user's wall clock (a no-op for local values).
String formatDateTime(DateTime date) => _dateTimeFormat.format(date.toLocal());
