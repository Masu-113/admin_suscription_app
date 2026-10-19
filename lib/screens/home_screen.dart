import 'package:admin_suscription_app/screens/category_screen.dart';
import 'package:admin_suscription_app/screens/payment_method_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/session_manager.dart';
import '../core/subscription_status.dart';

import '../providers/subscription_provider.dart';
import '../providers/payment_history_provider.dart';

import 'add_subscription_screen.dart';
import 'subscription_detail_screen.dart';
import 'cancelled_subscription_screen.dart';
import 'dashboard_screen.dart';

import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    final session = SessionManager.instance;

    debugPrint("========== HOME ==========");
    debugPrint("Session hash: ${session.hashCode}");
    debugPrint("Current user: ${session.currentUser?.email}");

    Future.microtask(() async {
      if (!mounted) return;

      final user = SessionManager.instance.currentUser;
      final subscriptionProvider = context.read<SubscriptionProvider>();
      final paymentProvider = context.read<PaymentHistoryProvider>();

      if (user != null) {
        await subscriptionProvider.loadUserSubscriptions(user.id);
      }

      await paymentProvider.loadPayments();
    });
  }

  Widget _infoMini(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String formatDate(DateTime date) {
    return date.toLocal().toString().split(' ')[0];
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cerrar sesión"),
        content: const Text("¿Seguro que deseas cerrar sesión?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Cerrar sesión"),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!mounted) return;

    context.read<SubscriptionProvider>().clear();
    context.read<PaymentHistoryProvider>().clear();

    await SessionManager.instance.logout();
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
    if (!mounted) {
      return;
    }

    await context.read<SubscriptionProvider>().cancelSubscription(id);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Suscripción cancelada correctamente.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = context.watch<SubscriptionProvider>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Mis Suscripciones",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              SessionManager.instance.currentUser?.email ?? "",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Cerrar sesión",
            onPressed: _logout,
          ),
        ],
      ),
      body: Consumer<PaymentHistoryProvider>(
        builder: (context, paymentProvider, _) {
          if (subscriptionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final activeSubscriptions = subscriptionProvider.subscriptions
              .where((s) => !s.subscription.isCancelledBool)
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
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SubscriptionDetailScreen(data: sub),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 24,
                              child: Icon(Icons.subscriptions),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                subscription.serviceName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Text(
                              "\$${subscription.cost}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        Row(
                          children: [
                            Expanded(
                              child: _infoMini(
                                "Inicio",
                                formatDate(subscription.startDate),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _infoMini(
                                "Activo hasta",
                                formatDate(lastCovered),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: _infoMini("Categoría", sub.categoryName),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _infoMini("Pago", sub.paymentMethodName),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Chip(
                          backgroundColor: SubscriptionStatusHelper.getColor(
                            status,
                          ).withValues(alpha: 0.15),
                          label: Text(
                            SubscriptionStatusHelper.getText(status),
                            style: TextStyle(
                              color: SubscriptionStatusHelper.getColor(status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
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
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.menu,
        activeIcon: Icons.close,
        spacing: 10,
        spaceBetweenChildren: 8,
        direction: SpeedDialDirection.up,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        overlayColor: Colors.black,
        overlayOpacity: 0.25,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add),
            backgroundColor: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddSubscriptionScreen(),
                ),
              );
            },
          ),

          SpeedDialChild(
            child: const Icon(Icons.dashboard),
            backgroundColor: Colors.deepPurple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            },
          ),

          SpeedDialChild(
            child: const Icon(Icons.category),
            backgroundColor: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoryScreen()),
              );
            },
          ),

          SpeedDialChild(
            child: const Icon(Icons.payment),
            backgroundColor: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentMethodScreen()),
              );
            },
          ),

          SpeedDialChild(
            child: const Icon(Icons.history),
            backgroundColor: Colors.red,
            onTap: () {
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
