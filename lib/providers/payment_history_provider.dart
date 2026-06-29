import 'package:flutter/material.dart';
import '../models/payment_history.dart';
import '../data/repositories/payment_history_repository.dart';

enum PaymentValidationResult { allowed, duplicate }

class PaymentHistoryProvider extends ChangeNotifier {
  final PaymentHistoryRepository _repo = PaymentHistoryRepository();

  List<PaymentHistory> payments = [];
  bool isLoading = false;

  // CARGAR PAGOS
  Future<void> loadPayments() async {
    isLoading = true;
    notifyListeners();

    payments = await _repo.getPayments();

    isLoading = false;
    notifyListeners();
  }

  // AGREGAR PAGO
  Future<bool> addPayment(PaymentHistory payment) async {
    final result = _validatePayment(payment);

    if (result == PaymentValidationResult.duplicate) {
      return false; // 🚫 solo bloquea duplicados reales
    }

    await _repo.insertPayment(payment);
    await loadPayments();

    return true;
  }

  // VALIDACIÓN CENTRAL (EXTENSIBLE)
  PaymentValidationResult _validatePayment(PaymentHistory newPayment) {
    final isDuplicate = _isDuplicate(newPayment);

    if (isDuplicate) {
      return PaymentValidationResult.duplicate;
    }

    return PaymentValidationResult.allowed;
  }

  // REGLA ÚNICA: DUPLICADOS REALES
  bool _isDuplicate(PaymentHistory newPayment) {
    return payments.any(
      (p) =>
          p.subscriptionId == newPayment.subscriptionId &&
          p.paymentDate.year == newPayment.paymentDate.year &&
          p.paymentDate.month == newPayment.paymentDate.month &&
          p.paymentDate.day == newPayment.paymentDate.day,
    );
  }

  // UPDATE
  Future<void> updatePayment(PaymentHistory payment) async {
    await _repo.updatePayment(payment);
    await loadPayments();
  }

  // DELETE
  Future<void> deletePayment(int id) async {
    await _repo.deletePayment(id);
    await loadPayments();
  }
}
