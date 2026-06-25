class PaymentHistory {
  int id;
  DateTime paymentDate;
  double amount;
  int subscriptionId;

  PaymentHistory({
    required this.id,
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
}
