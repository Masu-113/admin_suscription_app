class SubscriptionHistory {
  final int? id;

  final int subscriptionId;

  final String action;

  final DateTime actionDate;

  SubscriptionHistory({
    this.id,
    required this.subscriptionId,
    required this.action,
    required this.actionDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,

      'subscription_id': subscriptionId,

      'action': action,

      'action_date': actionDate.toIso8601String(),
    };
  }

  factory SubscriptionHistory.fromMap(Map<String, dynamic> map) {
    return SubscriptionHistory(
      id: map['id'] as int?,

      subscriptionId: map['subscription_id'] as int,

      action: map['action'] as String,

      actionDate: DateTime.parse(map['action_date'] as String),
    );
  }
}
