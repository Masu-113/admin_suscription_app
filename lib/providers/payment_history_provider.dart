import 'package:flutter/material.dart';

import '../models/payment_history.dart';
import '../data/repositories/payment_history_repository.dart';

class PaymentHistoryProvider extends ChangeNotifier {
  final PaymentHistoryRepository _repo = PaymentHistoryRepository();

  List<PaymentHistory> payments = [];

  bool isLoading = false;

  // 🟢 CARGAR PAGOS
  Future<void> loadPayments() async {
    isLoading = true;
    notifyListeners();

    payments = await _repo.getPayments();

    isLoading = false;
    notifyListeners();
  }

  // 🟢 AGREGAR PAGO
  Future<int> addPayment(PaymentHistory payment) async {
    final id = await _repo.insertPayment(payment);

    await loadPayments();

    return id;
  }

  // 🟠 ACTUALIZAR PAGO
  Future<void> updatePayment(PaymentHistory payment) async {
    await _repo.updatePayment(payment);

    await loadPayments();
  }

  // 🔴 ELIMINAR PAGO
  Future<void> deletePayment(int id) async {
    await _repo.deletePayment(id);

    await loadPayments();
  }
}
