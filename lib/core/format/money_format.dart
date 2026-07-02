import 'package:intl/intl.dart';

final _moneyFormat = NumberFormat('#,##0.##');

/// Formats a money amount with thousands separators, dropping trailing
/// zero decimals. Examples: 519156 → '$519,156', 519156.20 → '$519,156.2'.
String formatMoney(num v) => '\$${_moneyFormat.format(v)}';
