# Sales Shipments Ledger Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an org-wide, infinite-scroll sales shipments ledger screen reachable from the sales dashboard, with Date + Status filters and search by SO number.

**Architecture:** Mirror the just-shipped sales **payments** ledger stack layer-for-layer (DAO → repository → service → Riverpod paged notifier → `PaginatedListView` screen), reusing `PagedListNotifier`, `PagedState`, `PaginatedListView`, and the shared `FilterPill<T>` widget unchanged. A new DAO join query returns each shipment plus its order's `soNumber`/`customerId`; a new freezed read-model `SaleShipmentListItem` carries them to the UI.

**Tech Stack:** Flutter, Riverpod (Notifier API), Drift (SQLite), freezed, Flutter gen-l10n (ARB), flutter_test.

## Global Constraints

- Spec: [docs/superpowers/specs/2026-07-06-sales-shipments-ledger-design.md](../specs/2026-07-06-sales-shipments-ledger-design.md).
- All new code lives under `lib/features/sales/sale_order/`.
- Page size is the existing constant `SaleOrderService.pageSize` (20). Do not introduce a second page-size constant.
- Date range contract: `from` INCLUSIVE lower bound, `to` EXCLUSIVE upper bound — filter on `shippingDate`. Use `isBiggerOrEqualValue(from)` / `isSmallerThanValue(to)`.
- The `SaleOrderShippings` table has NO `isActive` column. The query filters the **order's** active flag: `saleOrders.isActive.equals(true)`. Do NOT filter `isSample` (sample shipments appear, like sample orders/payments).
- Search matches `saleOrders.soNumber` only, case-insensitive `LIKE %q%`.
- Ordering: `shippingDate DESC`, then `createdAt DESC` tiebreaker.
- `ShipmentStatus` wire values: `shipped, in_transit, delivered, returned` (enum values `shipped, inTransit, delivered, returned`).
- Two locales — every new UI string MUST be added to BOTH `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`.
- Codegen: `flutter pub run build_runner build --delete-conflicting-outputs` (plain `dart run` fails version solving in this project). l10n regen: `flutter gen-l10n`. Tests: `flutter test <path>`.
- Drift returns local-time `DateTime`s on read-back; when a test compares a read-back date to a `DateTime.utc(...)` literal, call `.toUtc()` on the read value (precedent: `sale_order_dao_test.dart:149`).
- The shared `FilterPill<T>` widget already exists at `lib/core/widgets/filter_pill.dart` (extracted during the payments feature) — reuse it, do not redefine.

---

### Task 1: DAO — `pagedShipments` join query

**Files:**
- Modify: `lib/features/sales/sale_order/data/sale_order_shipping_dao.dart`
- Test: `test/features/sales/sale_order/sale_order_shipping_dao_test.dart`

**Interfaces:**
- Consumes: existing `SaleOrderShippings` + `SaleOrders` Drift tables (both already on `@DriftAccessor`, so no `.g.dart` regeneration).
- Produces: `Future<List<({SaleOrderShippingRow shipment, String soNumber, String customerId})>> pagedShipments(String orgId, {String? status, DateTime? from, DateTime? to, String? search, required int limit, required int offset})` on `SaleOrderShippingDao`.

- [ ] **Step 1: Write the failing tests**

Append to the existing test file's `main()` (after the last test, before the closing `}`). These insert shipping rows directly (bypassing the stock machinery) and seed a second order + a soft-deleted order:

```dart
  test('pagedShipments returns shipments across orders, newest first, with order context',
      () async {
    // second, live order
    await db.into(db.saleOrders).insert(SaleOrdersCompanion.insert(
          id: 'so2', organizationId: 'org1', soNumber: 'SO-0002',
          customerId: 'c2', orderDate: now, status: const Value('processing'),
          createdAt: now, updatedAt: now,
        ));
    await db.into(db.saleOrderShippings).insert(SaleOrderShippingsCompanion.insert(
          id: 's_old', organizationId: 'org1', saleOrderId: 'so1',
          soShippingNumber: 'SHP-0001', shippingDate: DateTime.utc(2026, 6, 1),
          status: const Value('shipped'), createdAt: now, updatedAt: now,
        ));
    await db.into(db.saleOrderShippings).insert(SaleOrderShippingsCompanion.insert(
          id: 's_new', organizationId: 'org1', saleOrderId: 'so2',
          soShippingNumber: 'SHP-0002', shippingDate: DateTime.utc(2026, 6, 5),
          status: const Value('delivered'), createdAt: now, updatedAt: now,
        ));

    final rows = await db.saleOrderShippingDao
        .pagedShipments('org1', limit: 20, offset: 0);

    expect(rows.length, 2);
    expect(rows.first.shipment.id, 's_new'); // newest shippingDate first
    expect(rows.first.soNumber, 'SO-0002');
    expect(rows.first.customerId, 'c2');
    expect(rows.last.shipment.id, 's_old');
    expect(rows.last.soNumber, 'SO-0001');
  });

  test('pagedShipments excludes shipments of soft-deleted orders', () async {
    await db.into(db.saleOrderShippings).insert(SaleOrderShippingsCompanion.insert(
          id: 's1', organizationId: 'org1', saleOrderId: 'so1',
          soShippingNumber: 'SHP-0001', shippingDate: now,
          createdAt: now, updatedAt: now,
        ));
    // soft-delete the order
    await db.saleOrderDao.softDelete('so1', now);

    final rows = await db.saleOrderShippingDao
        .pagedShipments('org1', limit: 20, offset: 0);

    expect(rows, isEmpty);
  });

  test('pagedShipments filters by status, search, and date range', () async {
    await db.into(db.saleOrderShippings).insert(SaleOrderShippingsCompanion.insert(
          id: 's1', organizationId: 'org1', saleOrderId: 'so1',
          soShippingNumber: 'SHP-0001', shippingDate: DateTime.utc(2026, 6, 2),
          status: const Value('shipped'), createdAt: now, updatedAt: now,
        ));
    await db.into(db.saleOrderShippings).insert(SaleOrderShippingsCompanion.insert(
          id: 's2', organizationId: 'org1', saleOrderId: 'so1',
          soShippingNumber: 'SHP-0002', shippingDate: DateTime.utc(2026, 6, 4),
          status: const Value('delivered'), createdAt: now, updatedAt: now,
        ));

    expect(
        (await db.saleOrderShippingDao.pagedShipments('org1',
                status: 'shipped', limit: 20, offset: 0))
            .map((r) => r.shipment.id),
        ['s1']);
    expect(
        (await db.saleOrderShippingDao.pagedShipments('org1',
                search: 'SO-0001', limit: 20, offset: 0))
            .length,
        2);
    expect(
        (await db.saleOrderShippingDao.pagedShipments('org1',
                search: 'SO-9999', limit: 20, offset: 0))
            .length,
        0);
    // to is EXCLUSIVE: window [6-01, 6-04) excludes the 6-04 shipment.
    expect(
        (await db.saleOrderShippingDao.pagedShipments('org1',
                from: DateTime.utc(2026, 6, 1),
                to: DateTime.utc(2026, 6, 4),
                limit: 20, offset: 0))
            .map((r) => r.shipment.id),
        ['s1']);
  });

  test('pagedShipments applies limit and offset', () async {
    for (var i = 1; i <= 3; i++) {
      await db.into(db.saleOrderShippings).insert(SaleOrderShippingsCompanion.insert(
            id: 's$i', organizationId: 'org1', saleOrderId: 'so1',
            soShippingNumber: 'SHP-000$i', shippingDate: DateTime.utc(2026, 6, i),
            createdAt: now, updatedAt: now,
          ));
    }
    final page0 = await db.saleOrderShippingDao
        .pagedShipments('org1', limit: 2, offset: 0);
    final page1 = await db.saleOrderShippingDao
        .pagedShipments('org1', limit: 2, offset: 2);
    expect(page0.length, 2);
    expect(page1.length, 1);
    expect(page0.first.shipment.shippingDate.toUtc(), DateTime.utc(2026, 6, 3));
    expect(page1.single.shipment.shippingDate.toUtc(), DateTime.utc(2026, 6, 1));
  });
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/features/sales/sale_order/sale_order_shipping_dao_test.dart`
Expected: FAIL — `The method 'pagedShipments' isn't defined for the type 'SaleOrderShippingDao'`.

- [ ] **Step 3: Write minimal implementation**

Add this method to `SaleOrderShippingDao` (e.g. after `shipmentsFor`). `saleOrders` is already in scope via `@DriftAccessor`:

```dart
  /// Org-wide ledger of shipments joined to their order for SO number and
  /// customer id. Newest `shippingDate` first. `to` is EXCLUSIVE. Shipments of
  /// soft-deleted orders are excluded via the order's `isActive` flag.
  Future<List<({SaleOrderShippingRow shipment, String soNumber, String customerId})>>
      pagedShipments(
    String orgId, {
    String? status,
    DateTime? from,
    DateTime? to,
    String? search,
    required int limit,
    required int offset,
  }) async {
    final q = select(saleOrderShippings).join([
      innerJoin(
          saleOrders, saleOrders.id.equalsExp(saleOrderShippings.saleOrderId)),
    ]);
    q.where(saleOrderShippings.organizationId.equals(orgId) &
        saleOrders.isActive.equals(true));
    if (status != null) q.where(saleOrderShippings.status.equals(status));
    if (from != null) {
      q.where(saleOrderShippings.shippingDate.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      q.where(saleOrderShippings.shippingDate.isSmallerThanValue(to));
    }
    if (search != null && search.trim().isNotEmpty) {
      q.where(saleOrders.soNumber.like('%${search.trim()}%'));
    }
    q.orderBy([
      OrderingTerm(
          expression: saleOrderShippings.shippingDate, mode: OrderingMode.desc),
      OrderingTerm(
          expression: saleOrderShippings.createdAt, mode: OrderingMode.desc),
    ]);
    q.limit(limit, offset: offset);
    final rows = await q.get();
    return [
      for (final r in rows)
        (
          shipment: r.readTable(saleOrderShippings),
          soNumber: r.read(saleOrders.soNumber)!,
          customerId: r.read(saleOrders.customerId)!,
        ),
    ];
  }
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/features/sales/sale_order/sale_order_shipping_dao_test.dart`
Expected: PASS (existing + 4 new).

- [ ] **Step 5: Commit**

```bash
git add lib/features/sales/sale_order/data/sale_order_shipping_dao.dart test/features/sales/sale_order/sale_order_shipping_dao_test.dart
git commit -m "feat(sales): add pagedShipments DAO query for shipments ledger"
```

---

### Task 2: Domain read-model `SaleShipmentListItem` + mapper

**Files:**
- Modify: `lib/features/sales/sale_order/domain/sale_order.dart`
- Modify: `lib/features/sales/sale_order/data/sale_order_mappers.dart`
- Regenerate: `lib/features/sales/sale_order/domain/sale_order.freezed.dart` (via build_runner)
- Test: `test/features/sales/sale_order/sale_order_mapper_test.dart`

**Interfaces:**
- Consumes: `SaleOrderShippingRow` (Drift) and the record type from Task 1.
- Produces:
  - freezed class `SaleShipmentListItem` with fields: `id, organizationId, saleOrderId, soShippingNumber, shippingDate, carrier (String?), trackingNumber (String?), status (ShipmentStatus), createdAt, updatedAt, soNumber, customerId`.
  - `SaleShipmentListItem toSaleShipmentListItem(SaleOrderShippingRow r, {required String soNumber, required String customerId})` in `sale_order_mappers.dart`.

- [ ] **Step 1: Write the failing test**

Append to `test/features/sales/sale_order/sale_order_mapper_test.dart` inside `main()`:

```dart
  test('toSaleShipmentListItem carries shipment fields plus order context', () {
    final row = SaleOrderShippingRow(
      id: 's1',
      organizationId: 'org1',
      saleOrderId: 'so1',
      soShippingNumber: 'SHP-0001',
      shippingDate: DateTime.utc(2026, 6, 2),
      carrier: 'DHL',
      trackingNumber: '1Z999',
      status: 'delivered',
      isSample: false,
      createdAt: DateTime.utc(2026, 6, 2),
      updatedAt: DateTime.utc(2026, 6, 2),
    );

    final item =
        toSaleShipmentListItem(row, soNumber: 'SO-0001', customerId: 'c1');

    expect(item.id, 's1');
    expect(item.soShippingNumber, 'SHP-0001');
    expect(item.carrier, 'DHL');
    expect(item.trackingNumber, '1Z999');
    expect(item.status, ShipmentStatus.delivered);
    expect(item.soNumber, 'SO-0001');
    expect(item.customerId, 'c1');
  });
```

Ensure the test file imports include `sale_order_enums.dart` and `app_database.dart` (they were added in the payments feature's mapper test; add if missing).

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/sales/sale_order/sale_order_mapper_test.dart`
Expected: FAIL — `The function 'toSaleShipmentListItem' isn't defined` (and `SaleShipmentListItem` undefined).

- [ ] **Step 3: Write the model + mapper, then regenerate**

In `lib/features/sales/sale_order/domain/sale_order.dart`, append after the last freezed class (the file already has `part 'sale_order.freezed.dart';` and imports `sale_order_enums.dart`):

```dart
@freezed
abstract class SaleShipmentListItem with _$SaleShipmentListItem {
  const factory SaleShipmentListItem({
    required String id,
    required String organizationId,
    required String saleOrderId,
    required String soShippingNumber,
    required DateTime shippingDate,
    String? carrier,
    String? trackingNumber,
    required ShipmentStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String soNumber,
    required String customerId,
  }) = _SaleShipmentListItem;
}
```

In `lib/features/sales/sale_order/data/sale_order_mappers.dart`, append after `toSaleOrderShipping`:

```dart
SaleShipmentListItem toSaleShipmentListItem(
  SaleOrderShippingRow r, {
  required String soNumber,
  required String customerId,
}) =>
    SaleShipmentListItem(
      id: r.id,
      organizationId: r.organizationId,
      saleOrderId: r.saleOrderId,
      soShippingNumber: r.soShippingNumber,
      shippingDate: r.shippingDate,
      carrier: r.carrier,
      trackingNumber: r.trackingNumber,
      status: ShipmentStatus.fromWire(r.status),
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
      soNumber: soNumber,
      customerId: customerId,
    );
```

Then regenerate freezed:

Run: `flutter pub run build_runner build --delete-conflicting-outputs`

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/sales/sale_order/sale_order_mapper_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/sales/sale_order/domain/sale_order.dart lib/features/sales/sale_order/domain/sale_order.freezed.dart lib/features/sales/sale_order/data/sale_order_mappers.dart test/features/sales/sale_order/sale_order_mapper_test.dart
git commit -m "feat(sales): add SaleShipmentListItem read-model and mapper"
```

---

### Task 3: Repository — `pagedShipments`

**Files:**
- Modify: `lib/features/sales/sale_order/domain/sale_order_repository.dart`
- Modify: `lib/features/sales/sale_order/data/sale_order_repository_impl.dart`
- Test: `test/features/sales/sale_order/sale_order_repository_test.dart`

**Interfaces:**
- Consumes: `SaleOrderShippingDao.pagedShipments` (Task 1), `toSaleShipmentListItem` (Task 2). The impl has a `_shipping` field (the `SaleOrderShippingDao`) and already imports the mappers.
- Produces: `Future<List<SaleShipmentListItem>> pagedShipments(String orgId, {ShipmentStatus? status, DateTime? from, DateTime? to, String? search, required int limit, required int offset})` on `SaleOrderRepository` (interface + impl).

- [ ] **Step 1: Write the failing test**

Append to `test/features/sales/sale_order/sale_order_repository_test.dart` inside `main()`. Reuse the file's existing `SaleOrderRepositoryImpl` construction pattern (positional args `SaleOrderDao, SaleOrderPaymentDao, SaleOrderShippingDao, DocumentCounterDao`):

```dart
  test('pagedShipments maps DAO rows to SaleShipmentListItem with order context',
      () async {
    final db = newTestDb();
    addTearDown(db.close);
    final repo = SaleOrderRepositoryImpl(
      SaleOrderDao(db),
      SaleOrderPaymentDao(db),
      SaleOrderShippingDao(db),
      DocumentCounterDao(db),
    );
    final now = DateTime.utc(2026, 6, 2);
    await db.into(db.saleOrders).insert(SaleOrdersCompanion.insert(
          id: 'so1', organizationId: 'org1', soNumber: 'SO-0001',
          customerId: 'c1', orderDate: now, createdAt: now, updatedAt: now,
        ));
    await db.into(db.saleOrderShippings).insert(SaleOrderShippingsCompanion.insert(
          id: 's1', organizationId: 'org1', saleOrderId: 'so1',
          soShippingNumber: 'SHP-0001', shippingDate: now,
          carrier: const Value('DHL'), status: const Value('shipped'),
          createdAt: now, updatedAt: now,
        ));

    final items = await repo.pagedShipments('org1', limit: 20, offset: 0);

    expect(items.length, 1);
    expect(items.single, isA<SaleShipmentListItem>());
    expect(items.single.soNumber, 'SO-0001');
    expect(items.single.customerId, 'c1');
    expect(items.single.status, ShipmentStatus.shipped);
    expect(items.single.carrier, 'DHL');
  });
```

Ensure the test file's imports include `sale_order_shipping_dao.dart`, `sale_order.dart`, `sale_order_enums.dart`, and `package:drift/drift.dart` show `Value` (add any missing).

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/sales/sale_order/sale_order_repository_test.dart`
Expected: FAIL — `The method 'pagedShipments' isn't defined for the type 'SaleOrderRepositoryImpl'`.

- [ ] **Step 3: Write minimal implementation**

In `sale_order_repository.dart`, add to the interface (near the other shipment methods `shipmentsFor` / `setShipmentStatus`):

```dart
  Future<List<SaleShipmentListItem>> pagedShipments(String orgId,
      {ShipmentStatus? status,
      DateTime? from,
      DateTime? to,
      String? search,
      required int limit,
      required int offset});
```

In `sale_order_repository_impl.dart`, add (after `shipmentsFor`, using `_shipping`, with `@override`):

```dart
  @override
  Future<List<SaleShipmentListItem>> pagedShipments(String orgId,
          {ShipmentStatus? status,
          DateTime? from,
          DateTime? to,
          String? search,
          required int limit,
          required int offset}) async =>
      (await _shipping.pagedShipments(orgId,
              status: status?.wire,
              from: from,
              to: to,
              search: search,
              limit: limit,
              offset: offset))
          .map((r) => toSaleShipmentListItem(r.shipment,
              soNumber: r.soNumber, customerId: r.customerId))
          .toList();
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/sales/sale_order/sale_order_repository_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/sales/sale_order/domain/sale_order_repository.dart lib/features/sales/sale_order/data/sale_order_repository_impl.dart test/features/sales/sale_order/sale_order_repository_test.dart
git commit -m "feat(sales): add pagedShipments to sale order repository"
```

---

### Task 4: Service — `listShipments`

**Files:**
- Modify: `lib/features/sales/sale_order/domain/sale_order_usecases.dart`
- Test: `test/features/sales/sale_order/sale_order_shipments_test.dart`

**Interfaces:**
- Consumes: `SaleOrderRepository.pagedShipments` (Task 3), `SaleOrderService.pageSize` (20), `_orgId`, `_repo`.
- Produces: `Future<List<SaleShipmentListItem>> listShipments({int page = 0, ShipmentStatus? status, DateTime? from, DateTime? to, String search = ''})` on `SaleOrderService`.

- [ ] **Step 1: Write the failing test**

Append to `test/features/sales/sale_order/sale_order_shipments_test.dart` inside `main()`. Reuse the file's existing service/DB setup if present; otherwise this standalone body works (mirror the seed style already in the file — build a `SaleOrderService` the same way `saleOrderServiceProvider` does):

```dart
  test('listShipments returns page 0 newest-first and honors page offset',
      () async {
    final db = newTestDb();
    addTearDown(db.close);
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final service = SaleOrderService(
      repository: SaleOrderRepositoryImpl(
        SaleOrderDao(db),
        SaleOrderPaymentDao(db),
        SaleOrderShippingDao(db),
        DocumentCounterDao(db),
      ),
      ids: const IdGenerator(),
      organizationId: session.organizationId,
      userId: session.userId,
    );
    final now = DateTime.utc(2026, 6, 1);
    await db.into(db.saleOrders).insert(SaleOrdersCompanion.insert(
          id: 'so1', organizationId: session.organizationId,
          soNumber: 'SO-0001', customerId: 'c1', orderDate: now,
          createdAt: now, updatedAt: now,
        ));
    for (var i = 1; i <= 25; i++) {
      await db.into(db.saleOrderShippings).insert(SaleOrderShippingsCompanion.insert(
            id: 's$i', organizationId: session.organizationId, saleOrderId: 'so1',
            soShippingNumber: 'SHP-${i.toString().padLeft(4, '0')}',
            shippingDate: DateTime.utc(2026, 6, i),
            createdAt: now, updatedAt: now,
          ));
    }

    final page0 = await service.listShipments(page: 0);
    final page1 = await service.listShipments(page: 1);
    expect(page0.length, 20); // pageSize
    expect(page1.length, 5);
    expect(page0.first.soShippingNumber, 'SHP-0025'); // newest shippingDate
  });
```

Ensure imports include: `package:drift/drift.dart` show `Value`; `core/db/app_database.dart`; `core/id/id_generator.dart`; `core/seed/seed_service.dart`; the four DAO files; `data/sale_order_repository_impl.dart`; `domain/sale_order_usecases.dart`; `../../../helpers/test_db.dart`.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/sales/sale_order/sale_order_shipments_test.dart`
Expected: FAIL — `The method 'listShipments' isn't defined for the type 'SaleOrderService'`.

- [ ] **Step 3: Write minimal implementation**

In `sale_order_usecases.dart`, add to `SaleOrderService` near the existing `shipments(...)` method:

```dart
  Future<List<SaleShipmentListItem>> listShipments({
    int page = 0,
    ShipmentStatus? status,
    DateTime? from,
    DateTime? to,
    String search = '',
  }) =>
      _repo.pagedShipments(_orgId,
          status: status,
          from: from,
          to: to,
          search: search,
          limit: pageSize,
          offset: page * pageSize);
```

`SaleShipmentListItem` is visible via the existing `sale_order.dart` import; no new import needed.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/sales/sale_order/sale_order_shipments_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/sales/sale_order/domain/sale_order_usecases.dart test/features/sales/sale_order/sale_order_shipments_test.dart
git commit -m "feat(sales): add listShipments to SaleOrderService"
```

---

### Task 5: Localization keys

**Files:**
- Modify: `lib/l10n/app_en.arb`
- Modify: `lib/l10n/app_ar.arb`
- Regenerate: `lib/l10n/app_localizations*.dart` (via `flutter gen-l10n`)

**Interfaces:**
- Produces (new `AppLocalizations` getters, consumed by Tasks 6–8):
  `shipLedgerTitle, shipLedgerEmpty, shipFilterStatusLabel, shipStatusAny, shipStatusShipped, shipStatusInTransit, shipStatusDelivered, shipStatusReturned`.
- Reuses existing keys: `soSearchHint`, `soDateAll/soDateToday/soDateWeek/soDateMonth`, `soFilterDateLabel`, `soClearAll`, `soClearAllFiltersTooltip`, `soUnknownCustomer`, `soLoadingCustomer`.

- [ ] **Step 1: Add keys to `app_en.arb`**

Insert before the closing `}` (add a trailing comma to the currently-last entry if needed):

```json
  "shipLedgerTitle": "Shipments",
  "shipLedgerEmpty": "No shipments yet.",
  "shipFilterStatusLabel": "Status",
  "shipStatusAny": "Any status",
  "shipStatusShipped": "Shipped",
  "shipStatusInTransit": "In transit",
  "shipStatusDelivered": "Delivered",
  "shipStatusReturned": "Returned"
```

- [ ] **Step 2: Add the same keys to `app_ar.arb`**

Insert before the closing `}` (add a trailing comma to the currently-last entry if needed):

```json
  "shipLedgerTitle": "الشحنات",
  "shipLedgerEmpty": "لا توجد شحنات بعد.",
  "shipFilterStatusLabel": "الحالة",
  "shipStatusAny": "أي حالة",
  "shipStatusShipped": "تم الشحن",
  "shipStatusInTransit": "قيد النقل",
  "shipStatusDelivered": "تم التسليم",
  "shipStatusReturned": "مُرتجع"
```

- [ ] **Step 3: Regenerate localizations**

Run: `flutter gen-l10n`
Expected: no errors; `AppLocalizations` now exposes the new getters.

- [ ] **Step 4: Verify generation compiles**

Run: `flutter analyze lib/l10n`
Expected: No new issues.

- [ ] **Step 5: Commit**

```bash
git add lib/l10n/app_en.arb lib/l10n/app_ar.arb lib/l10n/app_localizations*.dart
git commit -m "feat(sales): add l10n keys for shipments ledger"
```

---

### Task 6: Providers — criteria, paged notifier, label helper

**Files:**
- Create: `lib/features/sales/sale_order/presentation/sale_shipment_providers.dart`
- Test: `test/features/sales/sale_order/sale_shipment_list_provider_test.dart`

**Interfaces:**
- Consumes: `saleOrderServiceProvider` + `DatePreset` (from `sale_order_providers.dart`), `SaleOrderService.listShipments`/`pageSize` (Task 4), `PagedListNotifier`/`PagedState`, l10n getters (Task 5).
- Produces:
  - `SaleShipmentListCriteria` (immutable) with fields `search, status (ShipmentStatus?), datePreset (DatePreset)`, getters `from`, `to`, `hasActiveFilters`, and `copyWith`.
  - `saleShipmentCriteriaProvider` (NotifierProvider) with methods `setSearch, setStatus, setDatePreset, reset`.
  - `saleShipmentListProvider` (NotifierProvider<SaleShipmentListNotifier, PagedState<SaleShipmentListItem>>).
  - `String shipmentStatusLabel(AppLocalizations, ShipmentStatus)`.

- [ ] **Step 1: Write the failing test**

Create `test/features/sales/sale_order/sale_shipment_list_provider_test.dart`:

```dart
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order_enums.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/presentation/sale_shipment_providers.dart';
import '../../../helpers/test_db.dart';

void main() {
  test('shipment list loads and a status filter change reloads filtered',
      () async {
    final db = newTestDb();
    addTearDown(db.close);
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final c = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      sessionProvider.overrideWithValue(session),
    ]);
    addTearDown(c.dispose);

    final now = DateTime.utc(2026, 6, 1);
    await db.into(db.saleOrders).insert(SaleOrdersCompanion.insert(
          id: 'so1', organizationId: session.organizationId,
          soNumber: 'SO-0001', customerId: 'c1', orderDate: now,
          createdAt: now, updatedAt: now,
        ));
    await db.into(db.saleOrderShippings).insert(SaleOrderShippingsCompanion.insert(
          id: 's1', organizationId: session.organizationId, saleOrderId: 'so1',
          soShippingNumber: 'SHP-0001', shippingDate: now,
          status: const Value('shipped'), createdAt: now, updatedAt: now,
        ));
    await db.into(db.saleOrderShippings).insert(SaleOrderShippingsCompanion.insert(
          id: 's2', organizationId: session.organizationId, saleOrderId: 'so1',
          soShippingNumber: 'SHP-0002', shippingDate: now,
          status: const Value('delivered'), createdAt: now, updatedAt: now,
        ));

    c.read(saleShipmentListProvider); // trigger initial load
    await Future<void>.delayed(Duration.zero);
    expect(c.read(saleShipmentListProvider).items.length, 2);

    c.read(saleShipmentCriteriaProvider.notifier)
        .setStatus(ShipmentStatus.shipped);
    await Future<void>.delayed(Duration.zero);
    final s = c.read(saleShipmentListProvider);
    expect(s.error, isNull);
    expect(s.items.single.soShippingNumber, 'SHP-0001');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/sales/sale_order/sale_shipment_list_provider_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'sale_shipment_providers.dart'`.

- [ ] **Step 3: Write the providers file**

Create `lib/features/sales/sale_order/presentation/sale_shipment_providers.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/paging/paged_list_notifier.dart';
import '../../../../core/paging/paged_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../domain/sale_order.dart';
import '../domain/sale_order_enums.dart';
import '../domain/sale_order_usecases.dart';
import 'sale_order_providers.dart' show saleOrderServiceProvider, DatePreset;

class SaleShipmentListCriteria {
  const SaleShipmentListCriteria({
    this.search = '',
    this.status,
    this.datePreset = DatePreset.all,
  });

  final String search;
  final ShipmentStatus? status;
  final DatePreset datePreset;

  SaleShipmentListCriteria copyWith({
    String? search,
    ShipmentStatus? status,
    bool clearStatus = false,
    DatePreset? datePreset,
  }) =>
      SaleShipmentListCriteria(
        search: search ?? this.search,
        status: clearStatus ? null : (status ?? this.status),
        datePreset: datePreset ?? this.datePreset,
      );

  /// Inclusive lower bound for the preset, or null for "all". Mirrors
  /// SaleOrderListCriteria.from.
  DateTime? get from {
    final now = DateTime.now();
    switch (datePreset) {
      case DatePreset.all:
        return null;
      case DatePreset.today:
        return DateTime(now.year, now.month, now.day);
      case DatePreset.week:
        return DateTime(now.year, now.month, now.day - (now.weekday - 1));
      case DatePreset.month:
        return DateTime(now.year, now.month, 1);
    }
  }

  /// Exclusive upper bound for the preset, or null for "all". Mirrors
  /// SaleOrderListCriteria.to.
  DateTime? get to {
    final now = DateTime.now();
    final tomorrowStart = DateTime(now.year, now.month, now.day + 1);
    switch (datePreset) {
      case DatePreset.all:
        return null;
      case DatePreset.today:
      case DatePreset.week:
        return tomorrowStart;
      case DatePreset.month:
        return DateTime(now.year, now.month + 1, 1);
    }
  }

  bool get hasActiveFilters =>
      search.isNotEmpty || status != null || datePreset != DatePreset.all;
}

class SaleShipmentCriteria extends Notifier<SaleShipmentListCriteria> {
  @override
  SaleShipmentListCriteria build() => const SaleShipmentListCriteria();

  void setSearch(String v) => state = state.copyWith(search: v);
  void setStatus(ShipmentStatus? v) =>
      state = state.copyWith(status: v, clearStatus: v == null);
  void setDatePreset(DatePreset v) => state = state.copyWith(datePreset: v);
  void reset() => state = const SaleShipmentListCriteria();
}

final saleShipmentCriteriaProvider =
    NotifierProvider<SaleShipmentCriteria, SaleShipmentListCriteria>(
        SaleShipmentCriteria.new);

class SaleShipmentListNotifier extends PagedListNotifier<SaleShipmentListItem> {
  @override
  int get pageSize => SaleOrderService.pageSize;

  @override
  PagedState<SaleShipmentListItem> build() {
    ref.listen(saleShipmentCriteriaProvider, (_, __) => reload());
    return super.build();
  }

  @override
  Future<List<SaleShipmentListItem>> fetch(int page) {
    final c = ref.read(saleShipmentCriteriaProvider);
    return ref.read(saleOrderServiceProvider).listShipments(
          page: page,
          status: c.status,
          from: c.from,
          to: c.to,
          search: c.search,
        );
  }
}

final saleShipmentListProvider =
    NotifierProvider<SaleShipmentListNotifier, PagedState<SaleShipmentListItem>>(
        SaleShipmentListNotifier.new);

String shipmentStatusLabel(AppLocalizations l10n, ShipmentStatus s) =>
    switch (s) {
      ShipmentStatus.shipped => l10n.shipStatusShipped,
      ShipmentStatus.inTransit => l10n.shipStatusInTransit,
      ShipmentStatus.delivered => l10n.shipStatusDelivered,
      ShipmentStatus.returned => l10n.shipStatusReturned,
    };
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/sales/sale_order/sale_shipment_list_provider_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/sales/sale_order/presentation/sale_shipment_providers.dart test/features/sales/sale_order/sale_shipment_list_provider_test.dart
git commit -m "feat(sales): add shipment ledger providers and label helper"
```

---

### Task 7: Presentation — `SaleShipmentListScreen`

**Files:**
- Create: `lib/features/sales/sale_order/presentation/sale_shipment_list_screen.dart`
- Test: `test/features/sales/sale_order/sale_shipment_list_test.dart`

**Interfaces:**
- Consumes: `saleShipmentListProvider`, `saleShipmentCriteriaProvider`, `shipmentStatusLabel` (Task 6); `DatePreset` (from `sale_order_providers.dart`); `SaleOrderDetailScreen`; the shared `FilterPill` (`core/widgets/filter_pill.dart`); `customerProvider`, `PaginatedListView`, `SearchField`, `EmptyState`, `AppCard`, `context.l10n`.
- Produces: `class SaleShipmentListScreen extends ConsumerStatefulWidget` with a `const` constructor.

- [ ] **Step 1: Write the failing widget test**

Create `test/features/sales/sale_order/sale_shipment_list_test.dart`:

```dart
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/l10n/app_localizations.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/presentation/sale_shipment_list_screen.dart';
import '../../../helpers/test_db.dart';

void main() {
  testWidgets('renders a seeded shipment row', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = newTestDb();
    addTearDown(db.close);
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final now = DateTime.utc(2026, 6, 1);
    await db.into(db.saleOrders).insert(SaleOrdersCompanion.insert(
          id: 'so1', organizationId: session.organizationId,
          soNumber: 'SO-0001', customerId: 'c1', orderDate: now,
          createdAt: now, updatedAt: now,
        ));
    await db.into(db.saleOrderShippings).insert(SaleOrderShippingsCompanion.insert(
          id: 's1', organizationId: session.organizationId, saleOrderId: 'so1',
          soShippingNumber: 'SHP-0001', shippingDate: now,
          status: const Value('shipped'), createdAt: now, updatedAt: now,
        ));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sessionProvider.overrideWithValue(session),
        sharedPrefsProvider.overrideWithValue(
            await SharedPreferences.getInstance()),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SaleShipmentListScreen(),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('SHP-0001'), findsOneWidget);
  });
}
```

> Note: the `sharedPrefsProvider` override + `SharedPreferences.setMockInitialValues` are required because the row's money-independent build still initializes the app theme/currency chain in some widgets; this mirrors the payments-screen test (`sale_payment_list_test.dart`). If the provider name differs, match whatever `sale_payment_list_test.dart` uses.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/sales/sale_order/sale_shipment_list_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'sale_shipment_list_screen.dart'`.

- [ ] **Step 3: Write the screen**

Create `lib/features/sales/sale_order/presentation/sale_shipment_list_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/filter_pill.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../domain/sale_order.dart';
import '../domain/sale_order_enums.dart';
import '../../customer/presentation/customer_providers.dart';
import 'sale_order_detail_screen.dart';
import 'sale_order_providers.dart' show DatePreset;
import 'sale_shipment_providers.dart';

class SaleShipmentListScreen extends ConsumerStatefulWidget {
  const SaleShipmentListScreen({super.key});

  @override
  ConsumerState<SaleShipmentListScreen> createState() =>
      _SaleShipmentListScreenState();
}

class _SaleShipmentListScreenState
    extends ConsumerState<SaleShipmentListScreen> {
  bool _searching = false;

  SaleShipmentListNotifier get _notifier =>
      ref.read(saleShipmentListProvider.notifier);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(saleShipmentListProvider);
    final criteria = ref.watch(saleShipmentCriteriaProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? SearchField(
                initial: criteria.search,
                hint: l10n.soSearchHint,
                onChanged: (v) => ref
                    .read(saleShipmentCriteriaProvider.notifier)
                    .setSearch(v),
              )
            : Text(l10n.shipLedgerTitle),
        actions: [
          if (criteria.hasActiveFilters)
            IconButton(
              tooltip: l10n.soClearAllFiltersTooltip,
              icon: const Icon(Icons.filter_alt_off),
              onPressed: () {
                ref.read(saleShipmentCriteriaProvider.notifier).reset();
                if (_searching) setState(() => _searching = false);
              },
            ),
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => _searching = !_searching);
              if (!_searching) {
                ref.read(saleShipmentCriteriaProvider.notifier).setSearch('');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _Filters(criteria: criteria),
          const SizedBox(height: 8),
          Expanded(
            child: PaginatedListView<SaleShipmentListItem>(
              state: state,
              onLoadMore: _notifier.loadMore,
              onRefresh: _notifier.refresh,
              onRetryInitial: _notifier.loadInitial,
              empty: EmptyState(
                icon: Icons.local_shipping_outlined,
                title: l10n.shipLedgerEmpty,
              ),
              itemBuilder: (context, s) => AppCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                onTap: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          SaleOrderDetailScreen(orderId: s.saleOrderId)));
                  if (mounted) await _notifier.refresh();
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: scheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.local_shipping,
                          color: scheme.primary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                s.soShippingNumber,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurface,
                                ),
                              ),
                              _badge(context, shipmentStatusLabel(l10n, s.status),
                                  _statusColor(s.status)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                s.soNumber,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text('  •  ',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurfaceVariant)),
                              Expanded(
                                child: Consumer(
                                  builder: (context, ref, child) {
                                    final customerAsync =
                                        ref.watch(customerProvider(s.customerId));
                                    return customerAsync.when(
                                      data: (customer) => Text(
                                        customer?.name ?? l10n.soUnknownCustomer,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      loading: () => Text(
                                        l10n.soLoadingCustomer,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: scheme.onSurfaceVariant
                                              .withOpacity(0.6),
                                        ),
                                      ),
                                      error: (_, __) => Text(
                                        l10n.soUnknownCustomer,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: scheme.onSurfaceVariant
                                              .withOpacity(0.6),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat.yMMMd().format(s.shippingDate),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (_carrierLine(s) != null)
                                Flexible(
                                  child: Text(
                                    _carrierLine(s)!,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.end,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// "carrier • tracking", or whichever of the two is present, or null.
  String? _carrierLine(SaleShipmentListItem s) {
    final parts = <String>[
      if (s.carrier != null && s.carrier!.trim().isNotEmpty) s.carrier!.trim(),
      if (s.trackingNumber != null && s.trackingNumber!.trim().isNotEmpty)
        s.trackingNumber!.trim(),
    ];
    return parts.isEmpty ? null : parts.join(' • ');
  }

  Widget _badge(BuildContext context, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(6)),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      );

  Color _statusColor(ShipmentStatus s) => switch (s) {
        ShipmentStatus.shipped => Colors.blue.shade700,
        ShipmentStatus.inTransit => Colors.amber.shade700,
        ShipmentStatus.delivered => Colors.green.shade700,
        ShipmentStatus.returned => Colors.red.shade700,
      };
}

class _Filters extends ConsumerWidget {
  const _Filters({required this.criteria});
  final SaleShipmentListCriteria criteria;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final n = ref.read(saleShipmentCriteriaProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (criteria.hasActiveFilters)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ActionChip(
                avatar: Icon(Icons.filter_alt_off_rounded,
                    size: 14, color: scheme.error),
                label: Text(
                  l10n.soClearAll,
                  style: TextStyle(
                    color: scheme.error,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: scheme.error.withOpacity(0.08),
                side: BorderSide(color: scheme.error.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                onPressed: n.reset,
              ),
            ),
          FilterPill<DatePreset>(
            label: l10n.soFilterDateLabel,
            isActive: criteria.datePreset != DatePreset.all,
            displayValue: _datePresetLabel(l10n, criteria.datePreset),
            onChanged: n.setDatePreset,
            onClear: () => n.setDatePreset(DatePreset.all),
            items: [
              PopupMenuItem(
                  value: DatePreset.all, child: Text(l10n.soDateAllDates)),
              PopupMenuItem(
                  value: DatePreset.today, child: Text(l10n.soDateToday)),
              PopupMenuItem(
                  value: DatePreset.week, child: Text(l10n.soDateWeek)),
              PopupMenuItem(
                  value: DatePreset.month, child: Text(l10n.soDateMonth)),
            ],
          ),
          const SizedBox(width: 8),
          FilterPill<ShipmentStatus?>(
            label: l10n.shipFilterStatusLabel,
            isActive: criteria.status != null,
            displayValue: criteria.status != null
                ? shipmentStatusLabel(l10n, criteria.status!)
                : '',
            onChanged: n.setStatus,
            onClear: () => n.setStatus(null),
            items: [
              PopupMenuItem(value: null, child: Text(l10n.shipStatusAny)),
              for (final st in ShipmentStatus.values)
                PopupMenuItem(
                    value: st, child: Text(shipmentStatusLabel(l10n, st))),
            ],
          ),
        ],
      ),
    );
  }

  String _datePresetLabel(AppLocalizations l10n, DatePreset p) => switch (p) {
        DatePreset.all => l10n.soDateAll,
        DatePreset.today => l10n.soDateToday,
        DatePreset.week => l10n.soDateWeek,
        DatePreset.month => l10n.soDateMonth,
      };
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/features/sales/sale_order/sale_shipment_list_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/sales/sale_order/presentation/sale_shipment_list_screen.dart test/features/sales/sale_order/sale_shipment_list_test.dart
git commit -m "feat(sales): add sale shipments ledger screen"
```

---

### Task 8: Entry point — "All Shipments" tile on the sales dashboard

**Files:**
- Modify: `lib/features/sales/sale_order/presentation/sale_order_dashboard_screen.dart`

**Interfaces:**
- Consumes: `SaleShipmentListScreen` (Task 7), existing `AppCard`, `AppTokens`, `context.l10n`, `l10n.shipLedgerTitle`.
- Produces: a tappable "All Shipments" tile immediately AFTER the shipping-status distribution block (parallel to how `_buildAllPaymentsTile` follows the payment-status distribution).

- [ ] **Step 1: Add the import**

At the top of `sale_order_dashboard_screen.dart`, alongside `import 'sale_payment_list_screen.dart';`, add:

```dart
import 'sale_shipment_list_screen.dart';
```

- [ ] **Step 2: Insert the tile after the shipping-status distribution**

Find the shipping-status distribution block in the body column:

```dart
            // Shipping Status distribution
            allOrdersAsync.when(
              data: (orders) => _buildShippingStatusDistribution(context, ref, orders, l10n),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('Error loading shipping status distribution: $e'),
            ),
            const SizedBox(height: AppTokens.space16),
```

Change the trailing spacer to `space24` and insert the tile after it, so it reads:

```dart
            // Shipping Status distribution
            allOrdersAsync.when(
              data: (orders) => _buildShippingStatusDistribution(context, ref, orders, l10n),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('Error loading shipping status distribution: $e'),
            ),
            const SizedBox(height: AppTokens.space24),

            // All shipments ledger
            _buildAllShipmentsTile(context, ref),
            const SizedBox(height: AppTokens.space16),
```

- [ ] **Step 3: Add the tile builder method**

Add this method to the dashboard widget class (e.g. right after `_buildAllPaymentsTile`):

```dart
  Widget _buildAllShipmentsTile(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AppCard(
      padding: const EdgeInsets.all(AppTokens.space16),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const SaleShipmentListScreen())),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTokens.space12),
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.local_shipping_rounded,
                color: scheme.primary, size: 24),
          ),
          const SizedBox(width: AppTokens.space16),
          Expanded(
            child: Text(
              context.l10n.shipLedgerTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: scheme.onSurfaceVariant.withOpacity(0.5)),
        ],
      ),
    );
  }
```

- [ ] **Step 4: Verify it compiles and the dashboard test still passes**

Run: `flutter test test/features/sales/sale_order/sale_dashboard_test.dart`
Expected: PASS.
Then: `flutter analyze lib/features/sales/sale_order/presentation/sale_order_dashboard_screen.dart`
Expected: No new issues (info-level `withOpacity` deprecations matching existing style are acceptable).

- [ ] **Step 5: Commit**

```bash
git add lib/features/sales/sale_order/presentation/sale_order_dashboard_screen.dart
git commit -m "feat(sales): add All Shipments entry tile to sales dashboard"
```

---

### Task 9: Full-suite verification

**Files:** none (verification only).

- [ ] **Step 1: Run the sales feature tests**

Run: `flutter test test/features/sales/`
Expected: PASS (all).

- [ ] **Step 2: Analyze the touched code**

Run: `flutter analyze lib/features/sales/sale_order`
Expected: No new issues.

- [ ] **Step 3: Run the whole test suite**

Run: `flutter test`
Expected: PASS (no regressions).

- [ ] **Step 4: Commit any incidental fixes**

If Steps 1–3 surfaced fixable issues, fix them and commit:

```bash
git add -A
git commit -m "fix(sales): resolve shipments ledger analyze/test issues"
```

---

## Self-Review Notes

- **Spec coverage:** DAO query (Task 1), read-model + mapper (Task 2), repository (Task 3), service (Task 4), l10n (Task 5), providers (Task 6), screen with Date+Status + SO-number search + tap-to-order + carrier/tracking display (Task 7), dashboard entry (Task 8). Decisions honored: Date+Status filters only (no method analog); all `ShipmentStatus` values filterable (Task 7 loops `ShipmentStatus.values`); search = SO number only; order's `isActive` filter (Task 1, with a soft-deleted-order-excluded test); `shippingDate` ordering; no `isSample` filter; no summary total; reuse shared `FilterPill`.
- **Type consistency:** `pagedShipments` record type `({SaleOrderShippingRow shipment, String soNumber, String customerId})` is produced in Task 1 and consumed verbatim in Task 3. `SaleShipmentListItem` field set is identical across Tasks 2/6/7. `listShipments` signature matches between Task 4 (definition) and Task 6 (call). `shipmentStatusLabel` defined in Task 6, used in Task 7.
- **Open verification for the implementer:** confirm the `SaleOrderRepositoryImpl` positional constructor arg order (`SaleOrderDao, SaleOrderPaymentDao, SaleOrderShippingDao, DocumentCounterDao`) against the real signature; confirm `sharedPrefsProvider` name against `sale_payment_list_test.dart`. If `SaleOrderShippingRow`'s positional constructor differs (e.g. `isSample` ordering), adjust the Task 2 mapper test row construction to match the generated row class.
