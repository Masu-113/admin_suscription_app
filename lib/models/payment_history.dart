class PaymentHistory {
  final int? id;

  final DateTime paymentDate;

  final double amount;

  final int subscriptionId;

  final DateTime coveredUntil;

  PaymentHistory({
    this.id,

    required this.paymentDate,

    required this.amount,

    required this.subscriptionId,

    required this.coveredUntil,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,

      'payment_date': paymentDate.toIso8601String(),

      'amount': amount,

      'subscription_id': subscriptionId,

      'covered_until': coveredUntil.toIso8601String(),
    };
  }

  factory PaymentHistory.fromMap(Map<String, dynamic> map) {
    return PaymentHistory(
      id: map['id'] as int?,

      paymentDate: DateTime.parse(map['payment_date'] as String),

      amount: (map['amount'] as num).toDouble(),

      subscriptionId: map['subscription_id'] as int,

      coveredUntil: DateTime.parse(map['covered_until'] as String),
    );
  }
}
