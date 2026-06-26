enum PurchaseOrderStatus {
  draft, sent, confirmed, received, cancelled;

  String get wire => name;
  static PurchaseOrderStatus fromWire(String s) =>
      PurchaseOrderStatus.values.firstWhere((e) => e.wire == s);
}

enum ReceiptStatus {
  notReceived, partial, fullyReceived;

  String get wire => switch (this) {
        ReceiptStatus.notReceived => 'not_received',
        ReceiptStatus.partial => 'partial',
        ReceiptStatus.fullyReceived => 'fully_received',
      };
  static ReceiptStatus fromWire(String s) =>
      ReceiptStatus.values.firstWhere((e) => e.wire == s);
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

enum ReceiptDocStatus {
  draft, posted, cancelled;

  String get wire => name;
  static ReceiptDocStatus fromWire(String s) =>
      ReceiptDocStatus.values.firstWhere((e) => e.wire == s);
}

enum PaymentDocStatus {
  draft, posted, cancelled;

  String get wire => name;
  static PaymentDocStatus fromWire(String s) =>
      PaymentDocStatus.values.firstWhere((e) => e.wire == s);
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
