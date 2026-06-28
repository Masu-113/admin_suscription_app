import 'package:flutter/material.dart';
import '../data/repositories/payment_method_repository.dart';
import '../models/payment_method.dart';

class PaymentMethodProvider extends ChangeNotifier {
  final PaymentMethodRepository _repo = PaymentMethodRepository();

  List<PaymentMethod> methods = [];

  bool isLoading = false;

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

  Future<void> addMethod(PaymentMethod method) async {
    await _repo.insertPaymentMethod(method);

    await loadMethods();
  }

  Future<void> updateMethod(PaymentMethod method) async {
    await _repo.updatePaymentMethod(method);

    await loadMethods();
  }

  Future<void> deleteMethod(int id) async {
    await _repo.deletePaymentMethod(id);

    await loadMethods();
  }
}
