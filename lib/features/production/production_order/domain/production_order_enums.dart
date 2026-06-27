enum ProductionOrderStatus {
  planned, inProgress, completed, cancelled;

  String get wire => switch (this) {
        ProductionOrderStatus.planned => 'planned',
        ProductionOrderStatus.inProgress => 'in_progress',
        ProductionOrderStatus.completed => 'completed',
        ProductionOrderStatus.cancelled => 'cancelled',
      };

  static ProductionOrderStatus fromWire(String s) =>
      ProductionOrderStatus.values.firstWhere((e) => e.wire == s);
}
