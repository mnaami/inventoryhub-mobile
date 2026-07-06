# Sales Shipments Ledger — Design

**Date:** 2026-07-06
**Status:** Approved (pending spec review)

## Goal

Give the end user a single screen listing **all** sales shipments across every
order — a chronological shipments ledger — reachable from the sales dashboard.
Directly mirrors the just-shipped **Sales Payments Ledger**
([2026-07-06-sales-payments-ledger-design.md](2026-07-06-sales-payments-ledger-design.md))
layer-for-layer.

Today shipments are only visible per-order, inside `SaleOrderDetailScreen`
(`SaleOrderShippingDao.shipmentsFor(saleOrderId)`). There is no org-wide or
paged shipments query. This feature adds one.

## Scope

A flat, infinite-scroll list of individual shipment records (one row per
shipment), newest first, with Date + Status filters and search by SO number.
Tapping a row opens the parent order's detail screen.

**Out of scope (v1):** grouping/rollups, customer-name search, carrier filter,
tracking-number search, editing shipments from this screen (done via order
detail).

## Decisions (and how they differ from the payments ledger)

- **Row granularity:** one row per individual shipment record.
- **Entry point:** an "All Shipments" tile on `sale_order_dashboard_screen`.
- **Filters:** Date preset (all/today/week/month) + **Status** only. (Payments
  had Method too; shipments have no "method". Carrier is free-text, not an
  enum, so it is not offered as a pill.)
- **Search:** matches **SO number only** (`soNumber LIKE %q%`), consistent with
  the payments/orders search.
- **Tap action:** navigate to `SaleOrderDetailScreen(orderId: saleOrderId)`;
  refresh the list on return.
- **Status filter:** exposes all `ShipmentStatus` values —
  `shipped, inTransit, delivered, returned`.
- **No `isActive` on shipments:** the `SaleOrderShippings` table has no
  soft-delete flag (only `isSample`). The query therefore filters on the
  **order's** `isActive` (`saleOrders.isActive == true`) for consistency with
  every other order-scoped query and to avoid listing shipments of soft-deleted
  orders. `isSample` is NOT filtered (sample shipments appear, consistent with
  how sample orders/payments appear in their lists).
- **Cancelled orders:** an order cannot be cancelled once it has shipments
  (`SaleOrderService.cancel` blocks it), so cancelled-order shipments do not
  occur in practice; no special handling.
- **No summary/total header** in v1.

## Architecture

Reuses the existing paging infrastructure unchanged: `PagedListNotifier<T>`,
`PagedState<T>`, `PaginatedListView<T>`, and the shared `FilterPill<T>` widget
(`lib/core/widgets/filter_pill.dart`, extracted during the payments feature).
Each layer mirrors its payments counterpart.

### 1. Data — `SaleOrderShippingDao.pagedShipments(...)`

New method:

```
Future<List<({SaleOrderShippingRow shipment, String soNumber, String customerId})>>
    pagedShipments(
  String orgId, {
  String? status,        // wire value
  DateTime? from,        // inclusive lower bound on shippingDate
  DateTime? to,          // exclusive upper bound on shippingDate
  String? search,        // matched against saleOrders.soNumber
  required int limit,
  required int offset,
})
```

- Joins `saleOrderShippings ⋈ saleOrders` (inner join on
  `saleOrders.id == saleOrderShippings.saleOrderId`). `SaleOrders` is already on
  the DAO's `@DriftAccessor`, so no `.g.dart` regeneration.
- Filters: `saleOrderShippings.organizationId == orgId`,
  `saleOrders.isActive == true`, plus optional `status`, `shippingDate` range,
  and `search`.
- `search` → `saleOrders.soNumber.like('%q%')` when non-empty.
- Order by `shippingDate DESC`, then `createdAt DESC` tiebreaker.
- `limit` / `offset` for paging.
- Returns rows carrying every shipment column **plus** `saleOrders.soNumber` and
  `saleOrders.customerId`.

### 2. Domain

- New freezed read-model `SaleShipmentListItem`:
  - all `SaleOrderShipping` fields (id, organizationId, saleOrderId,
    soShippingNumber, shippingDate, carrier, trackingNumber, status, createdAt,
    updatedAt)
  - `soNumber` (String)
  - `customerId` (String)
- `SaleOrderRepository`: add
  `Future<List<SaleShipmentListItem>> pagedShipments(String orgId, {ShipmentStatus?
  status, DateTime? from, DateTime? to, String? search, required int limit,
  required int offset})`.
- `SaleOrderRepositoryImpl`: implement by calling the DAO and mapping joined
  rows → `SaleShipmentListItem` (new mapper `toSaleShipmentListItem`).
- `SaleOrderService`: add
  `Future<List<SaleShipmentListItem>> listShipments({int page = 0, ShipmentStatus?
  status, DateTime? from, DateTime? to, String search = ''})` — converts the
  enum to wire, `limit: pageSize` (20), `offset: page * pageSize`.

### 3. Providers — `sale_shipment_providers.dart` (new file)

- `SaleShipmentListCriteria` (immutable) + `copyWith`: `search`, `status`,
  `datePreset`, with `from`/`to` derived from `datePreset` exactly as the
  payments/orders criteria do, and `hasActiveFilters`.
- `SaleShipmentCriteria` notifier: `setSearch`, `setStatus`, `setDatePreset`,
  `reset`.
- `SaleShipmentListNotifier extends PagedListNotifier<SaleShipmentListItem>`:
  `pageSize => SaleOrderService.pageSize`; `build()` listens to the criteria
  provider and `reload()`s on change; `fetch(page)` reads criteria and calls
  `service.listShipments(...)`.
- `saleShipmentListProvider`, `saleShipmentCriteriaProvider`.
- Reuse `saleOrderServiceProvider` and the `DatePreset` enum from
  `sale_order_providers.dart`.
- `String shipmentStatusLabel(AppLocalizations, ShipmentStatus)` helper.

### 4. Presentation — `sale_shipment_list_screen.dart` (new file)

- `ConsumerStatefulWidget` modeled on `SalePaymentListScreen`.
- AppBar: title (l10n) + search toggle using the shared `SearchField`
  + clear-filters action when `hasActiveFilters`.
- Filter row: two shared `FilterPill`s — Date, Status.
- Body: `PaginatedListView<SaleShipmentListItem>` with `onLoadMore`,
  `onRefresh`, `onRetryInitial`, and an `EmptyState`.
- Row card (`AppCard`): shipping number + status badge, SO number + customer
  name (resolved with a `Consumer` watching `customerProvider(item.customerId)`),
  shipping date (`DateFormat`), and carrier + tracking number shown when present
  (`carrier`/`trackingNumber` are nullable). `onTap` → push
  `SaleOrderDetailScreen(orderId: item.saleOrderId)`; `await notifier.refresh()`
  on return. Icon: `Icons.local_shipping`.

### 5. Entry point

- Add an "All Shipments" tile to `sale_order_dashboard_screen.dart` (next to the
  "All Payments" tile) that pushes `SaleShipmentListScreen`.

### 6. Localization

New ARB keys (en + ar):
- screen title, empty-state title, status filter label, status "Any" option
- `ShipmentStatus` value labels: shipped, in transit, delivered, returned
- carrier / tracking-number row labels (e.g. "Tracking")
- reuse existing `soSearchHint`, `soDate*`, `soFilterDateLabel`, `soClearAll`,
  `soClearAllFiltersTooltip`, `soUnknownCustomer`, `soLoadingCustomer`.

## Data flow

```
SaleShipmentListScreen
  → watches saleShipmentListProvider (PagedState<SaleShipmentListItem>)
  → PaginatedListView renders rows / triggers loadMore
SaleShipmentListNotifier.fetch(page)
  → reads saleShipmentCriteriaProvider
  → SaleOrderService.listShipments(page, status, from, to, search)
  → SaleOrderRepositoryImpl.pagedShipments(...)
  → SaleOrderShippingDao.pagedShipments(...)  [shipments ⋈ orders]
  → List<SaleShipmentListItem>
Criteria change → notifier.reload() → fresh page 0
Row tap → SaleOrderDetailScreen(orderId) → back → notifier.refresh()
```

## Error handling

- Fetch errors surface through `PagedState.error`; `PaginatedListView` already
  renders retry/inline-error states. No new handling.
- Customer-name lookups degrade to an "unknown customer" label on error.

## Testing

- **DAO** (`sale_order_shipping_dao` test): seed shipments across multiple
  orders (incl. a soft-deleted order and different statuses); assert
  - status / date-range filters each narrow correctly,
  - search matches by SO number,
  - shipments of a soft-deleted order are **excluded** (order `isActive` filter),
  - ordering is `shippingDate DESC`,
  - `limit`/`offset` paging returns the right slice.
- **Service** (`listShipments`): enum→wire conversion and `offset = page * pageSize`.
- **Provider**: initial load + a status-filter change reloads filtered.
- **Widget** (optional): list renders a seeded row.

## Files touched

New:
- `lib/features/sales/sale_order/presentation/sale_shipment_list_screen.dart`
- `lib/features/sales/sale_order/presentation/sale_shipment_providers.dart`
- `SaleShipmentListItem` model (in `domain/sale_order.dart`)

Modified:
- `data/sale_order_shipping_dao.dart`
- `data/sale_order_mappers.dart` (joined-row → `SaleShipmentListItem`)
- `domain/sale_order_repository.dart`
- `data/sale_order_repository_impl.dart`
- `domain/sale_order_usecases.dart` (`listShipments`)
- `presentation/sale_order_dashboard_screen.dart` (entry tile)
- ARB locale files + generated l10n
