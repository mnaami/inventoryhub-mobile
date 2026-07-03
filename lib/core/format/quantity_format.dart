/// Formats a quantity value, dropping the trailing `.0` for whole numbers.
/// Examples: 5.0 → '5', 5.5 → '5.5', 0.0 → '0'.
// Note: toStringAsFixed always produces Latin/Western digits regardless of
// locale, so it is already safe for Arabic UI — no locale pinning needed here.
String formatQty(double v) =>
    v.toStringAsFixed(v == v.roundToDouble() ? 0 : 1);
