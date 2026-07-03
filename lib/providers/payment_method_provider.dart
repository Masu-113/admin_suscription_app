import 'package:flutter/material.dart';

import '../data/repositories/payment_method_repository.dart';
import '../models/payment_method.dart';

class PaymentMethodProvider extends ChangeNotifier {
  final PaymentMethodRepository _repo = PaymentMethodRepository();

  List<PaymentMethod> methods = [];

  bool isLoading = false;

  String? currentUserId;

  // ==========================
  // LOAD USER METHODS
  // ==========================

  Future<void> loadUserMethods(String userId) async {
    try {
      isLoading = true;
      currentUserId = userId;
      notifyListeners();

      methods = await _repo.getPaymentMethodsByUser(userId);
    } catch (e) {
      debugPrint("Error loading payment methods: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ==========================
  // ADD
  // ==========================

  Future<void> addMethod(PaymentMethod method) async {
    if (method.userId == null) {
      throw Exception("No se puede crear método sin usuario");
    }

    try {
      isLoading = true;
      notifyListeners();

      await _repo.insertPaymentMethod(method);

      if (currentUserId != null) {
        await loadUserMethods(currentUserId!);
      }
    } catch (e) {
      debugPrint("Error adding payment method: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ==========================
  // UPDATE
  // ==========================

  Future<void> updateMethod(PaymentMethod method) async {
    try {
      isLoading = true;
      notifyListeners();

      await _repo.updatePaymentMethod(
        cloudId: method.cloudId!,
        type: method.type,
        details: method.details,
      );

      if (currentUserId != null) {
        await loadUserMethods(currentUserId!);
      }
    } catch (e) {
      debugPrint("Error updating payment method: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ==========================
  // DELETE
  // ==========================

  Future<void> deleteMethod(PaymentMethod method) async {
    try {
      isLoading = true;
      notifyListeners();

      await _repo.deletePaymentMethod(method);

      if (currentUserId != null) {
        await loadUserMethods(currentUserId!);
      }
    } catch (e) {
      debugPrint("Error deleting payment method: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
