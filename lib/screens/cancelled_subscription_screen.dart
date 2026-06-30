import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/subscription_provider.dart';
import '../providers/payment_history_provider.dart';

import 'subscription_detail_screen.dart';

class CancelledSubscriptionScreen extends StatelessWidget {
  const CancelledSubscriptionScreen({super.key});

  String formatDate(DateTime date) {
    return date.toLocal().toString().split(' ')[0];
  }

  Future<void> _restoreSubscription(
    BuildContext context,
    int id,
    String name,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,

      builder: (_) {
        return AlertDialog(
          title: const Text("Reactivar suscripción"),

          content: Text("¿Deseas reactivar $name?"),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),

              child: const Text("Cancelar"),
            ),

            TextButton(
              onPressed: () => Navigator.pop(context, true),

              child: const Text("Reactivar"),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    await context.read<SubscriptionProvider>().restoreSubscription(id);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Suscripción reactivada correctamente.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = context.watch<SubscriptionProvider>();

    final cancelledSubscriptions = subscriptionProvider.subscriptions
        .where((s) => s.subscription.isCancelled)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Suscripciones canceladas")),

      body: Consumer<PaymentHistoryProvider>(
        builder: (context, paymentProvider, _) {
          if (cancelledSubscriptions.isEmpty) {
            return const Center(child: Text("No hay suscripciones canceladas"));
          }

          return ListView.builder(
            itemCount: cancelledSubscriptions.length,

            itemBuilder: (context, index) {
              final sub = cancelledSubscriptions[index];

              final subscription = sub.subscription;

              final lastPayment = subscription.id != null
                  ? paymentProvider.getLastPaymentForSubscription(
                      subscription.id!,
                    )
                  : null;

              final lastCovered =
                  lastPayment?.coveredUntil ?? subscription.startDate;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

                child: ListTile(
                  title: Text(subscription.serviceName),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text("Estado: Cancelada"),

                      Text("Último periodo: ${formatDate(lastCovered)}"),

                      Text("Costo: \$${subscription.cost}"),
                    ],
                  ),

                  leading: const Icon(Icons.cancel, color: Colors.red),

                  trailing: IconButton(
                    icon: const Icon(Icons.restore, color: Colors.green),

                    tooltip: "Reactivar",

                    onPressed: () {
                      if (subscription.id == null) {
                        return;
                      }

                      _restoreSubscription(
                        context,

                        subscription.id!,

                        subscription.serviceName,
                      );
                    },
                  ),

                  onTap: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) => SubscriptionDetailScreen(data: sub),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
