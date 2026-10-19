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
    final totalMonths = from.month - 1 + months;
    final year = from.year + totalMonths ~/ 12;
    final month = totalMonths % 12 + 1;

    final lastDayOfMonth = DateTime(year, month + 1, 0).day;
    final day = from.day > lastDayOfMonth ? lastDayOfMonth : from.day;

    return DateTime(year, month, day);
  }
}
