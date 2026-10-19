import 'package:flutter/material.dart';

enum SubscriptionStatus { active, aboutToExpire, expired }

class SubscriptionStatusHelper {
  static SubscriptionStatus getStatus(DateTime coveredUntil) {
    final now = DateTime.now();

    final today = DateTime.utc(now.year, now.month, now.day);
    final endDate = DateTime.utc(
      coveredUntil.year,
      coveredUntil.month,
      coveredUntil.day,
    );

    if (today.isAfter(endDate)) {
      return SubscriptionStatus.expired;
    }

    final daysLeft = endDate.difference(today).inDays;

    if (daysLeft <= 3) {
      return SubscriptionStatus.aboutToExpire;
    }

    return SubscriptionStatus.active;
  }

  static String getText(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return "Activa";

      case SubscriptionStatus.aboutToExpire:
        return "Por vencer";

      case SubscriptionStatus.expired:
        return "Vencida";
    }
  }

  static Color getColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return Colors.green;

      case SubscriptionStatus.aboutToExpire:
        return Colors.orange;

      case SubscriptionStatus.expired:
        return Colors.red;
    }
  }
}
