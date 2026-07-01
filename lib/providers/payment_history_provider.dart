import 'package:flutter/material.dart';
import '../models/payment_history.dart';
import '../data/repositories/payment_history_repository.dart';

enum PaymentValidationResult { allowed, duplicate }

class PaymentHistoryProvider extends ChangeNotifier {
  final PaymentHistoryRepository _repo = PaymentHistoryRepository();

  List<PaymentHistory> payments = [];
  bool isLoading = false;

  // CARGAR TODOS LOS PAGOS
  Future<void> loadPayments() async {
    try {
      isLoading = true;
      notifyListeners();

      payments = await _repo.getPayments();
    } catch (e) {
      debugPrint("Error loading payments: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // AGREGAR PAGO
  Future<bool> addPayment(PaymentHistory payment) async {
    final result = _validatePayment(payment);

    if (result == PaymentValidationResult.duplicate) {
      return false;
    }

    await _repo.insertPayment(payment);
    await loadPayments(); // Cargar todos los pagos después de agregar uno nuevo

    return true;
  }

  PaymentValidationResult _validatePayment(PaymentHistory payment) {
    if (_isDuplicate(payment)) {
      return PaymentValidationResult.duplicate;
    }

    return PaymentValidationResult.allowed;
  }

  bool _isDuplicate(PaymentHistory newPayment) {
    return payments.any(
      (p) =>
          p.subscriptionId == newPayment.subscriptionId &&
          p.paymentDate.year == newPayment.paymentDate.year &&
          p.paymentDate.month == newPayment.paymentDate.month &&
          p.paymentDate.day == newPayment.paymentDate.day,
    );
  }

  PaymentHistory? getLastPaymentForSubscription(int subscriptionId) {
    final list = payments
        .where((p) => p.subscriptionId == subscriptionId)
        .toList();

    if (list.isEmpty) {
      return null;
    }

    list.sort((a, b) => b.coveredUntil.compareTo(a.coveredUntil));
    return list.first;
  }

  Future<void> updatePayment(PaymentHistory payment) async {
    await _repo.updatePayment(payment);
    await loadPayments(); // Cargar todos los pagos después de actualizar uno
  }

  Future<void> deletePayment(int id) async {
    await _repo.deletePayment(id);
    await loadPayments(); // Cargar todos los pagos después de eliminar uno
  }
}
