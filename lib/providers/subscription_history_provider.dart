import 'package:flutter/material.dart';

import '../models/subscription_history.dart';
import '../data/repositories/subscription_history_repository.dart';

class SubscriptionHistoryProvider extends ChangeNotifier {
  final SubscriptionHistoryRepository _repo = SubscriptionHistoryRepository();

  List<SubscriptionHistory> history = [];

  bool isLoading = false;

  // CARGAR HISTORIAL DE UNA SUSCRIPCIÓN

  Future<void> loadHistory(int subscriptionId) async {
    try {
      isLoading = true;
      notifyListeners();

      history = await _repo.getHistoryBySubscription(subscriptionId);
    } catch (e) {
      debugPrint("Error loading subscription history: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // AGREGAR EVENTO

  Future<void> addHistory(SubscriptionHistory item) async {
    await _repo.insertHistory(item);

    await loadHistory(item.subscriptionId);
  }

  // ELIMINAR HISTORIAL

  Future<void> deleteHistory(int subscriptionId) async {
    await _repo.deleteHistoryBySubscription(subscriptionId);

    history.clear();

    notifyListeners();
  }
}
