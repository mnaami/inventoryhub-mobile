# InventoryHub Mobile

Local-first inventory app (Flutter, Android). Slice 1: inventory core —
products, hierarchical categories, units with conversion, an append-only
stock ledger, barcode scanning, and product photos. No backend yet; SQLite
(Drift) is the source of truth.

## Run

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

## Test

```bash
flutter test
```

## Architecture

Clean Architecture, feature-first. Domain + presentation depend only on
repository interfaces; the Drift data layer is swappable for a future backend.
`products.current_stock` is written only by the transactional stock ledger.
See `../docs/superpowers/specs/2026-06-25-inventory-core-design.md`.

## Manual Smoke-Test Checklist

Run on an emulator or physical device with `flutter run` and verify the
following happy path before shipping a release:

1. **Empty state** — App opens on the Products tab showing an empty-state
   message (no products).
2. **Units** — Navigate to the Units tab. Confirm the seeded "Piece" unit is
   listed. Add "Gram" (base, weight type) and "Kilogram" (derived from Gram,
   factor 1000). Verify both appear in the list.
3. **Categories** — Navigate to the Categories tab. Add "Food". Then add
   child "Snacks" under "Food". Attempt to delete "Food" — confirm the action
   is blocked (has a child category).
4. **Add product** — Navigate to the Products tab and add "Widget" (category:
   Snacks, unit: Piece, minimum stock: 5). Confirm it appears with a "Low"
   badge (current stock is 0, below the 5 minimum).
5. **Stock in** — Open "Widget". Record a stock movement: type In, quantity
   20. Confirm current stock shows 20 and the Low badge clears.
6. **Stock out** — Record another movement: type Out, quantity 25. Confirm
   current stock shows -5 (negative stock is permitted in this slice).
7. **Stock history** — View stock history for "Widget". Confirm three entries
   appear, newest first: Out 25, In 20, and the initial state.
8. **Global stock tab** — Navigate to the Stock tab. Confirm the same
   movements are visible globally.
9. **Theme persistence** — Open Settings and switch to Dark theme. Confirm
   the UI updates immediately. Relaunch the app and confirm the dark theme
   persists.
