import 'package:flutter/material.dart';
import '../../app/theme/app_tokens.dart';
import '../l10n/l10n_ext.dart';

enum _StatusBadgeKind { low, out }

class StatusBadge extends StatelessWidget {
  const StatusBadge._(this._kind, this._fg, this._bg, {super.key});
  const StatusBadge.low({Key? key})
      : this._(_StatusBadgeKind.low, AppTokens.lowFg, AppTokens.lowBg,
            key: key);
  const StatusBadge.out({Key? key})
      : this._(_StatusBadgeKind.out, AppTokens.outFg, AppTokens.outBg,
            key: key);

  final _StatusBadgeKind _kind;
  final Color _fg;
  final Color _bg;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label =
        _kind == _StatusBadgeKind.low ? l10n.coreStatusLow : l10n.coreStatusOut;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(color: _fg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
