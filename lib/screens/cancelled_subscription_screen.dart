import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/subscription_provider.dart';
import '../providers/payment_history_provider.dart';

//import '../core/subscription_status.dart';

import 'subscription_detail_screen.dart';

class CancelledSubscriptionScreen extends StatelessWidget {
  const CancelledSubscriptionScreen({super.key});

  String formatDate(DateTime date) {
    return date.toLocal().toString().split(' ')[0];
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

              final lastPayment = paymentProvider.getLastPaymentForSubscription(
                subscription.id!,
              );

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
