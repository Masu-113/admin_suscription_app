import 'package:flutter/material.dart';

import '../models/payment_history.dart';
import '../data/repositories/payment_history_repository.dart';

enum PaymentValidationResult { allowed, duplicate }

class PaymentHistoryProvider extends ChangeNotifier {
  final PaymentHistoryRepository _repo = PaymentHistoryRepository();

  List<PaymentHistory> payments = [];

  bool isLoading = false;

  int? currentUserId;

  // CARGAR TODOS
  // futuro uso admin

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

  // CARGAR PAGOS DEL USUARIO

  Future<void> loadUserPayments(int userId) async {
    try {
      isLoading = true;

      currentUserId = userId;

      notifyListeners();

      payments = await _repo.getPaymentsByUser(userId);
    } catch (e) {
      debugPrint("Error loading user payments: $e");
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

    if (currentUserId != null) {
      await loadUserPayments(currentUserId!);
    } else {
      await loadPayments();
    }

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

    if (currentUserId != null) {
      await loadUserPayments(currentUserId!);
    } else {
      await loadPayments();
    }
  }

  Future<void> deletePayment(int id) async {
    await _repo.deletePayment(id);

    if (currentUserId != null) {
      await loadUserPayments(currentUserId!);
    } else {
      await loadPayments();
    }
  }
}
