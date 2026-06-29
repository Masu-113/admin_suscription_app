enum BillingCycle { monthly, yearly }

extension BillingCycleExtension on BillingCycle {
  String get label {
    switch (this) {
      case BillingCycle.monthly:
        return "Monthly";
      case BillingCycle.yearly:
        return "Yearly";
    }
  }

  int get months {
    switch (this) {
      case BillingCycle.monthly:
        return 1;
      case BillingCycle.yearly:
        return 12;
    }
  }

  DateTime nextDate(DateTime from) {
    return DateTime(from.year, from.month + months, from.day);
  }
}
