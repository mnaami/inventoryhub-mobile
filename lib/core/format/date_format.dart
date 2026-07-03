import 'package:intl/intl.dart';

final _dateFormat = DateFormat('MMM d, y', 'en');

/// Formats a date using Latin digits and English month abbreviations,
/// regardless of the active app locale (e.g. 'Jan 5, 2026').
String formatDate(DateTime date) => _dateFormat.format(date);
