import 'package:flutter/material.dart';

import '../models/subscription.dart';
import '../models/subscription_full.dart';
import '../data/repositories/subscription_repository.dart';

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionRepository _repo = SubscriptionRepository();

  List<SubscriptionFull> subscriptions = [];

  bool isLoading = false;

  // LOAD TODAS
  // (futuro uso administrativo)

  Future<void> loadSubscriptions() async {
    try {
      isLoading = true;

      notifyListeners();

      subscriptions = await _repo.getSubscriptionsFull();
    } catch (e) {
      debugPrint("Error loading subscriptions: $e");
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }

  // LOAD POR USUARIO

  Future<void> loadUserSubscriptions(int userId) async {
    try {
      isLoading = true;

      notifyListeners();

      subscriptions = await _repo.getSubscriptionsFullByUser(userId);
    } catch (e) {
      debugPrint("Error loading user subscriptions: $e");
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }

  // ADD

  Future<int> addSubscription(Subscription sub) async {
    final id = await _repo.insertSubscription(sub);

    await loadSubscriptions();

    return id;
  }

  // CANCELAR

  Future<void> cancelSubscription(int id) async {
    await _repo.cancelSubscription(id);

    await loadSubscriptions();
  }

  // REACTIVAR

  Future<void> restoreSubscription(int id) async {
    await _repo.restoreSubscription(id);

    await loadSubscriptions();
  }

  // UPDATE

  Future<void> updateSubscription(Subscription sub) async {
    await _repo.updateSubscription(sub);

    await loadSubscriptions();
  }
}
