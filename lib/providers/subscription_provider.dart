import 'package:flutter/material.dart';

import '../models/subscription.dart';
import '../models/subscription_full.dart';
import '../data/repositories/subscription_repository.dart';

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionRepository _repo = SubscriptionRepository();

  List<SubscriptionFull> subscriptions = [];

  bool isLoading = false;

  String? currentUserId;

  // ==========================
  // CARGAR TODAS
  // ==========================

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

  // ==========================
  // CARGAR POR USUARIO
  // ==========================

  Future<void> loadUserSubscriptions(String userId) async {
    try {
      isLoading = true;
      currentUserId = userId;
      notifyListeners();

      subscriptions = await _repo.getSubscriptionsFullByUser(userId);
    } catch (e) {
      debugPrint("Error loading user subscriptions: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ==========================
  // AGREGAR
  // ==========================

  Future<int> addSubscription(Subscription sub) async {
    try {
      final id = await _repo.insertSubscription(sub);

      if (currentUserId != null) {
        await loadUserSubscriptions(currentUserId!);
      } else {
        await loadSubscriptions();
      }

      return id;
    } catch (e) {
      debugPrint("Error adding subscription: $e");
      rethrow;
    }
  }

  // ==========================
  // CANCELAR
  // ==========================

  Future<void> cancelSubscription(int id) async {
    try {
      await _repo.cancelSubscription(id);

      if (currentUserId != null) {
        await loadUserSubscriptions(currentUserId!);
      }
    } catch (e) {
      debugPrint("Error cancelling subscription: $e");
      rethrow;
    }
  }

  // ==========================
  // REACTIVAR
  // ==========================

  Future<void> restoreSubscription(int id) async {
    try {
      await _repo.restoreSubscription(id);

      if (currentUserId != null) {
        await loadUserSubscriptions(currentUserId!);
      }
    } catch (e) {
      debugPrint("Error restoring subscription: $e");
      rethrow;
    }
  }

  // ==========================
  // ACTUALIZAR
  // ==========================

  Future<void> updateSubscription(Subscription sub) async {
    try {
      await _repo.updateSubscription(sub);

      if (currentUserId != null) {
        await loadUserSubscriptions(currentUserId!);
      }
    } catch (e) {
      debugPrint("Error updating subscription: $e");
      rethrow;
    }
  }
}
