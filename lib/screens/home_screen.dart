import 'package:admin_suscription_app/screens/category_screen.dart';
import 'package:admin_suscription_app/screens/payment_method_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/subscription_provider.dart';
import '../providers/payment_history_provider.dart';

import '../core/subscription_status.dart';

import 'add_subscription_screen.dart';
import 'subscription_detail_screen.dart';
import 'cancelled_subscription_screen.dart';
import 'dashboard_screen.dart';

import '../providers/user_provider.dart';

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
      final user = context.read<UserProvider>().currentUser;

      if (user != null) {
        context.read<SubscriptionProvider>().loadUserSubscriptions(user.id!);

        context.read<PaymentHistoryProvider>().loadUserPayments(user.id!);
      }
    });
  }

  String formatDate(DateTime date) {
    return date.toLocal().toString().split(' ')[0];
  }

  Future<void> _cancelSubscription(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,

      builder: (_) {
        return AlertDialog(
          title: const Text("Cancelar suscripción"),

          content: Text(
            "¿Deseas cancelar $name?\n\n"
            "La suscripción desaparecerá de activas, "
            "pero conservará su historial de pagos.",
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },

              child: const Text("No"),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },

              child: const Text("Sí"),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    await context.read<SubscriptionProvider>().cancelSubscription(id);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(this.context).showSnackBar(
      const SnackBar(content: Text("Suscripción cancelada correctamente.")),
    );
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

          final activeSubscriptions = subscriptionProvider.subscriptions
              .where((s) => !s.subscription.isCancelled)
              .toList();

          if (activeSubscriptions.isEmpty) {
            return const Center(child: Text("No hay suscripciones activas"));
          }

          return ListView.builder(
            itemCount: activeSubscriptions.length,

            itemBuilder: (context, index) {
              final sub = activeSubscriptions[index];

              final subscription = sub.subscription;

              final lastPayment = paymentProvider.getLastPaymentForSubscription(
                subscription.id!,
              );

              final lastCovered =
                  lastPayment?.coveredUntil ?? subscription.startDate;

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
                        "Estado: "
                        "${SubscriptionStatusHelper.getText(status)}",

                        style: TextStyle(
                          color: SubscriptionStatusHelper.getColor(status),

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text("Activo hasta: ${formatDate(lastCovered)}"),

                      Text("Category: ${sub.categoryName}"),

                      Text("Payment: ${sub.paymentMethodName}"),
                    ],
                  ),

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
                        icon: const Icon(Icons.cancel, color: Colors.red),

                        onPressed: () {
                          if (subscription.id != null) {
                            _cancelSubscription(
                              subscription.id!,

                              subscription.serviceName,
                            );
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
            heroTag: "dashboard",

            backgroundColor: Colors.blue,

            child: const Icon(Icons.dashboard),

            onPressed: () {
              Navigator.push(
                context,

                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            },
          ),
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
          FloatingActionButton(
            heroTag: "cancelled",

            backgroundColor: Colors.red,

            child: const Icon(Icons.history),

            onPressed: () {
              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (_) => const CancelledSubscriptionScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
