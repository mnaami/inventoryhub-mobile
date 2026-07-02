import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/paging/paged_list_notifier.dart';
import 'package:inventoryhub_mobile/core/paging/paged_state.dart';

class _GatedNotifier extends PagedListNotifier<int> {
  final List<Completer<List<int>>> gates = [];
  final List<int> requestedPages = [];
  @override
  Future<List<int>> fetch(int page) {
    requestedPages.add(page);
    final c = Completer<List<int>>();
    gates.add(c);
    return c.future;
  }
}

final gatedProvider =
    NotifierProvider<_GatedNotifier, PagedState<int>>(_GatedNotifier.new);

class _FakeNotifier extends PagedListNotifier<int> {
  _FakeNotifier(this._pages);
  final List<List<int>> _pages;
  final List<int> fetchedPages = [];
  Object? throwOn; // set to a page index to simulate failure

  @override
  int get pageSize => 3;

  @override
  Future<List<int>> fetch(int page) async {
    fetchedPages.add(page);
    if (throwOn == page) throw StateError('boom');
    return page < _pages.length ? _pages[page] : <int>[];
  }
}

void main() {
  test('loadInitial populates items and sets hasMore on full page', () async {
    final p = NotifierProvider<_FakeNotifier, PagedState<int>>(
        () => _FakeNotifier([[1, 2, 3]]));
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(p); // triggers build + scheduled loadInitial
    await Future<void>.delayed(Duration.zero);
    final s = c.read(p);
    expect(s.items, [1, 2, 3]);
    expect(s.hasMore, true); // full page
    expect(s.isLoadingInitial, false);
  });

  test('loadMore appends next page and stops on short page', () async {
    final p = NotifierProvider<_FakeNotifier, PagedState<int>>(
        () => _FakeNotifier([[1, 2, 3], [4, 5]]));
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(p);
    await Future<void>.delayed(Duration.zero);
    await c.read(p.notifier).loadMore();
    final s = c.read(p);
    expect(s.items, [1, 2, 3, 4, 5]);
    expect(s.hasMore, false); // short page => no more
    expect(s.page, 1);
  });

  test('loadMore is a no-op when hasMore is false', () async {
    final p = NotifierProvider<_FakeNotifier, PagedState<int>>(
        () => _FakeNotifier([[1, 2]])); // short first page
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(p);
    await Future<void>.delayed(Duration.zero);
    final n = c.read(p.notifier);
    n.fetchedPages.clear();
    await n.loadMore();
    expect(n.fetchedPages, isEmpty);
  });

  test('initial error sets error and clears loading', () async {
    final fake = _FakeNotifier([[1, 2, 3]])..throwOn = 0;
    final p = NotifierProvider<_FakeNotifier, PagedState<int>>(() => fake);
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(p);
    await Future<void>.delayed(Duration.zero);
    final s = c.read(p);
    expect(s.error, isA<StateError>());
    expect(s.isLoadingInitial, false);
    expect(s.items, isEmpty);
  });

  test('loadMore error keeps existing items', () async {
    final fake = _FakeNotifier([[1, 2, 3], [4, 5, 6]])..throwOn = 1;
    final p = NotifierProvider<_FakeNotifier, PagedState<int>>(() => fake);
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(p);
    await Future<void>.delayed(Duration.zero);
    await c.read(p.notifier).loadMore();
    final s = c.read(p);
    expect(s.items, [1, 2, 3]); // preserved
    expect(s.error, isA<StateError>());
    expect(s.isLoadingMore, false);
  });

  test('refresh reloads from page 0', () async {
    final p = NotifierProvider<_FakeNotifier, PagedState<int>>(
        () => _FakeNotifier([[1, 2, 3], [4, 5, 6]]));
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(p);
    await Future<void>.delayed(Duration.zero);
    await c.read(p.notifier).loadMore();
    await c.read(p.notifier).refresh();
    final s = c.read(p);
    expect(s.page, 0);
    expect(s.items, [1, 2, 3]);
  });

  test('stale loadMore is dropped when a reload supersedes it', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final n = container.read(gatedProvider.notifier);

    // build() schedules loadInitial -> gate[0] is fetch(0), gen 1
    await Future.microtask(() {});
    n.gates[0].complete(List.filled(20, 1)); // full page -> hasMore
    await Future.microtask(() {});

    n.loadMore();                 // captures gen 1 -> gate[1] = fetch(1)
    await Future.microtask(() {});
    n.reload();                   // bumps gen 2 -> gate[2] = fetch(0)
    await Future.microtask(() {});

    // Resolve the FRESH reload first, then the STALE loadMore last: only the
    // generation guard stops the late-arriving stale page from clobbering
    // the fresh state. Without it, whichever fetch resolves last always
    // wins, so completion order must put the stale one last to discriminate.
    n.gates[2].complete(List.filled(3, 2));   // fresh page-0 resolves first
    await Future.microtask(() {});
    n.gates[1].complete(List.filled(5, 9));   // stale page-1 resolves last
    await Future.microtask(() {});

    final s = container.read(gatedProvider);
    expect(s.items, [2, 2, 2]);   // only fresh page-0, no foreign 9s
    expect(s.page, 0);
  });

  test('rapid reloads are last-write-wins', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final n = container.read(gatedProvider.notifier);
    await Future.microtask(() {});
    n.gates[0].complete(const []);          // initial gen 1
    await Future.microtask(() {});

    n.reload();                              // gen 2 -> gate[1]
    await Future.microtask(() {});
    n.reload();                              // gen 3 -> gate[2]
    await Future.microtask(() {});

    // Resolve the newest generation (3) first and the older one (2) last:
    // the guard must drop gen 2's late result so the newest reload still
    // wins. Without the guard, last-to-resolve always wins regardless of
    // generation, so this ordering is what makes the test discriminating.
    n.gates[2].complete(List.filled(2, 8));  // gen-3 result resolves first
    await Future.microtask(() {});
    n.gates[1].complete(List.filled(2, 7));  // gen-2 result (stale) resolves last
    await Future.microtask(() {});

    expect(container.read(gatedProvider).items, [8, 8]);
  });

  test('disposed mid-fetch does not throw and does not set state', () async {
    final container = ProviderContainer();
    final n = container.read(gatedProvider.notifier);
    await Future.microtask(() {}); // fetch(0) pending in gate[0]

    container.dispose(); // dispose before completion
    n.gates[0].complete(List.filled(3, 1)); // must be a no-op, not a StateError
    await Future.microtask(() {});
    // Reaching here without an exception is the assertion.
    expect(true, isTrue);
  });
}
