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
    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      onChanged: _onChanged,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(icon: const Icon(Icons.clear), onPressed: _clear),
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}
