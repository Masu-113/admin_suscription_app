import 'package:flutter/material.dart';

import '../data/repositories/payment_method_repository.dart';
import '../models/payment_method.dart';

class PaymentMethodProvider extends ChangeNotifier {
  final PaymentMethodRepository _repo = PaymentMethodRepository();

  List<PaymentMethod> methods = [];
  bool isLoading = false;
  String? errorMessage;
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

  Future<bool> addMethod(PaymentMethod method) async {
    if (method.userId == null) {
      throw Exception("No se puede crear método sin usuario");
    }
    return _run(
      () => _repo.insertPaymentMethod(method),
      "Se guardó en este dispositivo, pero no se pudo sincronizar con la nube.",
    );
  }

  Future<bool> updateMethod(PaymentMethod method) async {
    return _run(
      () => _repo.updatePaymentMethod(method),
      "Se actualizó en este dispositivo, pero no se pudo sincronizar con la nube.",
    );
  }

  Future<bool> deleteMethod(PaymentMethod method) async {
    return _run(
      () => _repo.deletePaymentMethod(method),
      "Se eliminó en este dispositivo, pero no se pudo sincronizar con la nube.",
    );
  }

  Future<bool> _run(Future<void> Function() action, String failMessage) async {
    errorMessage = null;
    var ok = true;

    try {
      isLoading = true;
      notifyListeners();
      await action();
    } catch (e) {
      ok = false;
      errorMessage = failMessage;
      debugPrint("Error en PaymentMethodProvider: $e");
    }

    if (currentUserId != null) {
      await loadUserMethods(currentUserId!);
    } else {
      isLoading = false;
      notifyListeners();
    }

    return ok;
  }
}
