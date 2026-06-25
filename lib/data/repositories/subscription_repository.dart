import '../local/database_helper.dart';
import '../../models/subscription.dart';

class SubscriptionRepository {
  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<void> insertSubscription(Subscription subscription) async {
    final db = await dbHelper.database;

    await db.insert("subscriptions", {
      "id": subscription.id,

      "serviceName": subscription.serviceName,

      "price": subscription.price,

      "renewalDate": subscription.renewalDate.toIso8601String(),

      "status": subscription.status,
    });
  }

  Future<List<Subscription>> getSubscriptions() async {
    final db = await dbHelper.database;

    final result = await db.query("subscriptions");

    return result
        .map(
          (e) => Subscription(
            id: e["id"].toString(),

            serviceName: e["serviceName"].toString(),

            price: double.parse(e["price"].toString()),

            renewalDate: DateTime.parse(e["renewalDate"].toString()),

            status: e["status"].toString(),
          ),
        )
        .toList();
  }
}
