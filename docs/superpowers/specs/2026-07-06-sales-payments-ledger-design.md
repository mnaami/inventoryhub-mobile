# Sales Payments Ledger — Design

**Date:** 2026-07-06
**Status:** Approved (pending spec review)

## Goal

Give the end user a single screen listing **all** sales payments across every
order — a chronological payment ledger — reachable from the sales dashboard.

Today payments are only visible per-order, inside `SaleOrderDetailScreen`
(`SaleOrderPaymentDao.paymentsFor(saleOrderId)`). There is no org-wide or paged
payments query. This feature adds one, mirroring the existing sale-order paged
list stack layer-for-layer.

## Scope

A flat, infinite-scroll list of individual payment records (one row per
payment), newest first, with Date / Method / Status filters and search by SO
number. Tapping a row opens the parent order's detail screen.

**Out of scope (v1):** grouping/rollups, customer-name search, summary totals,
export, editing payments from this screen (done via order detail).

## Decisions

- **Row granularity:** one row per individual payment record.
- **Entry point:** an "All Payments" tile on `sale_order_dashboard_screen`.
- **Filters:** Date preset (all/today/week/month) + Method + Status + search.
- **Search:** matches **SO number only** (`soNumber LIKE %q%`), consistent with
  the existing order-list search. Customer-name search is out of scope for v1.
- **Tap action:** navigate to `SaleOrderDetailScreen(orderId: saleOrderId)`;
  refresh the list on return.
- **Cancelled orders:** payments against cancelled orders **are included** (this
  is a raw ledger, unlike the money aggregates such as `completedTotalForOrg`
  which exclude cancelled).
- **Status filter:** exposes all `PaymentRecordStatus` values —
  `pending, completed, failed, refunded`.
- **Method filter:** all `PaymentMethod` values —
  `cash, creditCard, bankTransfer, check, digitalWallet, other`.
- **Soft-deleted payments:** excluded (`isActive == true` only).
- **No summary/total header** in v1.

## Architecture

Reuses the existing paging infrastructure unchanged: `PagedListNotifier<T>`,
`PagedState<T>`, `PaginatedListView<T>`. Each layer mirrors its sale-order
counterpart.

### 1. Data — `SaleOrderPaymentDao.pagedPayments(...)`

New method:

```
Future<List<JoinedRow>> pagedPayments(
  String orgId, {
  String? method,        // wire value
  String? status,        // wire value
  DateTime? from,        // inclusive lower bound on paymentDate
  DateTime? to,          // exclusive upper bound on paymentDate
  String? search,        // matched against saleOrders.soNumber
  required int limit,
  required int offset,
})
```

- Joins `saleOrderPayments ⋈ saleOrders` (inner join on
  `saleOrders.id == saleOrderPayments.saleOrderId`).
- Filters: `saleOrderPayments.organizationId == orgId`,
  `saleOrderPayments.isActive == true`, plus each optional filter when present.
- **No cancelled-order exclusion** (decision above).
- `search` → `saleOrders.soNumber.like('%q%')` when non-empty.
- Order by `paymentDate DESC`, then `createdAt DESC` as a stable tiebreaker.
- `limit` / `offset` for paging.
- Returns rows carrying every payment column **plus** `saleOrders.soNumber` and
  `saleOrders.customerId` (needed because `SaleOrderPayment` carries neither).

### 2. Domain

- New freezed read-model `SalePaymentListItem`:
  - all `SaleOrderPayment` fields (id, organizationId, saleOrderId,
    paymentNumber, amount, method, status, paymentDate, isActive, createdAt,
    updatedAt)
  - `soNumber` (String)
  - `customerId` (String)
- `SaleOrderRepository`: add
  `Future<List<SalePaymentListItem>> pagedPayments(String orgId, {...same
  filters..., required int limit, required int offset})`.
- `SaleOrderRepositoryImpl`: implement by calling the DAO and mapping joined
  rows → `SalePaymentListItem` (new mapper).
- `SaleOrderService`: add
  `Future<List<SalePaymentListItem>> listPayments({int page = 0, PaymentMethod?
  method, PaymentRecordStatus? status, DateTime? from, DateTime? to, String
  search = ''})` — converts enums to wire, computes `limit: pageSize`
  (existing constant, 20) and `offset: page * pageSize`. Mirrors `list(...)`.

### 3. Providers — `sale_payment_providers.dart` (new file)

- `SalePaymentListCriteria` (immutable) + `copyWith`: `search`, `method`,
  `status`, `datePreset`, with `from`/`to` derived from `datePreset` exactly as
  `SaleOrderListCriteria` does, and `hasActiveFilters`.
- `SalePaymentCriteria` notifier: `setSearch`, `setMethod`, `setStatus`,
  `setDatePreset`, `reset`.
- `SalePaymentListNotifier extends PagedListNotifier<SalePaymentListItem>`:
  `pageSize => SaleOrderService.pageSize`; `build()` listens to the criteria
  provider and `reload()`s on change; `fetch(page)` reads criteria and calls
  `service.listPayments(...)`.
- `salePaymentListProvider`, `salePaymentCriteriaProvider`.
- Reuse `saleOrderServiceProvider` (already exposes the service).

### 4. Presentation — `sale_payment_list_screen.dart` (new file)

- `ConsumerStatefulWidget` modeled on `SaleOrderListScreen`.
- AppBar: title (l10n) + search toggle using the shared `SearchField`
  + clear-filters action when `hasActiveFilters`.
- Filter row: three `_FilterPill`s — Date, Method, Status. (Pill widget can be
  reused/adapted from the order list; extract to a shared widget only if trivial,
  otherwise duplicate to avoid destabilizing the order screen.)
- Body: `PaginatedListView<SalePaymentListItem>` with `onLoadMore`,
  `onRefresh`, `onRetryInitial`, and an `EmptyState`.
- Row card (`AppCard`): payment number + amount (via `moneyFormatterProvider`),
  method + status badges, SO number + customer name (resolved with a `Consumer`
  watching `customerProvider(item.customerId)`, same as the order list),
  payment date (`DateFormat`). `onTap` → push
  `SaleOrderDetailScreen(orderId: item.saleOrderId)`; `await notifier.refresh()`
  on return.

### 5. Entry point

- Add an "All Payments" tile/card to `sale_order_dashboard_screen.dart`
  (alongside the existing order shortcuts) that pushes `SalePaymentListScreen`.

### 6. Localization

New ARB keys (with existing-key reuse where possible):
- screen title, empty-state title, search hint
- filter labels: Method, Status (Date preset labels already exist as `soDate*`)
- method value labels (`cash`, `credit card`, `bank transfer`, `check`,
  `digital wallet`, `other`) if not already localized
- status value labels (`pending`, `completed`, `failed`, `refunded`)

Add to all locale ARB files and regenerate.

## Data flow

```
SalePaymentListScreen
  → watches salePaymentListProvider (PagedState<SalePaymentListItem>)
  → PaginatedListView renders rows / triggers loadMore
SalePaymentListNotifier.fetch(page)
  → reads salePaymentCriteriaProvider
  → SaleOrderService.listPayments(page, method, status, from, to, search)
  → SaleOrderRepositoryImpl.pagedPayments(...)
  → SaleOrderPaymentDao.pagedPayments(...)  [payments ⋈ orders]
  → List<SalePaymentListItem>
Criteria change → notifier.reload() → fresh page 0
Row tap → SaleOrderDetailScreen(orderId) → back → notifier.refresh()
```

## Error handling

- Fetch errors surface through `PagedState.error`; `PaginatedListView` already
  renders retry (initial) and inline error (load-more) states. No new handling.
- Customer-name lookups degrade to an "unknown customer" label on error, same as
  the order list.

## Testing

- **DAO** (`sale_order_payment_dao` test): seed payments across multiple orders
  (incl. a cancelled order and a soft-deleted payment); assert
  - method / status / date-range filters each narrow correctly,
  - search matches by SO number,
  - cancelled-order payments **are** returned,
  - soft-deleted payments are **not** returned,
  - ordering is `paymentDate DESC`,
  - `limit`/`offset` paging returns the right slice and `hasMore` boundary
    (page size 20).
- **Service** (`listPayments`): asserts enum→wire conversion and
  `offset = page * pageSize`.
- **Widget** (optional): list renders a seeded page and a row tap pushes
  `SaleOrderDetailScreen`.

## Files touched

New:
- `lib/features/sales/sale_order/presentation/sale_payment_list_screen.dart`
- `lib/features/sales/sale_order/presentation/sale_payment_providers.dart`
- `SalePaymentListItem` model (in `domain/sale_order.dart` or a new
  `domain/sale_payment_list_item.dart`)

Modified:
- `data/sale_order_payment_dao.dart` (+ regenerated `.g.dart`)
- `data/sale_order_mappers.dart` (joined-row → `SalePaymentListItem`)
- `domain/sale_order_repository.dart`
- `data/sale_order_repository_impl.dart`
- `domain/sale_order_usecases.dart` (`listPayments`)
- `presentation/sale_order_dashboard_screen.dart` (entry tile)
- ARB locale files + generated l10n
