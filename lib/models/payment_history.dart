class PaymentHistory {
  final int? id;

  final DateTime paymentDate;

  final double amount;

  final int subscriptionId;

  PaymentHistory({
    this.id,

    required this.paymentDate,

    required this.amount,

    required this.subscriptionId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,

      'payment_date': paymentDate.toIso8601String(),

      'amount': amount,

      'subscription_id': subscriptionId,
    };
  }

  factory PaymentHistory.fromMap(Map<String, dynamic> map) {
    return PaymentHistory(
      id: map['id'] as int?,

      paymentDate: DateTime.parse(map['payment_date'] as String),

      amount: (map['amount'] as num).toDouble(),

      subscriptionId: map['subscription_id'] as int,
    );
  }
}
