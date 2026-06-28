import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventoryhub_mobile/core/paging/paged_state.dart';
import 'package:inventoryhub_mobile/core/widgets/paginated_list_view.dart';

Widget _wrap(Widget c) => MaterialApp(home: Scaffold(body: c));

PaginatedListView<int> view(
  PagedState<int> state, {
  Future<void> Function()? onLoadMore,
  Future<void> Function()? onRefresh,
  Future<void> Function()? onRetryInitial,
}) =>
    PaginatedListView<int>(
      state: state,
      itemBuilder: (_, v) => SizedBox(height: 100, child: Text('item $v')),
      onLoadMore: onLoadMore ?? () async {},
      onRefresh: onRefresh ?? () async {},
      onRetryInitial: onRetryInitial ?? () async {},
    );

void main() {
  testWidgets('shows spinner while loading initial', (tester) async {
    await tester.pumpWidget(_wrap(view(PagedState<int>.initial())));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows empty state when no items', (tester) async {
    await tester.pumpWidget(_wrap(view(const PagedState<int>(
        items: [], page: 0, hasMore: false,
        isLoadingInitial: false, isLoadingMore: false))));
    expect(find.text('Nothing here yet.'), findsOneWidget);
  });

  testWidgets('shows initial error with retry', (tester) async {
    var retried = false;
    await tester.pumpWidget(_wrap(view(
      PagedState<int>(items: const [], page: 0, hasMore: false,
          isLoadingInitial: false, isLoadingMore: false,
          error: StateError('x')),
      onRetryInitial: () async => retried = true,
    )));
    expect(find.text('Retry'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retried, true);
  });

  testWidgets('renders items and a load-more spinner footer', (tester) async {
    await tester.pumpWidget(_wrap(view(const PagedState<int>(
        items: [1, 2], page: 0, hasMore: true,
        isLoadingInitial: false, isLoadingMore: true))));
    expect(find.text('item 1'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget); // footer
  });

  testWidgets('load-more error footer retries', (tester) async {
    var retried = false;
    await tester.pumpWidget(_wrap(view(
      PagedState<int>(items: const [1], page: 0, hasMore: true,
          isLoadingInitial: false, isLoadingMore: false,
          error: StateError('x')),
      onLoadMore: () async => retried = true,
    )));
    expect(find.textContaining('Retry'), findsOneWidget);
    await tester.tap(find.textContaining('Retry'));
    expect(retried, true);
  });

  testWidgets('scrolling near the bottom triggers load-more', (tester) async {
    var loaded = false;
    await tester.pumpWidget(_wrap(view(
      PagedState<int>(
          items: List<int>.generate(20, (i) => i),
          page: 0,
          hasMore: true,
          isLoadingInitial: false,
          isLoadingMore: false),
      onLoadMore: () async => loaded = true,
    )));
    await tester.drag(find.byType(Scrollable), const Offset(0, -5000));
    await tester.pump();
    expect(loaded, true);
  });
}
