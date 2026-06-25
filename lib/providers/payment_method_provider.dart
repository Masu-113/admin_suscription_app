import 'package:flutter/material.dart';
import '../data/repositories/payment_method_repository.dart';
import '../models/payment_method.dart';

class PaymentMethodProvider extends ChangeNotifier {
  final _repo = PaymentMethodRepository();

  List<PaymentMethod> methods = [];

  Future<void> loadMethods() async {
    methods = await _repo.getPaymentMethods();
    notifyListeners();
  }
}
