import 'dart:async';
import 'package:flutter/material.dart';

/// A debounced text field. Calls [onChanged] [debounce] after typing stops.
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    this.initial = '',
    required this.onChanged,
    this.hint = 'Search',
    this.debounce = const Duration(milliseconds: 300),
    this.autofocus = true,
  });

  final String initial;
  final ValueChanged<String> onChanged;
  final String hint;
  final Duration debounce;
  final bool autofocus;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _timer?.cancel();
    _timer = Timer(widget.debounce, () => widget.onChanged(value));
    setState(() {}); // refresh clear-button visibility
  }

  void _clear() {
    _controller.clear();
    _timer?.cancel();
    widget.onChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      onChanged: _onChanged,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: _clear,
              ),
        filled: true,
        fillColor: isLight
            ? Colors.black.withOpacity(0.04)
            : scheme.surfaceContainerHighest.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        isDense: true,
      ),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: scheme.onSurface,
      ),
    );
  }
}
