import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/paging/paged_list_notifier.dart';
import 'package:inventoryhub_mobile/core/paging/paged_state.dart';

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

PagedState<int> read(ProviderContainer c,
        NotifierProvider<_FakeNotifier, PagedState<int>> p) =>
    c.read(p);

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
}
