import 'package:flutter/material.dart';
import '../models/subscription.dart';
import '../data/repositories/subscription_repository.dart';

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionRepository _repo = SubscriptionRepository();

  List<Subscription> subscriptions = [];

  bool isLoading = false;

  Future<void> loadSubscriptions() async {
    isLoading = true;
    notifyListeners();

    subscriptions = await _repo.getSubscriptions();

    isLoading = false;
    notifyListeners();
  }

  Future<void> addSubscription(Subscription sub) async {
    await _repo.insertSubscription(sub);

    await loadSubscriptions(); // refresca lista
  }

  Future<void> deleteSubscription(int id) async {
    await _repo.deleteSubscription(id);

    await loadSubscriptions();
  }

  Future<void> updateSubscription(Subscription sub) async {
    await _repo.updateSubscription(sub);

    await loadSubscriptions();
  }
}
