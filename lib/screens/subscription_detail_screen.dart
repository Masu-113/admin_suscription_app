import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/subscription_full.dart';
import '../models/payment_history.dart';
import '../providers/payment_history_provider.dart';

class SubscriptionDetailScreen extends StatefulWidget {
  final SubscriptionFull data;

  const SubscriptionDetailScreen({super.key, required this.data});

  @override
  State<SubscriptionDetailScreen> createState() =>
      _SubscriptionDetailScreenState();
}

class _SubscriptionDetailScreenState extends State<SubscriptionDetailScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<PaymentHistoryProvider>().loadPayments();
    });
  }

  void _addPayment() async {
    final payment = PaymentHistory(
      paymentDate: DateTime.now(),

      amount: widget.data.subscription.cost,

      subscriptionId: widget.data.subscription.id!,
    );

    await context.read<PaymentHistoryProvider>().addPayment(payment);
  }

  @override
  Widget build(BuildContext context) {
    final subscription = widget.data.subscription;

    return Scaffold(
      appBar: AppBar(title: Text(subscription.serviceName)),

      body: Consumer<PaymentHistoryProvider>(
        builder: (context, provider, _) {
          final payments = provider.payments
              .where((p) => p.subscriptionId == subscription.id)
              .toList();

          return Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // 🧾 INFO SUSCRIPCIÓN
                Text(
                  subscription.serviceName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text("\$${subscription.cost} / mes"),

                const SizedBox(height: 4),

                Text("Categoría: ${widget.data.categoryName}"),

                Text("Método: ${widget.data.paymentMethodName}"),

                const Divider(height: 30),

                // 💰 HISTORIAL
                const Text(
                  "Historial de pagos",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: payments.isEmpty
                      ? const Center(child: Text("No hay pagos aún"))
                      : ListView.builder(
                          itemCount: payments.length,

                          itemBuilder: (context, index) {
                            final p = payments[index];

                            return ListTile(
                              leading: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),

                              title: Text("\$${p.amount}"),

                              subtitle: Text(
                                p.paymentDate.toString().substring(0, 10),
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 10),

                // ➕ BOTÓN PAGO
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),

                    label: const Text("Registrar pago"),

                    onPressed: _addPayment,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
