/// Formats a quantity value, dropping the trailing `.0` for whole numbers.
/// Examples: 5.0 → '5', 5.5 → '5.5', 0.0 → '0'.
String formatQty(double v) =>
    v.toStringAsFixed(v == v.roundToDouble() ? 0 : 1);
