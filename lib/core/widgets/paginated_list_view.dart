import 'package:flutter/material.dart';
import '../l10n/l10n_ext.dart';
import '../paging/paged_state.dart';
import '../result/app_exception.dart';
import '../../app/theme/app_tokens.dart';
import 'empty_state.dart';

/// Renders a [PagedState] as an infinite-scroll list with pull-to-refresh,
/// a load-more footer (spinner / retry), and centered initial loading/error.
class PaginatedListView<T> extends StatefulWidget {
  const PaginatedListView({
    super.key,
    required this.state,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.onRefresh,
    required this.onRetryInitial,
    this.empty,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.loadMoreThreshold = 0.8,
  }) : assert(loadMoreThreshold > 0 && loadMoreThreshold <= 1);

  final PagedState<T> state;
  final Widget Function(BuildContext, T) itemBuilder;
  final Future<void> Function() onLoadMore;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onRetryInitial;
  final Widget? empty;
  final EdgeInsets padding;
  final double loadMoreThreshold;

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    final max = _controller.position.maxScrollExtent;
    if (max <= 0) return;
    final s = widget.state;
    if (s.isLoadingMore || !s.hasMore) return;
    if (_controller.position.pixels >= max * widget.loadMoreThreshold) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;

    if (s.isLoadingInitial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (s.items.isEmpty && s.error != null) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: _InitialError(error: s.error!, onRetry: widget.onRetryInitial),
            ),
          ],
        ),
      );
    }
    if (s.isEmpty) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: widget.empty ??
                  EmptyState(
                      icon: Icons.inbox_outlined,
                      title: context.l10n.coreNothingHere),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.separated(
        controller: _controller,
        padding: widget.padding,
        itemCount: s.items.length + 1, // +1 footer
        separatorBuilder: (_, __) => const SizedBox(height: AppTokens.space12),
        itemBuilder: (context, i) {
          if (i == s.items.length) return _Footer(state: s, onRetry: widget.onLoadMore);
          return widget.itemBuilder(context, s.items[i]);
        },
      ),
    );
  }
}

class _Footer<T> extends StatelessWidget {
  const _Footer({required this.state, required this.onRetry});
  final PagedState<T> state;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(AppTokens.space16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.error != null) {
      return Padding(
        padding: const EdgeInsets.all(AppTokens.space16),
        child: Center(
          child: TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.coreCouldntLoadMore),
          ),
        ),
      );
    }
    return const SizedBox(height: AppTokens.space24);
  }
}

class _InitialError extends StatelessWidget {
  const _InitialError({required this.error, required this.onRetry});
  final Object error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final message = error is AppException
        ? (error as AppException).message
        : context.l10n.coreSomethingWrong;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 32, color: scheme.error),
            const SizedBox(height: AppTokens.space12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppTokens.space16),
            FilledButton(
                onPressed: onRetry, child: Text(context.l10n.coreRetry)),
          ],
        ),
      ),
    );
  }
}
