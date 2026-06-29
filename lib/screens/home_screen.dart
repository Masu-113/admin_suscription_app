import 'package:admin_suscription_app/screens/category_screen.dart';
import 'package:admin_suscription_app/screens/payment_method_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/subscription_provider.dart';
import '../providers/payment_history_provider.dart';

import '../models/payment_history.dart';
import '../core/subscription_status.dart';

import 'add_subscription_screen.dart';
import 'subscription_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<PaymentHistoryProvider>().loadPayments();
    });
  }

  String formatDate(DateTime date) {
    return date.toLocal().toString().split(' ')[0];
  }

  DateTime getLastCoveredUntil(
    List<PaymentHistory> payments,
    DateTime startDate,
  ) {
    if (payments.isEmpty) {
      return startDate;
    }

    final last = payments.reduce(
      (a, b) => a.coveredUntil.isAfter(b.coveredUntil) ? a : b,
    );

    return last.coveredUntil;
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Mis Suscripciones")),

      body: Consumer<PaymentHistoryProvider>(
        builder: (context, paymentProvider, _) {
          if (subscriptionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (subscriptionProvider.subscriptions.isEmpty) {
            return const Center(child: Text("No hay suscripciones"));
          }

          return ListView.builder(
            itemCount: subscriptionProvider.subscriptions.length,

            itemBuilder: (context, index) {
              final sub = subscriptionProvider.subscriptions[index];

              final subscription = sub.subscription;

              final payments = paymentProvider.payments
                  .where((p) => p.subscriptionId == subscription.id)
                  .toList();

              final lastCovered = getLastCoveredUntil(
                payments,
                subscription.startDate,
              );

              final status = SubscriptionStatusHelper.getStatus(lastCovered);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

                child: ListTile(
                  title: Text(subscription.serviceName),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text("Inicio: ${formatDate(subscription.startDate)}"),

                      Text(
                        "Estado: ${SubscriptionStatusHelper.getText(status)}",
                      ),

                      Text("Activo hasta: ${formatDate(lastCovered)}"),

                      Text("Category: ${sub.categoryName}"),

                      Text("Payment: ${sub.paymentMethodName}"),
                    ],
                  ),

                  isThreeLine: false,

                  onTap: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) => SubscriptionDetailScreen(data: sub),
                      ),
                    );
                  },

                  leading: const Icon(Icons.subscriptions),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      Text("\$${subscription.cost}"),

                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),

                        onPressed: () async {
                          await Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (_) => AddSubscriptionScreen(
                                subscription: subscription,
                              ),
                            ),
                          );
                        },
                      ),

                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),

                        onPressed: () {
                          if (subscription.id != null) {
                            context
                                .read<SubscriptionProvider>()
                                .deleteSubscription(subscription.id!);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          FloatingActionButton(
            heroTag: "add_sub",

            child: const Icon(Icons.add),

            onPressed: () {
              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (_) => const AddSubscriptionScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          FloatingActionButton(
            heroTag: "categories",

            backgroundColor: Colors.orange,

            child: const Icon(Icons.category),

            onPressed: () {
              Navigator.push(
                context,

                MaterialPageRoute(builder: (_) => const CategoryScreen()),
              );
            },
          ),

          const SizedBox(height: 10),

          FloatingActionButton(
            heroTag: "payments",

            backgroundColor: Colors.green,

            child: const Icon(Icons.payment),

            onPressed: () {
              Navigator.push(
                context,

                MaterialPageRoute(builder: (_) => const PaymentMethodScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
