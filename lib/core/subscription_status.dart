enum SubscriptionStatus { active, aboutToExpire, expired }

class SubscriptionStatusHelper {
  static SubscriptionStatus getStatus(DateTime coveredUntil) {
    final now = DateTime.now();

    if (now.isAfter(coveredUntil)) {
      return SubscriptionStatus.expired;
    }

    final daysLeft = coveredUntil.difference(now).inDays;

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
}
