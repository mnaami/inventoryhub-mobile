import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'paged_state.dart';

/// Reusable infinite-scroll paging state machine. Subclasses implement [fetch];
/// the screen calls [loadMore]/[refresh] and watches the [PagedState].
abstract class PagedListNotifier<T> extends Notifier<PagedState<T>> {
  int get pageSize => 20;

  /// Loads page [page] (0-based) of results for the current criteria.
  Future<List<T>> fetch(int page);

  @override
  PagedState<T> build() {
    Future.microtask(loadInitial);
    return PagedState<T>.initial();
  }

  Future<void> loadInitial() async {
    state = PagedState<T>.initial();
    try {
      final items = await fetch(0);
      state = PagedState<T>(
        items: items,
        page: 0,
        hasMore: items.length == pageSize,
        isLoadingInitial: false,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingInitial: false, error: e);
    }
  }

  Future<void> loadMore() async {
    final s = state;
    if (s.isLoadingInitial || s.isLoadingMore || !s.hasMore) return;
    state = s.copyWith(isLoadingMore: true, error: null);
    try {
      final next = s.page + 1;
      final items = await fetch(next);
      state = state.copyWith(
        items: [...s.items, ...items],
        page: next,
        hasMore: items.length == pageSize,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e);
    }
  }

  Future<void> refresh() => loadInitial();

  void reload() {
    Future.microtask(loadInitial);
  }
}
