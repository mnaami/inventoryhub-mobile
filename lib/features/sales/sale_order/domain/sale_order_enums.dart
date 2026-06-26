enum OrderStatus {
  draft, confirmed, processing, shipped, delivered, cancelled;

  String get wire => switch (this) {
        OrderStatus.draft => 'draft',
        OrderStatus.confirmed => 'confirmed',
        OrderStatus.processing => 'processing',
        OrderStatus.shipped => 'shipped',
        OrderStatus.delivered => 'delivered',
        OrderStatus.cancelled => 'cancelled',
      };
  static OrderStatus fromWire(String s) =>
      OrderStatus.values.firstWhere((e) => e.wire == s);
}

enum PaymentStatus {
  notPaid, partial, paid;

  String get wire => switch (this) {
        PaymentStatus.notPaid => 'not_paid',
        PaymentStatus.partial => 'partial',
        PaymentStatus.paid => 'paid',
      };
  static PaymentStatus fromWire(String s) =>
      PaymentStatus.values.firstWhere((e) => e.wire == s);
}

enum ShippingStatus {
  notShipped, partiallyShipped, fullyShipped;

  String get wire => switch (this) {
        ShippingStatus.notShipped => 'not_shipped',
        ShippingStatus.partiallyShipped => 'partially_shipped',
        ShippingStatus.fullyShipped => 'fully_shipped',
      };
  static ShippingStatus fromWire(String s) =>
      ShippingStatus.values.firstWhere((e) => e.wire == s);
}

enum PaymentMethod {
  cash, creditCard, bankTransfer, check, digitalWallet, other;

  String get wire => switch (this) {
        PaymentMethod.cash => 'cash',
        PaymentMethod.creditCard => 'credit_card',
        PaymentMethod.bankTransfer => 'bank_transfer',
        PaymentMethod.check => 'check',
        PaymentMethod.digitalWallet => 'digital_wallet',
        PaymentMethod.other => 'other',
      };
  static PaymentMethod fromWire(String s) =>
      PaymentMethod.values.firstWhere((e) => e.wire == s);
}

enum PaymentRecordStatus {
  pending, completed, failed, refunded;

  String get wire => name;
  static PaymentRecordStatus fromWire(String s) =>
      PaymentRecordStatus.values.firstWhere((e) => e.wire == s);
}

enum ShipmentStatus {
  shipped, inTransit, delivered, returned;

  String get wire => switch (this) {
        ShipmentStatus.shipped => 'shipped',
        ShipmentStatus.inTransit => 'in_transit',
        ShipmentStatus.delivered => 'delivered',
        ShipmentStatus.returned => 'returned',
      };
  static ShipmentStatus fromWire(String s) =>
      ShipmentStatus.values.firstWhere((e) => e.wire == s);
}
