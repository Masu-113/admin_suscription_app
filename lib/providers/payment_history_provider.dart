import 'package:flutter/material.dart';

import '../models/payment_history.dart';
import '../data/repositories/payment_history_repository.dart';

class PaymentHistoryProvider extends ChangeNotifier {
  final PaymentHistoryRepository _repo = PaymentHistoryRepository();

  List<PaymentHistory> payments = [];

  Future<void> loadPayments() async {
    payments = await _repo.getPayments();

    notifyListeners();
  }

  Future<void> addPayment(PaymentHistory payment) async {
    await _repo.insertPayment(payment);

    await loadPayments();
  }

  Future<void> deletePayment(int id) async {
    await _repo.deletePayment(id);

    await loadPayments();
  }
}
