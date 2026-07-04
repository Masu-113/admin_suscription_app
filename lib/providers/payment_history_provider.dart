import 'package:flutter/material.dart';
import '../models/payment_history.dart';
import '../data/repositories/payment_history_repository.dart';

enum PaymentValidationResult { allowed, duplicate }

class PaymentHistoryProvider extends ChangeNotifier {
  final PaymentHistoryRepository _repo = PaymentHistoryRepository();

  List<PaymentHistory> payments = [];
  bool isLoading = false;

  // 🔹 LOAD LOCAL ONLY (correcto)
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

  // INSERT (SOLO LOCAL AQUÍ)
  Future<bool> addPayment(PaymentHistory payment) async {
    final result = _validatePayment(payment);

    if (result == PaymentValidationResult.duplicate) {
      return false;
    }

    try {
      final localId = await _repo.insertPayment(payment);

      final savedPayment = PaymentHistory(
        id: localId,
        idCloud: payment.idCloud,
        paymentDate: payment.paymentDate,
        amount: payment.amount,
        subscriptionId: payment.subscriptionId,
        coveredUntil: payment.coveredUntil,
      );

      payments.add(savedPayment);
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint("Error adding payment: $e");
      return false;
    }
  }

  // 🔹 VALIDACIÓN LOCAL (OK mantenerla)
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

    if (list.isEmpty) return null;

    list.sort((a, b) => b.coveredUntil.compareTo(a.coveredUntil));
    return list.first;
  }

  // 🔹 LOCAL UPDATE
  Future<void> updatePayment(PaymentHistory payment) async {
    await _repo.updateLocal(payment);
    await loadPayments();
  }

  // 🔹 LOCAL DELETE
  Future<void> deletePayment(int id) async {
    await _repo.deleteLocal(id);
    await loadPayments();
  }
}
