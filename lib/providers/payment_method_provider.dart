import 'package:flutter/material.dart';

import '../data/repositories/payment_method_repository.dart';
import '../models/payment_method.dart';

class PaymentMethodProvider extends ChangeNotifier {
  final PaymentMethodRepository _repo = PaymentMethodRepository();

  List<PaymentMethod> methods = [];

  bool isLoading = false;

  int? currentUserId;

  // TODOS LOS METODOS
  // futuro uso admin

  Future<void> loadMethods() async {
    try {
      isLoading = true;

      notifyListeners();

      methods = await _repo.getPaymentMethods();
    } catch (e) {
      debugPrint("Error loading payment methods: $e");
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }

  // METODOS DEL USUARIO

  Future<void> loadUserMethods(int userId) async {
    try {
      currentUserId = userId;

      isLoading = true;

      notifyListeners();

      methods = await _repo.getPaymentMethodsByUser(userId);
    } catch (e) {
      debugPrint("Error loading user payment methods: $e");
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }

  // ADD

  Future<void> addMethod(PaymentMethod method) async {
    await _repo.insertPaymentMethod(method);

    if (currentUserId != null) {
      await loadUserMethods(currentUserId!);
    } else {
      await loadMethods();
    }
  }

  // UPDATE

  Future<void> updateMethod(PaymentMethod method) async {
    await _repo.updatePaymentMethod(method);

    if (currentUserId != null) {
      await loadUserMethods(currentUserId!);
    } else {
      await loadMethods();
    }
  }

  // DELETE

  Future<void> deleteMethod(int id) async {
    await _repo.deletePaymentMethod(id);

    if (currentUserId != null) {
      await loadUserMethods(currentUserId!);
    } else {
      await loadMethods();
    }
  }
}
