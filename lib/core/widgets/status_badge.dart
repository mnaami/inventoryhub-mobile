import 'package:flutter/material.dart';
import '../../app/theme/app_tokens.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge._(this._label, this._fg, this._bg, {super.key});
  const StatusBadge.low({Key? key})
      : this._('Low', AppTokens.lowFg, AppTokens.lowBg, key: key);
  const StatusBadge.out({Key? key})
      : this._('Out', AppTokens.outFg, AppTokens.outBg, key: key);

  final String _label;
  final Color _fg;
  final Color _bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(_label,
          style: TextStyle(color: _fg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
