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

## Known Limitations (Slice 1)

These are deliberate gaps deferred to a later slice, not unintentional omissions.

**No DB-level foreign-key enforcement.** FK columns (e.g. `category_id`,
`unit_id`) are plain text columns and `PRAGMA foreign_keys` is deliberately
left off. Referential integrity is maintained by application logic: rows are
only ever soft-deleted (`is_active = false`, never hard-deleted), and the stock
ledger's `record()` method checks product existence and rolls back the
transaction if the product is missing. Enabling DB-level FK enforcement is
deferred to a later slice because doing so now would require reworking test
fixtures that intentionally use standalone rows.

**Unit conversion not yet surfaced in UI.** `UnitService.convert` and the
by-type/base-unit lookup methods are fully implemented and covered by unit
tests, but no screen or widget consumes them yet. The conversion logic is ready
for when a future slice adds a conversion UI.

**Dedicated low-stock / out-of-stock list views are deferred.** The
low-stock-alert requirement is satisfied today via a per-row "Low" badge on the
product list. The `lowStock` and `outOfStock` queries are wired end-to-end and
tested; a dedicated filtered list view that uses them is deferred to a future
slice.
