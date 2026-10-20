import 'package:flutter/material.dart';

import '../models/subscription.dart';
import '../models/subscription_full.dart';
import '../data/repositories/subscription_repository.dart';
import '../core/session_manager.dart';

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionRepository _repo = SubscriptionRepository();

  List<SubscriptionFull> subscriptions = [];
  bool isLoading = false;
  String? errorMessage;
  String? currentUserId;

  // ==========================
  // CARGAR TODAS
  // ==========================

  Future<void> loadSubscriptions() async {
    final userId = SessionManager.instance.userId;

    if (userId == null) {
      subscriptions = [];
      notifyListeners();
      return;
    }

    await loadUserSubscriptions(userId);
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

  Future<int?> addSubscription(Subscription sub) async {
    errorMessage = null;
    try {
      final id = await _repo.insertSubscription(sub);
      await _reload();
      return id;
    } catch (e) {
      debugPrint("Error adding subscription: $e");
      errorMessage = "No se pudo guardar la suscripción. Revisa tu conexión.";
      return null;
    }
  }

  Future<bool> cancelSubscription(int id) => _runAction(
    () => _repo.cancelSubscription(id),
    "Se canceló en este dispositivo, pero no se pudo sincronizar con la nube.",
  );

  Future<bool> restoreSubscription(int id) => _runAction(
    () => _repo.restoreSubscription(id),
    "Se reactivó en este dispositivo, pero no se pudo sincronizar con la nube.",
  );

  Future<bool> updateSubscription(Subscription sub) => _runAction(
    () => _repo.updateSubscription(sub),
    "Se actualizó en este dispositivo, pero no se pudo sincronizar con la nube.",
  );

  Future<bool> _runAction(
    Future<void> Function() action,
    String failMessage,
  ) async {
    errorMessage = null;
    var ok = true;
    try {
      await action();
    } catch (e) {
      ok = false;
      errorMessage = failMessage;
      debugPrint("Error en SubscriptionProvider: $e");
    }
    await _reload(); // el cambio local ya se hizo, siempre recargar
    return ok;
  }

  Future<void> _reload() async {
    if (currentUserId != null) {
      await loadUserSubscriptions(currentUserId!);
    } else {
      await loadSubscriptions();
    }
  }

  void clear() {
    subscriptions = [];
    currentUserId = null;
    notifyListeners();
  }
}
