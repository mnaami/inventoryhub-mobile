import 'package:flutter/material.dart';
import '../../app/theme/app_tokens.dart';

/// Presentational shell for swipeable dashboard sections: a card with a
/// header row (icon + per-page title + animated dot indicator) over a
/// fixed-height [PageView]. Pure chrome — page content and data wiring stay
/// feature-local.
class SwipeableStatsSection extends StatefulWidget {
  const SwipeableStatsSection({
    super.key,
    required this.pageCount,
    required this.titleForPage,
    required this.itemBuilder,
    this.leadingIcon = Icons.analytics_rounded,
    this.initialPage = 0,
    this.pageHeight = 96,
  });

  final int pageCount;
  final String Function(int page) titleForPage;
  final IndexedWidgetBuilder itemBuilder;
  final IconData leadingIcon;
  final int initialPage;
  final double pageHeight;

  @override
  State<SwipeableStatsSection> createState() => _SwipeableStatsSectionState();
}

class _SwipeableStatsSectionState extends State<SwipeableStatsSection> {
  late final PageController _controller;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _controller = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(widget.leadingIcon, color: scheme.primary, size: 20),
                  const SizedBox(width: AppTokens.space8),
                  Text(
                    widget.titleForPage(_currentPage),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
              Row(
                children: List.generate(widget.pageCount, (index) {
                  final isActive = _currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: isActive ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: isActive
                          ? scheme.primary
                          : scheme.outlineVariant.withOpacity(0.6),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space16),
          SizedBox(
            height: widget.pageHeight,
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: widget.pageCount,
              itemBuilder: widget.itemBuilder,
            ),
          ),
        ],
      ),
    );
  }
}
