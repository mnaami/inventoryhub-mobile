import 'package:freezed_annotation/freezed_annotation.dart';

part 'paged_state.freezed.dart';

@freezed
abstract class PagedState<T> with _$PagedState<T> {
  const PagedState._();
  const factory PagedState({
    required List<T> items,
    required int page,
    required bool hasMore,
    required bool isLoadingInitial,
    required bool isLoadingMore,
    Object? error,
  }) = _PagedState<T>;

  factory PagedState.initial() => PagedState<T>(
        items: const [],
        page: 0,
        hasMore: true,
        isLoadingInitial: true,
        isLoadingMore: false,
        error: null,
      );

  bool get isEmpty =>
      items.isEmpty && !isLoadingInitial && error == null;
}
