# Sales Payments Ledger Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an org-wide, infinite-scroll sales payments ledger screen reachable from the sales dashboard, with Date / Method / Status filters and search by SO number.

**Architecture:** Mirror the existing sale-order paged-list stack layer-for-layer (DAO → repository → service → Riverpod paged notifier → `PaginatedListView` screen), reusing `PagedListNotifier`, `PagedState`, and `PaginatedListView` unchanged. A new DAO join query returns each payment plus its order's `soNumber`/`customerId`; a new freezed read-model `SalePaymentListItem` carries them to the UI.

**Tech Stack:** Flutter, Riverpod (Notifier API), Drift (SQLite), freezed, Flutter gen-l10n (ARB), flutter_test.

## Global Constraints

- Spec: [docs/superpowers/specs/2026-07-06-sales-payments-ledger-design.md](../specs/2026-07-06-sales-payments-ledger-design.md).
- All new code lives under `lib/features/sales/sale_order/`.
- Page size is the existing constant `SaleOrderService.pageSize` (20). Do not introduce a second page-size constant.
- Date range contract: `from` is an INCLUSIVE lower bound, `to` is an EXCLUSIVE upper bound — same as `SaleOrderDao.paged`. Filter on `paymentDate` (not `createdAt`).
- Only active payments: `isActive == true`. Soft-deleted payments are excluded.
- Payments against cancelled orders **are included** (raw ledger — no cancelled-order exclusion).
- Search matches `saleOrders.soNumber` only (case-insensitive `LIKE %q%`), consistent with `SaleOrderDao.paged`.
- Ordering: `paymentDate DESC`, then `createdAt DESC` as tiebreaker.
- Two locales exist — every new UI string MUST be added to BOTH `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`.
- `PaymentMethod` wire values: `cash, credit_card, bank_transfer, check, digital_wallet, other`. `PaymentRecordStatus` wire values: `pending, completed, failed, refunded`.
- Codegen command: `dart run build_runner build --delete-conflicting-outputs`. l10n regen: `flutter gen-l10n`. Tests: `flutter test <path>`.

---

### Task 1: DAO — `pagedPayments` join query

**Files:**
- Modify: `lib/features/sales/sale_order/data/sale_order_payment_dao.dart`
- Test: `test/features/sales/sale_order/sale_order_payment_dao_test.dart`

**Interfaces:**
- Consumes: existing `SaleOrderPayments` + `SaleOrders` Drift tables (both already declared on `@DriftAccessor(tables: [SaleOrderPayments, SaleOrders])`, so no `.g.dart` regeneration is needed for this task).
- Produces: `Future<List<({SaleOrderPaymentRow payment, String soNumber, String customerId})>> pagedPayments(String orgId, {String? method, String? status, DateTime? from, DateTime? to, String? search, required int limit, required int offset})` on `SaleOrderPaymentDao`.

- [ ] **Step 1: Write the failing test**

Add these tests to the existing test file's `main()` (keep the existing `seedOrder`/`pay` helpers; add a second order + a soft-deleted payment inline). Append after the last existing test, before the closing `}` of `main`:

```dart
  test('pagedPayments returns active payments across orders, newest first', () async {
    // A second order so the ledger spans more than one order.
    await db.into(db.saleOrders).insert(SaleOrdersCompanion.insert(
          id: 'so2',
          organizationId: 'org1',
          soNumber: 'SO-0002',
          customerId: 'c2',
          orderDate: now,
          totalAmount: const Value(200),
          createdAt: now,
          updatedAt: now,
        ));
    // paymentDate ordering: p_old (older) then p_new (newer).
    await db.saleOrderPaymentDao.recordPayment(
        pay('1', 40).copyWith(paymentDate: Value(DateTime.utc(2026, 6, 1))));
    await db.saleOrderPaymentDao.recordPayment(SaleOrderPaymentsCompanion.insert(
      id: '2',
      organizationId: 'org1',
      saleOrderId: 'so2',
      paymentNumber: 'PAY-0002',
      amount: 60,
      method: 'cash',
      status: const Value('completed'),
      paymentDate: DateTime.utc(2026, 6, 5),
      createdAt: now,
      updatedAt: now,
    ));

    final rows = await db.saleOrderPaymentDao
        .pagedPayments('org1', limit: 20, offset: 0);

    expect(rows.length, 2);
    // Newest paymentDate first.
    expect(rows.first.payment.id, '2');
    expect(rows.first.soNumber, 'SO-0002');
    expect(rows.first.customerId, 'c2');
    expect(rows.last.payment.id, '1');
    expect(rows.last.soNumber, 'SO-0001');
  });

  test('pagedPayments excludes soft-deleted payments', () async {
    await db.saleOrderPaymentDao.recordPayment(pay('1', 40));
    await db.saleOrderPaymentDao.recordPayment(pay('2', 60));
    await db.saleOrderPaymentDao.deletePayment('1', now);

    final rows = await db.saleOrderPaymentDao
        .pagedPayments('org1', limit: 20, offset: 0);

    expect(rows.map((r) => r.payment.id), ['2']);
  });

  test('pagedPayments filters by method, status, search, and date range', () async {
    await db.saleOrderPaymentDao.recordPayment(SaleOrderPaymentsCompanion.insert(
      id: '1', organizationId: 'org1', saleOrderId: 'so1',
      paymentNumber: 'PAY-0001', amount: 10, method: 'cash',
      status: const Value('completed'),
      paymentDate: DateTime.utc(2026, 6, 2), createdAt: now, updatedAt: now,
    ));
    await db.saleOrderPaymentDao.recordPayment(SaleOrderPaymentsCompanion.insert(
      id: '2', organizationId: 'org1', saleOrderId: 'so1',
      paymentNumber: 'PAY-0002', amount: 20, method: 'bank_transfer',
      status: const Value('pending'),
      paymentDate: DateTime.utc(2026, 6, 4), createdAt: now, updatedAt: now,
    ));

    expect(
        (await db.saleOrderPaymentDao.pagedPayments('org1',
                method: 'cash', limit: 20, offset: 0))
            .map((r) => r.payment.id),
        ['1']);
    expect(
        (await db.saleOrderPaymentDao.pagedPayments('org1',
                status: 'pending', limit: 20, offset: 0))
            .map((r) => r.payment.id),
        ['2']);
    expect(
        (await db.saleOrderPaymentDao.pagedPayments('org1',
                search: 'SO-0001', limit: 20, offset: 0))
            .length,
        2);
    expect(
        (await db.saleOrderPaymentDao.pagedPayments('org1',
                search: 'SO-9999', limit: 20, offset: 0))
            .length,
        0);
    // to is EXCLUSIVE: window [6-01, 6-04) excludes the 6-04 payment.
    expect(
        (await db.saleOrderPaymentDao.pagedPayments('org1',
                from: DateTime.utc(2026, 6, 1),
                to: DateTime.utc(2026, 6, 4),
                limit: 20, offset: 0))
            .map((r) => r.payment.id),
        ['1']);
  });

  test('pagedPayments applies limit and offset', () async {
    for (var i = 1; i <= 3; i++) {
      await db.saleOrderPaymentDao.recordPayment(
          pay('$i', 10).copyWith(paymentDate: Value(DateTime.utc(2026, 6, i))));
    }
    final page0 = await db.saleOrderPaymentDao
        .pagedPayments('org1', limit: 2, offset: 0);
    final page1 = await db.saleOrderPaymentDao
        .pagedPayments('org1', limit: 2, offset: 2);
    expect(page0.length, 2);
    expect(page1.length, 1);
    // Newest first: 6-03, 6-02 on page 0; 6-01 on page 1.
    expect(page0.first.payment.paymentDate, DateTime.utc(2026, 6, 3));
    expect(page1.single.payment.paymentDate, DateTime.utc(2026, 6, 1));
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/sales/sale_order/sale_order_payment_dao_test.dart`
Expected: FAIL — `The method 'pagedPayments' isn't defined for the type 'SaleOrderPaymentDao'`.

- [ ] **Step 3: Write minimal implementation**

Add this method to `SaleOrderPaymentDao` (e.g. just after `paymentsFor`). The `@DriftAccessor` already lists `SaleOrders`, so `saleOrders` is in scope:

```dart
  /// Org-wide ledger of active payments joined to their order for SO number
  /// and customer id. Newest `paymentDate` first. `to` is EXCLUSIVE. Payments
  /// on cancelled orders are intentionally included.
  Future<List<({SaleOrderPaymentRow payment, String soNumber, String customerId})>>
      pagedPayments(
    String orgId, {
    String? method,
    String? status,
    DateTime? from,
    DateTime? to,
    String? search,
    required int limit,
    required int offset,
  }) async {
    final q = select(saleOrderPayments).join([
      innerJoin(
          saleOrders, saleOrders.id.equalsExp(saleOrderPayments.saleOrderId)),
    ]);
    q.where(saleOrderPayments.organizationId.equals(orgId) &
        saleOrderPayments.isActive.equals(true));
    if (method != null) q.where(saleOrderPayments.method.equals(method));
    if (status != null) q.where(saleOrderPayments.status.equals(status));
    if (from != null) {
      q.where(saleOrderPayments.paymentDate.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      q.where(saleOrderPayments.paymentDate.isSmallerThanValue(to));
    }
    if (search != null && search.trim().isNotEmpty) {
      q.where(saleOrders.soNumber.like('%${search.trim()}%'));
    }
    q.orderBy([
      OrderingTerm(
          expression: saleOrderPayments.paymentDate, mode: OrderingMode.desc),
      OrderingTerm(
          expression: saleOrderPayments.createdAt, mode: OrderingMode.desc),
    ]);
    q.limit(limit, offset: offset);
    final rows = await q.get();
    return [
      for (final r in rows)
        (
          payment: r.readTable(saleOrderPayments),
          soNumber: r.read(saleOrders.soNumber)!,
          customerId: r.read(saleOrders.customerId)!,
        ),
    ];
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/sales/sale_order/sale_order_payment_dao_test.dart`
Expected: PASS (all tests, including the four new ones).

- [ ] **Step 5: Commit**

```bash
git add lib/features/sales/sale_order/data/sale_order_payment_dao.dart test/features/sales/sale_order/sale_order_payment_dao_test.dart
git commit -m "feat(sales): add pagedPayments DAO query for payments ledger"
```

---

### Task 2: Domain read-model `SalePaymentListItem` + mapper

**Files:**
- Modify: `lib/features/sales/sale_order/domain/sale_order.dart`
- Modify: `lib/features/sales/sale_order/data/sale_order_mappers.dart`
- Regenerate: `lib/features/sales/sale_order/domain/sale_order.freezed.dart` (via build_runner)
- Test: `test/features/sales/sale_order/sale_order_mapper_test.dart`

**Interfaces:**
- Consumes: `SaleOrderPaymentRow` (Drift) and the record type from Task 1.
- Produces:
  - freezed class `SalePaymentListItem` with fields: `id, organizationId, saleOrderId, paymentNumber, amount, method (PaymentMethod), status (PaymentRecordStatus), paymentDate, isActive, createdAt, updatedAt, soNumber, customerId`.
  - `SalePaymentListItem toSalePaymentListItem(SaleOrderPaymentRow r, {required String soNumber, required String customerId})` in `sale_order_mappers.dart`.

- [ ] **Step 1: Write the failing test**

Append to `test/features/sales/sale_order/sale_order_mapper_test.dart` inside `main()`:

```dart
  test('toSalePaymentListItem carries payment fields plus order context', () {
    final row = SaleOrderPaymentRow(
      id: 'p1',
      organizationId: 'org1',
      saleOrderId: 'so1',
      paymentNumber: 'PAY-0001',
      amount: 42.5,
      method: 'bank_transfer',
      status: 'completed',
      paymentDate: DateTime.utc(2026, 6, 2),
      isActive: true,
      isSample: false,
      createdAt: DateTime.utc(2026, 6, 2),
      updatedAt: DateTime.utc(2026, 6, 2),
    );

    final item =
        toSalePaymentListItem(row, soNumber: 'SO-0001', customerId: 'c1');

    expect(item.id, 'p1');
    expect(item.amount, 42.5);
    expect(item.method, PaymentMethod.bankTransfer);
    expect(item.status, PaymentRecordStatus.completed);
    expect(item.soNumber, 'SO-0001');
    expect(item.customerId, 'c1');
  });
```

Ensure the test file imports (add if missing):
```dart
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order_enums.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_mappers.dart';
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/sales/sale_order/sale_order_mapper_test.dart`
Expected: FAIL — `The function 'toSalePaymentListItem' isn't defined` (and `SalePaymentListItem` undefined).

- [ ] **Step 3: Write the model + mapper, then regenerate**

In `lib/features/sales/sale_order/domain/sale_order.dart`, append after the `SaleOrderPayment` class (the file already has `part 'sale_order.freezed.dart';` and imports `sale_order_enums.dart`):

```dart
@freezed
abstract class SalePaymentListItem with _$SalePaymentListItem {
  const factory SalePaymentListItem({
    required String id,
    required String organizationId,
    required String saleOrderId,
    required String paymentNumber,
    required double amount,
    required PaymentMethod method,
    required PaymentRecordStatus status,
    required DateTime paymentDate,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String soNumber,
    required String customerId,
  }) = _SalePaymentListItem;
}
```

In `lib/features/sales/sale_order/data/sale_order_mappers.dart`, append after `toSaleOrderPayment`:

```dart
SalePaymentListItem toSalePaymentListItem(
  SaleOrderPaymentRow r, {
  required String soNumber,
  required String customerId,
}) =>
    SalePaymentListItem(
      id: r.id,
      organizationId: r.organizationId,
      saleOrderId: r.saleOrderId,
      paymentNumber: r.paymentNumber,
      amount: r.amount,
      method: PaymentMethod.fromWire(r.method),
      status: PaymentRecordStatus.fromWire(r.status),
      paymentDate: r.paymentDate,
      isActive: r.isActive,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
      soNumber: soNumber,
      customerId: customerId,
    );
```

Then regenerate freezed:

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/sales/sale_order/sale_order_mapper_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/sales/sale_order/domain/sale_order.dart lib/features/sales/sale_order/domain/sale_order.freezed.dart lib/features/sales/sale_order/data/sale_order_mappers.dart test/features/sales/sale_order/sale_order_mapper_test.dart
git commit -m "feat(sales): add SalePaymentListItem read-model and mapper"
```

---

### Task 3: Repository — `pagedPayments`

**Files:**
- Modify: `lib/features/sales/sale_order/domain/sale_order_repository.dart`
- Modify: `lib/features/sales/sale_order/data/sale_order_repository_impl.dart`
- Test: `test/features/sales/sale_order/sale_order_repository_test.dart`

**Interfaces:**
- Consumes: `SaleOrderPaymentDao.pagedPayments` (Task 1), `toSalePaymentListItem` (Task 2).
- Produces: `Future<List<SalePaymentListItem>> pagedPayments(String orgId, {PaymentMethod? method, PaymentRecordStatus? status, DateTime? from, DateTime? to, String? search, required int limit, required int offset})` on `SaleOrderRepository` (interface + impl).

- [ ] **Step 1: Write the failing test**

Append to `test/features/sales/sale_order/sale_order_repository_test.dart` inside `main()`. If the test file has no shared setup, this self-contained test works standalone (adjust the constructor call to match how the existing tests build `SaleOrderRepositoryImpl` — reuse their setup if present):

```dart
  test('pagedPayments maps DAO rows to SalePaymentListItem with order context',
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
          customerId: 'c1', orderDate: now, totalAmount: const Value(100),
          createdAt: now, updatedAt: now,
        ));
    await db.saleOrderPaymentDao.recordPayment(SaleOrderPaymentsCompanion.insert(
      id: 'p1', organizationId: 'org1', saleOrderId: 'so1',
      paymentNumber: 'PAY-0001', amount: 42, method: 'cash',
      status: const Value('completed'), paymentDate: now,
      createdAt: now, updatedAt: now,
    ));

    final items = await repo.pagedPayments('org1', limit: 20, offset: 0);

    expect(items.length, 1);
    expect(items.single, isA<SalePaymentListItem>());
    expect(items.single.soNumber, 'SO-0001');
    expect(items.single.customerId, 'c1');
    expect(items.single.method, PaymentMethod.cash);
  });
```

Ensure imports at the top of the test file include:
```dart
import 'package:drift/drift.dart' show Value;
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_payment_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_shipping_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/document_counter_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_repository_impl.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order_enums.dart';
import '../../../helpers/test_db.dart';
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/sales/sale_order/sale_order_repository_test.dart`
Expected: FAIL — `The method 'pagedPayments' isn't defined for the type 'SaleOrderRepositoryImpl'`.

- [ ] **Step 3: Write minimal implementation**

In `sale_order_repository.dart`, add to the interface (after `paymentsFor` on line ~45):

```dart
  Future<List<SalePaymentListItem>> pagedPayments(String orgId,
      {PaymentMethod? method,
      PaymentRecordStatus? status,
      DateTime? from,
      DateTime? to,
      String? search,
      required int limit,
      required int offset});
```

In `sale_order_repository_impl.dart`, add (after `paymentsFor`, using the impl's existing `_payments` field, and `@override`):

```dart
  @override
  Future<List<SalePaymentListItem>> pagedPayments(String orgId,
          {PaymentMethod? method,
          PaymentRecordStatus? status,
          DateTime? from,
          DateTime? to,
          String? search,
          required int limit,
          required int offset}) async =>
      (await _payments.pagedPayments(orgId,
              method: method?.wire,
              status: status?.wire,
              from: from,
              to: to,
              search: search,
              limit: limit,
              offset: offset))
          .map((r) => toSalePaymentListItem(r.payment,
              soNumber: r.soNumber, customerId: r.customerId))
          .toList();
```

If `toSalePaymentListItem` is not already imported in the impl, confirm the existing mapper import (`sale_order_mappers.dart`) is present — `toSaleOrderPayment` is already used there, so the import exists.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/sales/sale_order/sale_order_repository_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/sales/sale_order/domain/sale_order_repository.dart lib/features/sales/sale_order/data/sale_order_repository_impl.dart test/features/sales/sale_order/sale_order_repository_test.dart
git commit -m "feat(sales): add pagedPayments to sale order repository"
```

---

### Task 4: Service — `listPayments`

**Files:**
- Modify: `lib/features/sales/sale_order/domain/sale_order_usecases.dart`
- Test: `test/features/sales/sale_order/sale_order_payments_test.dart`

**Interfaces:**
- Consumes: `SaleOrderRepository.pagedPayments` (Task 3), `SaleOrderService.pageSize` (existing, 20), `_orgId` (existing private field).
- Produces: `Future<List<SalePaymentListItem>> listPayments({int page = 0, PaymentMethod? method, PaymentRecordStatus? status, DateTime? from, DateTime? to, String search = ''})` on `SaleOrderService`.

- [ ] **Step 1: Write the failing test**

Append to `test/features/sales/sale_order/sale_order_payments_test.dart` inside `main()`. Reuse that file's existing service/DB setup helpers if present; otherwise this standalone body works (mirror the seed style already in the file):

```dart
  test('listPayments returns page 0 newest-first and honors page offset',
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
          totalAmount: const Value(1000), createdAt: now, updatedAt: now,
        ));
    for (var i = 1; i <= 25; i++) {
      await db.saleOrderPaymentDao.recordPayment(
          SaleOrderPaymentsCompanion.insert(
        id: 'p$i', organizationId: session.organizationId, saleOrderId: 'so1',
        paymentNumber: 'PAY-${i.toString().padLeft(4, '0')}', amount: 1,
        method: 'cash', status: const Value('completed'),
        paymentDate: DateTime.utc(2026, 6, i), createdAt: now, updatedAt: now,
      ));
    }

    final page0 = await service.listPayments(page: 0);
    final page1 = await service.listPayments(page: 1);
    expect(page0.length, 20); // pageSize
    expect(page1.length, 5);
    // Newest paymentDate first: p25 (6-25) leads page 0.
    expect(page0.first.paymentNumber, 'PAY-0025');
  });
```

Ensure the file imports include (add any that are missing):
```dart
import 'package:drift/drift.dart' show Value;
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_payment_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_shipping_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/document_counter_dao.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/data/sale_order_repository_impl.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order_usecases.dart';
import '../../../helpers/test_db.dart';
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/sales/sale_order/sale_order_payments_test.dart`
Expected: FAIL — `The method 'listPayments' isn't defined for the type 'SaleOrderService'`.

- [ ] **Step 3: Write minimal implementation**

In `sale_order_usecases.dart`, add to `SaleOrderService` right after the existing `list(...)` method (it already exposes `pageSize` and `_orgId`, and `_repo`):

```dart
  Future<List<SalePaymentListItem>> listPayments({
    int page = 0,
    PaymentMethod? method,
    PaymentRecordStatus? status,
    DateTime? from,
    DateTime? to,
    String search = '',
  }) =>
      _repo.pagedPayments(_orgId,
          method: method,
          status: status,
          from: from,
          to: to,
          search: search,
          limit: pageSize,
          offset: page * pageSize);
```

Confirm `SalePaymentListItem` is visible — `sale_order_usecases.dart` already imports `sale_order.dart` (it references `SaleOrderPayment`), so no new import is needed.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/sales/sale_order/sale_order_payments_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/sales/sale_order/domain/sale_order_usecases.dart test/features/sales/sale_order/sale_order_payments_test.dart
git commit -m "feat(sales): add listPayments to SaleOrderService"
```

---

### Task 5: Localization keys

**Files:**
- Modify: `lib/l10n/app_en.arb`
- Modify: `lib/l10n/app_ar.arb`
- Regenerate: `lib/l10n/app_localizations*.dart` (via `flutter gen-l10n`)

**Interfaces:**
- Produces (new `AppLocalizations` getters, consumed by Tasks 6–8):
  `spLedgerTitle, spLedgerEmpty, spFilterMethodLabel, spFilterStatusLabel, spMethodAny, spStatusAny, spMethodCash, spMethodCreditCard, spMethodBankTransfer, spMethodCheck, spMethodDigitalWallet, spMethodOther, spStatusPending, spStatusCompleted, spStatusFailed, spStatusRefunded`.
- Reuses existing keys: `soSearchHint` (search hint), `soDateAll/soDateToday/soDateWeek/soDateMonth` and `soFilterDateLabel` (date pill).

- [ ] **Step 1: Add keys to `app_en.arb`**

Insert before the closing `}` (add a trailing comma to the currently-last entry if needed):

```json
  "spLedgerTitle": "Payments",
  "spLedgerEmpty": "No payments yet.",
  "spFilterMethodLabel": "Method",
  "spFilterStatusLabel": "Status",
  "spMethodAny": "Any method",
  "spStatusAny": "Any status",
  "spMethodCash": "Cash",
  "spMethodCreditCard": "Credit card",
  "spMethodBankTransfer": "Bank transfer",
  "spMethodCheck": "Check",
  "spMethodDigitalWallet": "Digital wallet",
  "spMethodOther": "Other",
  "spStatusPending": "Pending",
  "spStatusCompleted": "Completed",
  "spStatusFailed": "Failed",
  "spStatusRefunded": "Refunded"
```

- [ ] **Step 2: Add the same keys to `app_ar.arb`**

Insert before the closing `}` (add a trailing comma to the currently-last entry if needed):

```json
  "spLedgerTitle": "المدفوعات",
  "spLedgerEmpty": "لا توجد مدفوعات بعد.",
  "spFilterMethodLabel": "الطريقة",
  "spFilterStatusLabel": "الحالة",
  "spMethodAny": "أي طريقة",
  "spStatusAny": "أي حالة",
  "spMethodCash": "نقداً",
  "spMethodCreditCard": "بطاقة ائتمان",
  "spMethodBankTransfer": "تحويل بنكي",
  "spMethodCheck": "شيك",
  "spMethodDigitalWallet": "محفظة رقمية",
  "spMethodOther": "أخرى",
  "spStatusPending": "قيد الانتظار",
  "spStatusCompleted": "مكتمل",
  "spStatusFailed": "فشل",
  "spStatusRefunded": "مسترد"
```

- [ ] **Step 3: Regenerate localizations**

Run: `flutter gen-l10n`
Expected: no errors; `AppLocalizations` now exposes the new getters.

- [ ] **Step 4: Verify generation compiles**

Run: `flutter analyze lib/l10n`
Expected: No issues (or only pre-existing warnings unrelated to these keys).

- [ ] **Step 5: Commit**

```bash
git add lib/l10n/app_en.arb lib/l10n/app_ar.arb lib/l10n/app_localizations*.dart
git commit -m "feat(sales): add l10n keys for payments ledger"
```

---

### Task 6: Providers — criteria, paged notifier, label helpers

**Files:**
- Create: `lib/features/sales/sale_order/presentation/sale_payment_providers.dart`
- Test: `test/features/sales/sale_order/sale_payment_list_provider_test.dart`

**Interfaces:**
- Consumes: `saleOrderServiceProvider` + `DatePreset` (from `sale_order_providers.dart`), `SaleOrderService.listPayments`/`pageSize` (Task 4), `PagedListNotifier`/`PagedState` (existing), l10n getters (Task 5).
- Produces:
  - `SalePaymentListCriteria` (immutable) with fields `search, method (PaymentMethod?), status (PaymentRecordStatus?), datePreset (DatePreset)`, getters `from`, `to`, `hasActiveFilters`, and `copyWith`.
  - `salePaymentCriteriaProvider` (NotifierProvider) with methods `setSearch, setMethod, setStatus, setDatePreset, reset`.
  - `salePaymentListProvider` (NotifierProvider<SalePaymentListNotifier, PagedState<SalePaymentListItem>>).
  - `String paymentMethodLabel(AppLocalizations, PaymentMethod)` and `String paymentRecordStatusLabel(AppLocalizations, PaymentRecordStatus)`.

- [ ] **Step 1: Write the failing test**

Create `test/features/sales/sale_order/sale_payment_list_provider_test.dart`:

```dart
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/domain/sale_order_enums.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/presentation/sale_payment_providers.dart';
import '../../../helpers/test_db.dart';

void main() {
  test('payment list loads and a method filter change reloads filtered',
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
          totalAmount: const Value(100), createdAt: now, updatedAt: now,
        ));
    await db.saleOrderPaymentDao.recordPayment(SaleOrderPaymentsCompanion.insert(
      id: 'p1', organizationId: session.organizationId, saleOrderId: 'so1',
      paymentNumber: 'PAY-0001', amount: 10, method: 'cash',
      status: const Value('completed'), paymentDate: now,
      createdAt: now, updatedAt: now,
    ));
    await db.saleOrderPaymentDao.recordPayment(SaleOrderPaymentsCompanion.insert(
      id: 'p2', organizationId: session.organizationId, saleOrderId: 'so1',
      paymentNumber: 'PAY-0002', amount: 20, method: 'bank_transfer',
      status: const Value('completed'), paymentDate: now,
      createdAt: now, updatedAt: now,
    ));

    c.read(salePaymentListProvider); // trigger initial load
    await Future<void>.delayed(Duration.zero);
    expect(c.read(salePaymentListProvider).items.length, 2);

    c.read(salePaymentCriteriaProvider.notifier).setMethod(PaymentMethod.cash);
    await Future<void>.delayed(Duration.zero);
    final s = c.read(salePaymentListProvider);
    expect(s.error, isNull);
    expect(s.items.single.paymentNumber, 'PAY-0001');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/sales/sale_order/sale_payment_list_provider_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'sale_payment_providers.dart'`.

- [ ] **Step 3: Write the providers file**

Create `lib/features/sales/sale_order/presentation/sale_payment_providers.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/paging/paged_list_notifier.dart';
import '../../../../core/paging/paged_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../domain/sale_order.dart';
import '../domain/sale_order_enums.dart';
import '../domain/sale_order_usecases.dart';
import 'sale_order_providers.dart' show saleOrderServiceProvider, DatePreset;

class SalePaymentListCriteria {
  const SalePaymentListCriteria({
    this.search = '',
    this.method,
    this.status,
    this.datePreset = DatePreset.all,
  });

  final String search;
  final PaymentMethod? method;
  final PaymentRecordStatus? status;
  final DatePreset datePreset;

  SalePaymentListCriteria copyWith({
    String? search,
    PaymentMethod? method,
    bool clearMethod = false,
    PaymentRecordStatus? status,
    bool clearStatus = false,
    DatePreset? datePreset,
  }) =>
      SalePaymentListCriteria(
        search: search ?? this.search,
        method: clearMethod ? null : (method ?? this.method),
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
      search.isNotEmpty ||
      method != null ||
      status != null ||
      datePreset != DatePreset.all;
}

class SalePaymentCriteria extends Notifier<SalePaymentListCriteria> {
  @override
  SalePaymentListCriteria build() => const SalePaymentListCriteria();

  void setSearch(String v) => state = state.copyWith(search: v);
  void setMethod(PaymentMethod? v) =>
      state = state.copyWith(method: v, clearMethod: v == null);
  void setStatus(PaymentRecordStatus? v) =>
      state = state.copyWith(status: v, clearStatus: v == null);
  void setDatePreset(DatePreset v) => state = state.copyWith(datePreset: v);
  void reset() => state = const SalePaymentListCriteria();
}

final salePaymentCriteriaProvider =
    NotifierProvider<SalePaymentCriteria, SalePaymentListCriteria>(
        SalePaymentCriteria.new);

class SalePaymentListNotifier extends PagedListNotifier<SalePaymentListItem> {
  @override
  int get pageSize => SaleOrderService.pageSize;

  @override
  PagedState<SalePaymentListItem> build() {
    ref.listen(salePaymentCriteriaProvider, (_, __) => reload());
    return super.build();
  }

  @override
  Future<List<SalePaymentListItem>> fetch(int page) {
    final c = ref.read(salePaymentCriteriaProvider);
    return ref.read(saleOrderServiceProvider).listPayments(
          page: page,
          method: c.method,
          status: c.status,
          from: c.from,
          to: c.to,
          search: c.search,
        );
  }
}

final salePaymentListProvider =
    NotifierProvider<SalePaymentListNotifier, PagedState<SalePaymentListItem>>(
        SalePaymentListNotifier.new);

String paymentMethodLabel(AppLocalizations l10n, PaymentMethod m) =>
    switch (m) {
      PaymentMethod.cash => l10n.spMethodCash,
      PaymentMethod.creditCard => l10n.spMethodCreditCard,
      PaymentMethod.bankTransfer => l10n.spMethodBankTransfer,
      PaymentMethod.check => l10n.spMethodCheck,
      PaymentMethod.digitalWallet => l10n.spMethodDigitalWallet,
      PaymentMethod.other => l10n.spMethodOther,
    };

String paymentRecordStatusLabel(AppLocalizations l10n, PaymentRecordStatus s) =>
    switch (s) {
      PaymentRecordStatus.pending => l10n.spStatusPending,
      PaymentRecordStatus.completed => l10n.spStatusCompleted,
      PaymentRecordStatus.failed => l10n.spStatusFailed,
      PaymentRecordStatus.refunded => l10n.spStatusRefunded,
    };
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/sales/sale_order/sale_payment_list_provider_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/sales/sale_order/presentation/sale_payment_providers.dart test/features/sales/sale_order/sale_payment_list_provider_test.dart
git commit -m "feat(sales): add payment ledger providers and label helpers"
```

---

### Task 7: Presentation — `SalePaymentListScreen`

**Files:**
- Create: `lib/features/sales/sale_order/presentation/sale_payment_list_screen.dart`
- Test: `test/features/sales/sale_order/sale_payment_list_test.dart`

**Interfaces:**
- Consumes: `salePaymentListProvider`, `salePaymentCriteriaProvider`, `paymentMethodLabel`, `paymentRecordStatusLabel` (Task 6); `DatePreset` + `SaleOrderDetailScreen` (from `sale_order_providers.dart` / `sale_order_detail_screen.dart`); `moneyFormatterProvider`, `customerProvider`, `PaginatedListView`, `SearchField`, `EmptyState`, `AppCard`, `context.l10n`.
- Produces: `class SalePaymentListScreen extends ConsumerStatefulWidget` with a `const` constructor.

- [ ] **Step 1: Write the failing widget test**

Create `test/features/sales/sale_order/sale_payment_list_test.dart`:

```dart
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:inventoryhub_mobile/core/db/app_database.dart';
import 'package:inventoryhub_mobile/core/id/id_generator.dart';
import 'package:inventoryhub_mobile/core/providers.dart';
import 'package:inventoryhub_mobile/core/seed/seed_service.dart';
import 'package:inventoryhub_mobile/l10n/app_localizations.dart';
import 'package:inventoryhub_mobile/features/sales/sale_order/presentation/sale_payment_list_screen.dart';
import '../../../helpers/test_db.dart';

void main() {
  testWidgets('renders a seeded payment row', (tester) async {
    final db = newTestDb();
    addTearDown(db.close);
    final session = await SeedService(db, const IdGenerator()).ensureSeeded();
    final now = DateTime.utc(2026, 6, 1);
    await db.into(db.saleOrders).insert(SaleOrdersCompanion.insert(
          id: 'so1', organizationId: session.organizationId,
          soNumber: 'SO-0001', customerId: 'c1', orderDate: now,
          totalAmount: const Value(100), createdAt: now, updatedAt: now,
        ));
    await db.saleOrderPaymentDao.recordPayment(SaleOrderPaymentsCompanion.insert(
      id: 'p1', organizationId: session.organizationId, saleOrderId: 'so1',
      paymentNumber: 'PAY-0001', amount: 10, method: 'cash',
      status: const Value('completed'), paymentDate: now,
      createdAt: now, updatedAt: now,
    ));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sessionProvider.overrideWithValue(session),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SalePaymentListScreen(),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('PAY-0001'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/sales/sale_order/sale_payment_list_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'sale_payment_list_screen.dart'`.

- [ ] **Step 3: Write the screen**

Create `lib/features/sales/sale_order/presentation/sale_payment_list_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:inventoryhub_mobile/app/currency/currency_controller.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/paginated_list_view.dart';
import '../../../../core/widgets/search_field.dart';
import '../domain/sale_order.dart';
import '../domain/sale_order_enums.dart';
import '../../customer/presentation/customer_providers.dart';
import 'sale_order_detail_screen.dart';
import 'sale_order_providers.dart' show DatePreset;
import 'sale_payment_providers.dart';

class SalePaymentListScreen extends ConsumerStatefulWidget {
  const SalePaymentListScreen({super.key});

  @override
  ConsumerState<SalePaymentListScreen> createState() =>
      _SalePaymentListScreenState();
}

class _SalePaymentListScreenState extends ConsumerState<SalePaymentListScreen> {
  bool _searching = false;

  SalePaymentListNotifier get _notifier =>
      ref.read(salePaymentListProvider.notifier);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final money = ref.watch(moneyFormatterProvider);
    final state = ref.watch(salePaymentListProvider);
    final criteria = ref.watch(salePaymentCriteriaProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? SearchField(
                initial: criteria.search,
                hint: l10n.soSearchHint,
                onChanged: (v) => ref
                    .read(salePaymentCriteriaProvider.notifier)
                    .setSearch(v),
              )
            : Text(l10n.spLedgerTitle),
        actions: [
          if (criteria.hasActiveFilters)
            IconButton(
              tooltip: l10n.soClearAllFiltersTooltip,
              icon: const Icon(Icons.filter_alt_off),
              onPressed: () {
                ref.read(salePaymentCriteriaProvider.notifier).reset();
                if (_searching) setState(() => _searching = false);
              },
            ),
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => _searching = !_searching);
              if (!_searching) {
                ref.read(salePaymentCriteriaProvider.notifier).setSearch('');
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
            child: PaginatedListView<SalePaymentListItem>(
              state: state,
              onLoadMore: _notifier.loadMore,
              onRefresh: _notifier.refresh,
              onRetryInitial: _notifier.loadInitial,
              empty: EmptyState(
                icon: Icons.payments_outlined,
                title: l10n.spLedgerEmpty,
              ),
              itemBuilder: (context, p) => AppCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                onTap: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          SaleOrderDetailScreen(orderId: p.saleOrderId)));
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
                      child: Icon(Icons.payments,
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
                                p.paymentNumber,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurface,
                                ),
                              ),
                              Text(
                                money(p.amount),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                p.soNumber,
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
                                        ref.watch(customerProvider(p.customerId));
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
                                DateFormat.yMMMd().format(p.paymentDate),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: [
                                  _badge(
                                      context,
                                      paymentMethodLabel(l10n, p.method),
                                      scheme.primary),
                                  const SizedBox(width: 6),
                                  _badge(
                                      context,
                                      paymentRecordStatusLabel(l10n, p.status),
                                      _statusColor(p.status)),
                                ],
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

  Widget _badge(BuildContext context, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(6)),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      );

  Color _statusColor(PaymentRecordStatus s) => switch (s) {
        PaymentRecordStatus.completed => Colors.green.shade700,
        PaymentRecordStatus.pending => Colors.amber.shade700,
        PaymentRecordStatus.failed => Colors.red.shade700,
        PaymentRecordStatus.refunded => Colors.blueGrey.shade600,
      };
}

class _Filters extends ConsumerWidget {
  const _Filters({required this.criteria});
  final SalePaymentListCriteria criteria;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final n = ref.read(salePaymentCriteriaProvider.notifier);
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
          _FilterPill<DatePreset>(
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
          _FilterPill<PaymentMethod?>(
            label: l10n.spFilterMethodLabel,
            isActive: criteria.method != null,
            displayValue: criteria.method != null
                ? paymentMethodLabel(l10n, criteria.method!)
                : '',
            onChanged: n.setMethod,
            onClear: () => n.setMethod(null),
            items: [
              PopupMenuItem(value: null, child: Text(l10n.spMethodAny)),
              for (final m in PaymentMethod.values)
                PopupMenuItem(
                    value: m, child: Text(paymentMethodLabel(l10n, m))),
            ],
          ),
          const SizedBox(width: 8),
          _FilterPill<PaymentRecordStatus?>(
            label: l10n.spFilterStatusLabel,
            isActive: criteria.status != null,
            displayValue: criteria.status != null
                ? paymentRecordStatusLabel(l10n, criteria.status!)
                : '',
            onChanged: n.setStatus,
            onClear: () => n.setStatus(null),
            items: [
              PopupMenuItem(value: null, child: Text(l10n.spStatusAny)),
              for (final s in PaymentRecordStatus.values)
                PopupMenuItem(
                    value: s, child: Text(paymentRecordStatusLabel(l10n, s))),
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

class _FilterPill<T> extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.isActive,
    required this.displayValue,
    required this.items,
    required this.onChanged,
    required this.onClear,
  });

  final String label;
  final bool isActive;
  final String displayValue;
  final List<PopupMenuEntry<T>> items;
  final ValueChanged<T> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isActive
            ? scheme.primary.withOpacity(0.08)
            : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? scheme.primary
              : scheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PopupMenuButton<T>(
            onSelected: onChanged,
            itemBuilder: (_) => items,
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: 12,
                end: isActive ? 6 : 12,
                top: 6,
                bottom: 6,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isActive ? '$label: ' : label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                      color:
                          isActive ? scheme.primary : scheme.onSurfaceVariant,
                    ),
                  ),
                  if (isActive)
                    Text(
                      displayValue,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                      ),
                    )
                  else ...[
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down,
                        size: 16, color: scheme.onSurfaceVariant),
                  ],
                ],
              ),
            ),
          ),
          if (isActive)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: InkWell(
                onTap: onClear,
                borderRadius: BorderRadius.circular(100),
                child: Icon(Icons.cancel, size: 16, color: scheme.primary),
              ),
            ),
        ],
      ),
    );
  }
}
```

> Note: `_FilterPill` is duplicated from `sale_order_list_screen.dart` deliberately — the spec allows duplicating the pill rather than extracting a shared widget, to avoid destabilizing the order screen. If a shared `core/widgets/filter_pill.dart` already exists, import it instead and delete this local copy.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/sales/sale_order/sale_payment_list_test.dart`
Expected: PASS. (If the seed helper requires a customer named for `c1`, the row still renders `PAY-0001`; the customer label falls back to "unknown" which does not affect the assertion.)

- [ ] **Step 5: Commit**

```bash
git add lib/features/sales/sale_order/presentation/sale_payment_list_screen.dart test/features/sales/sale_order/sale_payment_list_test.dart
git commit -m "feat(sales): add sale payments ledger screen"
```

---

### Task 8: Entry point — "All Payments" tile on the sales dashboard

**Files:**
- Modify: `lib/features/sales/sale_order/presentation/sale_order_dashboard_screen.dart`

**Interfaces:**
- Consumes: `SalePaymentListScreen` (Task 7), existing `AppCard`, `AppTokens`, `context.l10n`, `l10n.spLedgerTitle`.
- Produces: a tappable card between the outstanding-receivables card and the payment-status distribution that pushes `SalePaymentListScreen`.

- [ ] **Step 1: Add the import**

At the top of `sale_order_dashboard_screen.dart`, add alongside the existing presentation imports:

```dart
import 'sale_payment_list_screen.dart';
```

- [ ] **Step 2: Insert the tile in the dashboard column**

In the `build`/body column, immediately after the outstanding-receivables block (the `kpisAsync.when(...)` that renders `_buildOutstandingCard`, ending around line 65 with its trailing `SizedBox(height: AppTokens.space24)`), insert:

```dart
            // All payments ledger
            _buildAllPaymentsTile(context, ref),
            const SizedBox(height: AppTokens.space24),
```

- [ ] **Step 3: Add the tile builder method**

Add this method to the dashboard widget class (e.g. right after `_buildOutstandingCard`):

```dart
  Widget _buildAllPaymentsTile(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AppCard(
      padding: const EdgeInsets.all(AppTokens.space16),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const SalePaymentListScreen())),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTokens.space12),
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.payments_rounded,
                color: scheme.primary, size: 24),
          ),
          const SizedBox(width: AppTokens.space16),
          Expanded(
            child: Text(
              context.l10n.spLedgerTitle,
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
Expected: PASS (existing dashboard test unaffected).
Then: `flutter analyze lib/features/sales/sale_order/presentation/sale_order_dashboard_screen.dart`
Expected: No issues.

- [ ] **Step 5: Commit**

```bash
git add lib/features/sales/sale_order/presentation/sale_order_dashboard_screen.dart
git commit -m "feat(sales): add All Payments entry tile to sales dashboard"
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
git commit -m "fix(sales): resolve payments ledger analyze/test issues"
```

---

## Self-Review Notes

- **Spec coverage:** DAO query (Task 1), read-model + mapper (Task 2), repository (Task 3), service (Task 4), l10n (Task 5), providers (Task 6), screen with Date/Method/Status + SO-number search + tap-to-order (Task 7), dashboard entry (Task 8). Decisions honored: include cancelled-order payments (no exclusion in Task 1), all `PaymentRecordStatus` values exposed (Task 7 filter loops `PaymentRecordStatus.values`), no summary total (absent by design), search = SO number only, `isActive` only, `paymentDate` ordering.
- **Type consistency:** `pagedPayments` record type `({SaleOrderPaymentRow payment, String soNumber, String customerId})` is produced in Task 1 and consumed verbatim in Task 3. `SalePaymentListItem` field set is identical across Tasks 2/6/7. `listPayments` signature matches between Task 4 (definition) and Task 6 (call). Label helpers `paymentMethodLabel`/`paymentRecordStatusLabel` defined in Task 6, used in Task 7.
- **Open verification for the implementer:** confirm the exact positional constructor arg order of `SaleOrderRepositoryImpl` (Task 3/4 tests assume `SaleOrderDao, SaleOrderPaymentDao, SaleOrderShippingDao, DocumentCounterDao` — matches `saleOrderServiceProvider`). If `newTestDb`/`SeedService` seeds differ, adjust seeded ids but keep assertions.
